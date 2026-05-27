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
    case cloudDisabled
    case cloudAPIKeyMissing
    case invalidCloudEndpoint
    case cloudResponseInvalid

    var errorDescription: String? {
        switch self {
        case .emptyIdea:
            return "Add a little more to the note before asking for suggestions."
        case .localModelUnavailable(let modelName):
            return "AI assistant unavailable. Add the local \(modelName) model before brainstorming."
        case .cloudDisabled:
            return "Cloud brainstorming is turned off."
        case .cloudAPIKeyMissing:
            return "Cloud brainstorming needs an OpenAI API key before it can run."
        case .invalidCloudEndpoint:
            return "Cloud brainstorming is not configured yet."
        case .cloudResponseInvalid:
            return "The cloud response could not be read."
        }
    }
}

protocol IdeaSuggestionProviding {
    var modelName: String { get }
    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult
}

final class IdeaAssistantService {
    private let localProvider: IdeaSuggestionProviding
    private let cloudProvider: IdeaSuggestionProviding

    init(
        localProvider: IdeaSuggestionProviding = LlamaCppLocalIdeaProvider(),
        cloudProvider: IdeaSuggestionProviding = BrainBotCloudIdeaProvider()
    ) {
        self.localProvider = localProvider
        self.cloudProvider = cloudProvider
    }

    func generateSuggestions(
        for request: IdeaAssistanceRequest,
        allowsCloudEscalation: Bool = false
    ) async throws -> IdeaAssistanceResult {
        guard request.isReady else { throw IdeaAssistantError.emptyIdea }

        do {
            let result = try await localProvider.suggestions(for: request)
            if Self.passesQualityGate(result) {
                return result
            }
        } catch IdeaAssistantError.emptyIdea {
            throw IdeaAssistantError.emptyIdea
        } catch {
            // Local model unavailable or produced bad JSON — fall through to heuristic
        }

        // Heuristic fallback: always works, instant
        return try await HeuristicIdeaProvider().suggestions(for: request)
    }

    static func passesQualityGate(_ result: IdeaAssistanceResult) -> Bool {
        guard result.suggestions.count == 3 else { return false }

        let texts = result.suggestions.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard texts.allSatisfy({ !$0.isEmpty && $0.count <= 180 }) else { return false }

        let uniqueTexts = Set(texts.map { $0.lowercased() })
        return uniqueTexts.count == texts.count
    }
}

struct BrainstormPromptBuilder {
    func prompt(for request: IdeaAssistanceRequest) -> String {
        """
        <|im_start|>system
        You are BrainBot, a concise idea-expansion partner.
        Never dismiss, cap, or limit an idea because it sounds weird, impractical, too early, too ambitious, or unlikely.
        Treat unusual ideas as raw material. Challenge the user to grow and flesh out the idea with sharper questions, possible versions, experiments, and a smallest next step.
        Return valid JSON only. Do not include markdown, commentary, explanations, code fences, or thinking text.
        <|im_end|>
        <|im_start|>user
        /no_think
        Read this note and return exactly 3 helpful thought-starters.

        Rules:
        - Use this exact JSON shape: {"suggestions":[{"type":"question","text":"..."},{"type":"pathway","text":"..."},{"type":"assumption","text":"..."}]}
        - Allowed type values: question, pathway, assumption.
        - Keep every text under 24 words.
        - Make every text specific to the note.
        - Do not write the idea for me.
        - Do not add keys beyond type and text.

        Assistance level: \(request.assistanceLevel.rawValue)
        Title: \(request.trimmedTitle)
        Note: \(request.trimmedBody)
        <|im_end|>
        <|im_start|>assistant
        """
    }
}
