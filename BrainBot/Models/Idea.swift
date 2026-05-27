//
//  Ideas.swift
//  BrainBot

import Foundation
internal import SwiftUI

struct Idea: Identifiable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var category: IdeaCategory
    var visualStyle: IdeaVisualStyle
    var assistanceResults: [IdeaAssistanceResult]
    var audioRecordingURL: URL?
    var transcript: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        category: IdeaCategory,
        visualStyle: IdeaVisualStyle,
        assistanceResults: [IdeaAssistanceResult] = [],
        audioRecordingURL: URL? = nil,
        transcript: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.visualStyle = visualStyle
        self.assistanceResults = assistanceResults
        self.audioRecordingURL = audioRecordingURL
        self.transcript = transcript
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var growthLevel: Int {
        min(3, assistanceResults.count + 1)
    }
}

enum IdeaCategory: String, CaseIterable, Identifiable {
    case quickWin    = "Quick Win"
    case longTerm    = "Long Term"
    case creatorMode = "Creator Mode"
    case experiment  = "Experiment"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .quickWin:    return "bolt.fill"
        case .longTerm:    return "clock.fill"
        case .creatorMode: return "paintpalette.fill"
        case .experiment:  return "flask.fill"
        }
    }

    var emoji: String {
        switch self {
        case .quickWin:    return "⚡"
        case .longTerm:    return "🌳"
        case .creatorMode: return "🎨"
        case .experiment:  return "🧪"
        }
    }
}

enum IdeaVisualStyle: String, CaseIterable, Identifiable {
    case mist  = "Mist"
    case sage  = "Sage"
    case paper = "Paper"
    case night = "Night"

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .mist:  return Color(hex: "D5ECE3")
        case .sage:  return Color(hex: "B8DAB7")
        case .paper: return Color(hex: "FBF1D9")
        case .night: return Color(hex: "2A4438")
        }
    }

    var foregroundColor: Color {
        switch self {
        case .mist:  return Color(hex: "0B3A2A")
        case .sage:  return Color(hex: "173B17")
        case .paper: return Color(hex: "5A3E0A")
        case .night: return Color(hex: "E6F0E5")
        }
    }

    var ringColor: Color {
        switch self {
        case .mist:  return Color(hex: "A4D3C0")
        case .sage:  return Color(hex: "7BB47A")
        case .paper: return Color(hex: "E0CE9C")
        case .night: return Color(hex: "4F7C68")
        }
    }

    var isNight: Bool { self == .night }
}
