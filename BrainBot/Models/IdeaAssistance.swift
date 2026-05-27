//
//  IdeaAssistance.swift
//  BrainBot
//
//  Created by Codex on 4/17/26.
//

import Foundation

enum IdeaAssistanceLevel: String, CaseIterable, Identifiable, Codable, Hashable {
    case minimal = "Minimal"
    case standard = "Standard"
    case moreHelp = "More Help"

    var id: String { rawValue }

    var suggestionCount: Int {
        switch self {
        case .minimal: return 3
        case .standard: return 3
        case .moreHelp: return 3
        }
    }
}

enum IdeaSuggestionKind: String, CaseIterable, Codable, Hashable {
    case question
    case pathway
    case assumption
}

enum IdeaAssistanceSource: String, Codable, Hashable {
    case local
    case cloud

    var label: String {
        switch self {
        case .local: return "Local"
        case .cloud: return "Cloud"
        }
    }
}

struct IdeaSuggestion: Identifiable, Codable, Hashable {
    let id: UUID
    var kind: IdeaSuggestionKind
    var text: String

    init(id: UUID = UUID(), kind: IdeaSuggestionKind, text: String) {
        self.id = id
        self.kind = kind
        self.text = text
    }
}

struct IdeaAssistanceResult: Identifiable, Codable, Hashable {
    let id: UUID
    var suggestions: [IdeaSuggestion]
    var source: IdeaAssistanceSource
    var assistanceLevel: IdeaAssistanceLevel
    var modelName: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        suggestions: [IdeaSuggestion],
        source: IdeaAssistanceSource,
        assistanceLevel: IdeaAssistanceLevel,
        modelName: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.suggestions = suggestions
        self.source = source
        self.assistanceLevel = assistanceLevel
        self.modelName = modelName
        self.createdAt = createdAt
    }
}

struct IdeaAssistanceRequest: Hashable {
    var title: String
    var body: String
    var assistanceLevel: IdeaAssistanceLevel

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isReady: Bool {
        !trimmedBody.isEmpty || !trimmedTitle.isEmpty
    }
}
