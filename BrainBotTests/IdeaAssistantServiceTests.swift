//
//  IdeaAssistantServiceTests.swift
//  BrainBotTests
//
//  Created by Codex on 4/17/26.
//

import XCTest
@testable import BrainBot

@MainActor
final class IdeaAssistantServiceTests: XCTestCase {
    func testQualityGateRequiresExactlyThreeUniqueSuggestions() {
        let valid = IdeaAssistanceResult(
            suggestions: [
                IdeaSuggestion(kind: .question, text: "What is the fastest way to test this?"),
                IdeaSuggestion(kind: .pathway, text: "Try it with one specific audience first."),
                IdeaSuggestion(kind: .assumption, text: "Check whether people want the reminder.")
            ],
            source: .localFallback,
            assistanceLevel: .standard,
            modelName: "test"
        )

        XCTAssertTrue(IdeaAssistantService.passesQualityGate(valid))

        let duplicate = IdeaAssistanceResult(
            suggestions: [
                IdeaSuggestion(kind: .question, text: "What is the fastest way to test this?"),
                IdeaSuggestion(kind: .pathway, text: "What is the fastest way to test this?"),
                IdeaSuggestion(kind: .assumption, text: "Check whether people want the reminder.")
            ],
            source: .localFallback,
            assistanceLevel: .standard,
            modelName: "test"
        )

        XCTAssertFalse(IdeaAssistantService.passesQualityGate(duplicate))
    }

    func testUnavailableLocalModelDoesNotReturnFallbackSuggestions() async {
        let service = IdeaAssistantService(
            localProvider: UnavailableProvider(),
            cloudProvider: SuccessfulProvider()
        )

        do {
            _ = try await service.generateSuggestions(for: IdeaAssistanceRequest(
                title: "Tiny habit app",
                body: "A lightweight app for building tiny habits with a friend.",
                assistanceLevel: .standard
            ))
            XCTFail("Expected local model unavailable error.")
        } catch IdeaAssistantError.localModelUnavailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCloudEscalationIsOffByDefaultForLowQualityLocalOutput() async {
        let service = IdeaAssistantService(
            localProvider: LowQualityProvider(),
            cloudProvider: SuccessfulProvider()
        )

        do {
            _ = try await service.generateSuggestions(for: IdeaAssistanceRequest(
                title: "Tiny habit app",
                body: "A lightweight app for building tiny habits with a friend.",
                assistanceLevel: .standard
            ))
            XCTFail("Expected low-quality local output to stop without cloud escalation.")
        } catch IdeaAssistantError.cloudResponseInvalid {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLocalProviderCanDecodeJSONSuggestions() throws {
        let suggestions = try LlamaCppLocalIdeaProvider.decodeSuggestions(from: """
        {
          "suggestions": [
            { "type": "question", "text": "Who needs this first?" },
            { "type": "pathway", "text": "Test one reminder flow." },
            { "type": "assumption", "text": "Check whether friends want shared nudges." }
          ]
        }
        """)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions[2].kind, .assumption)
    }

    func testLocalProviderCanDecodeMarkdownWrappedKindSuggestions() throws {
        let suggestions = try LlamaCppLocalIdeaProvider.decodeSuggestions(from: """
        ```json
        {
          "suggestions": [
            { "kind": "question", "text": "Who needs this first?" },
            { "kind": "pathway", "text": "Test one reminder flow." },
            { "kind": "assumption", "text": "Check whether friends want shared nudges." }
          ]
        }
        ```
        """)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions[0].kind, .question)
    }

    func testLocalProviderCanDecodeDirectSuggestionArray() throws {
        let suggestions = try LlamaCppLocalIdeaProvider.decodeSuggestions(from: """
        [
          { "type": "question", "text": "Who needs this first?" },
          { "type": "pathway", "text": "Test one reminder flow." },
          { "type": "assumption", "text": "Check whether friends want shared nudges." }
        ]
        """)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions[1].kind, .pathway)
    }

    func testOpenAICloudProviderIsDisabledByDefault() async {
        let provider = BrainBotCloudIdeaProvider(configuration: BrainBotCloudConfiguration())

        do {
            _ = try await provider.suggestions(for: IdeaAssistanceRequest(
                title: "Tiny habit app",
                body: "A lightweight app for building tiny habits with a friend.",
                assistanceLevel: .standard
            ))
            XCTFail("Expected disabled cloud provider to throw.")
        } catch IdeaAssistantError.cloudDisabled {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPromptDoesNotLimitWeirdIdeas() {
        let prompt = BrainstormPromptBuilder().prompt(for: IdeaAssistanceRequest(
            title: "Moon cafe",
            body: "A cafe on the moon for impossible conversations.",
            assistanceLevel: .standard
        ))

        XCTAssertTrue(prompt.contains("Never dismiss, cap, or limit"))
        XCTAssertTrue(prompt.contains("weird"))
        XCTAssertTrue(prompt.contains("smallest next step"))
    }

    func testOpenAICloudProviderCanDecodeResponsesOutput() throws {
        let response = OpenAIResponsesResponse(
            model: "gpt-4.1-mini",
            output: [
                OutputItem(content: [
                    OutputContent(text: """
                    {
                      "suggestions": [
                        { "type": "question", "text": "Who needs this first?" },
                        { "type": "pathway", "text": "Test one reminder flow." },
                        { "type": "assumption", "text": "Check whether friends want shared nudges." }
                      ]
                    }
                    """)
                ])
            ]
        )

        let suggestions = try BrainBotCloudIdeaProvider.decodeSuggestions(from: response)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions[0].kind, .question)
    }
}

private struct UnavailableProvider: IdeaSuggestionProviding {
    var modelName: String { "test-local" }

    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        throw IdeaAssistantError.localModelUnavailable(modelName)
    }
}

private struct SuccessfulProvider: IdeaSuggestionProviding {
    var modelName: String { "test-cloud" }

    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        IdeaAssistanceResult(
            suggestions: [
                IdeaSuggestion(kind: .question, text: "Who needs this first?"),
                IdeaSuggestion(kind: .pathway, text: "Try one tiny experiment."),
                IdeaSuggestion(kind: .assumption, text: "Check demand before building.")
            ],
            source: .cloud,
            assistanceLevel: request.assistanceLevel,
            modelName: modelName
        )
    }
}

private struct LowQualityProvider: IdeaSuggestionProviding {
    var modelName: String { "test-low-quality-local" }

    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        IdeaAssistanceResult(
            suggestions: [
                IdeaSuggestion(kind: .question, text: "Too few.")
            ],
            source: .local,
            assistanceLevel: request.assistanceLevel,
            modelName: modelName
        )
    }
}
