//
//  BrainBotCloudIdeaProvider.swift
//  BrainBot
//
//  Created by Codex on 4/17/26.
//

import Foundation
import OSLog

struct BrainBotCloudConfiguration: Hashable {
    var isEnabled: Bool
    var apiKey: String?
    var endpoint: URL
    var modelName: String

    init(
        isEnabled: Bool = false,
        apiKey: String? = nil,
        endpoint: URL = URL(string: "https://api.openai.com/v1/responses")!,
        modelName: String = "gpt-4.1-mini"
    ) {
        self.isEnabled = isEnabled
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.modelName = modelName
    }

    static var appDefault: BrainBotCloudConfiguration {
        let info = Bundle.main.infoDictionary ?? [:]
        let environment = ProcessInfo.processInfo.environment

        let enabledValue = (info["BRAINBOT_OPENAI_ENABLED"] as? String)
            ?? environment["BRAINBOT_OPENAI_ENABLED"]
        let apiKey = environment["OPENAI_API_KEY"]
            ?? info["BRAINBOT_OPENAI_API_KEY"] as? String
        let endpointValue = (info["BRAINBOT_OPENAI_ENDPOINT"] as? String)
            ?? environment["BRAINBOT_OPENAI_ENDPOINT"]
        let modelName = (info["BRAINBOT_OPENAI_MODEL"] as? String)
            ?? environment["BRAINBOT_OPENAI_MODEL"]
            ?? "gpt-4.1-mini"

        return BrainBotCloudConfiguration(
            isEnabled: enabledValue?.caseInsensitiveCompare("YES") == .orderedSame
                || enabledValue?.caseInsensitiveCompare("true") == .orderedSame
                || enabledValue == "1",
            apiKey: apiKey?.nilIfBlank,
            endpoint: endpointValue.flatMap(URL.init(string:)) ?? URL(string: "https://api.openai.com/v1/responses")!,
            modelName: modelName
        )
    }
}

struct BrainBotCloudIdeaProvider: IdeaSuggestionProviding {
    let configuration: BrainBotCloudConfiguration
    let session: URLSession
    private let logger = Logger(subsystem: "risabsank.BrainBot", category: "OpenAI")

    var modelName: String { configuration.modelName }

    init(
        configuration: BrainBotCloudConfiguration = .appDefault,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }

    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        guard configuration.isEnabled else {
            logger.notice("OpenAI cloud brainstorming is configured but disabled.")
            throw IdeaAssistantError.cloudDisabled
        }

        guard let apiKey = configuration.apiKey?.nilIfBlank else {
            logger.error("OpenAI cloud brainstorming is enabled, but no API key is configured.")
            throw IdeaAssistantError.cloudAPIKeyMissing
        }

        var urlRequest = URLRequest(url: configuration.endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(OpenAIResponsesRequest.ideaSuggestions(
            request: request,
            model: configuration.modelName
        ))

        logger.notice("Requesting OpenAI cloud brainstorm. model=\(configuration.modelName, privacy: .public)")
        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("OpenAI cloud brainstorm returned a non-HTTP response.")
            throw IdeaAssistantError.cloudResponseInvalid
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            logger.error("OpenAI cloud brainstorm failed. statusCode=\(httpResponse.statusCode), preview=\(Self.preview(data), privacy: .public)")
            throw IdeaAssistantError.cloudResponseInvalid
        }

        let responsesResponse = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
        let suggestions = try Self.decodeSuggestions(from: responsesResponse)

        guard suggestions.count == 3 else {
            logger.error("OpenAI cloud brainstorm returned the wrong suggestion count. count=\(suggestions.count)")
            throw IdeaAssistantError.cloudResponseInvalid
        }

        logger.notice("OpenAI cloud brainstorm decoded. suggestionCount=\(suggestions.count)")
        return IdeaAssistanceResult(
            suggestions: suggestions,
            source: .cloud,
            assistanceLevel: request.assistanceLevel,
            modelName: responsesResponse.model ?? configuration.modelName
        )
    }

    static func decodeSuggestions(from response: OpenAIResponsesResponse) throws -> [IdeaSuggestion] {
        guard let outputText = response.outputText else {
            throw IdeaAssistantError.cloudResponseInvalid
        }

        return try LlamaCppLocalIdeaProvider.decodeSuggestions(from: outputText)
    }

    private static func preview(_ data: Data) -> String {
        String(decoding: data.prefix(500), as: UTF8.self)
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
    }
}

private struct OpenAIResponsesRequest: Encodable {
    var model: String
    var input: [InputMessage]
    var text: TextConfiguration

    static func ideaSuggestions(
        request: IdeaAssistanceRequest,
        model: String
    ) -> OpenAIResponsesRequest {
        OpenAIResponsesRequest(
            model: model,
            input: [
                InputMessage(
                    role: "system",
                    content: """
                    You are BrainBot, a concise brainstorming partner.
                    Return JSON only. Do not include markdown, commentary, explanations, or code fences.
                    """
                ),
                InputMessage(
                    role: "user",
                    content: """
                    Read this note and return exactly 3 helpful thought-starters.

                    Rules:
                    - Prefer questions, angles, experiments, or small additions.
                    - Keep every text under 24 words.
                    - Make every text specific to the note.
                    - Do not write the idea for me.

                    Assistance level: \(request.assistanceLevel.rawValue)
                    Title: \(request.trimmedTitle)
                    Note: \(request.trimmedBody)
                    """
                )
            ],
            text: TextConfiguration(format: .ideaSuggestionSchema)
        )
    }
}

private struct InputMessage: Encodable {
    var role: String
    var content: String
}

private struct TextConfiguration: Encodable {
    var format: ResponseFormat
}

private struct ResponseFormat: Encodable {
    var type = "json_schema"
    var name: String
    var strict: Bool
    var schema: JSONSchema

    static let ideaSuggestionSchema = ResponseFormat(
        name: "brainbot_idea_suggestions",
        strict: true,
        schema: JSONSchema(
            type: "object",
            properties: [
                "suggestions": JSONSchema(
                    type: "array",
                    items: JSONSchema(
                        type: "object",
                        properties: [
                            "type": JSONSchema(type: "string", enumValues: ["question", "pathway", "assumption"]),
                            "text": JSONSchema(type: "string")
                        ],
                        required: ["type", "text"],
                        additionalProperties: false
                    )
                )
            ],
            required: ["suggestions"],
            additionalProperties: false
        )
    )
}

private final class JSONSchema: Encodable {
    var type: String
    var properties: [String: JSONSchema]?
    var items: JSONSchema?
    var required: [String]?
    var additionalProperties: Bool?
    var enumValues: [String]?

    init(
        type: String,
        properties: [String: JSONSchema]? = nil,
        items: JSONSchema? = nil,
        required: [String]? = nil,
        additionalProperties: Bool? = nil,
        enumValues: [String]? = nil
    ) {
        self.type = type
        self.properties = properties
        self.items = items
        self.required = required
        self.additionalProperties = additionalProperties
        self.enumValues = enumValues
    }

    enum CodingKeys: String, CodingKey {
        case type
        case properties
        case items
        case required
        case additionalProperties
        case enumValues = "enum"
    }
}

struct OpenAIResponsesResponse: Decodable {
    var model: String?
    var output: [OutputItem]

    var outputText: String? {
        output
            .flatMap(\.content)
            .compactMap(\.text)
            .joined()
            .nilIfBlank
    }
}

struct OutputItem: Decodable {
    var content: [OutputContent]
}

struct OutputContent: Decodable {
    var text: String?
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
