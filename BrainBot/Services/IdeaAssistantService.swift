//
//  IdeaAssistantService.swift
//  BrainBot
//
//  Created by Codex on 4/17/26.
//

import Foundation

enum IdeaAssistantError: LocalizedError, Equatable {
    case emptyIdea
    case localModelUnavailable(String)
    case poorQualityOutput

    var errorDescription: String? {
        switch self {
        case .emptyIdea:
            return "Add a little more to the note before asking for suggestions."
        case .localModelUnavailable(let modelName):
            return "Add the local \(modelName) model file to enable AI pathways."
        case .poorQualityOutput:
            return "The AI produced an unexpected response. Try again."
        }
    }
}

protocol IdeaSuggestionProviding {
    var modelName: String { get }
    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult
}

final class IdeaAssistantService {
    private let localProvider: IdeaSuggestionProviding

    init(localProvider: IdeaSuggestionProviding = LlamaCppLocalIdeaProvider()) {
        self.localProvider = localProvider
    }

    func generateSuggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        guard request.isReady else { throw IdeaAssistantError.emptyIdea }
        let result = try await localProvider.suggestions(for: request)
        guard Self.passesQualityGate(result) else { throw IdeaAssistantError.poorQualityOutput }
        return result
    }

    static func passesQualityGate(_ result: IdeaAssistanceResult) -> Bool {
        guard result.suggestions.count == 3 else { return false }
        let texts = result.suggestions.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard texts.allSatisfy({ !$0.isEmpty && $0.count <= 180 }) else { return false }
        return Set(texts.map { $0.lowercased() }).count == texts.count
    }
}

struct BrainstormPromptBuilder {
    func prompt(for request: IdeaAssistanceRequest) -> String {
        """
        <|im_start|>system
        You are BrainBot. Output ONLY a JSON object. No thinking, no <think> tags, no explanation, no markdown.
        <|im_end|>
        <|im_start|>user
        /no_think
        Return exactly 3 thought-starters for the idea below.
        JSON shape: {"suggestions":[{"type":"question","text":"..."},{"type":"pathway","text":"..."},{"type":"assumption","text":"..."}]}
        Rules: type is question/pathway/assumption. Each text is under 20 words and specific to the idea.
        Title: \(request.trimmedTitle)
        Note: \(request.trimmedBody.prefix(300))
        <|im_end|>
        <|im_start|>assistant
        {"suggestions":[
        """
    }
}
