//
//  Ideas.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

import Foundation
internal import SwiftUI

struct Idea: Identifiable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var category: IdeaCategory
    var visualStyle: IdeaVisualStyle
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        category: IdeaCategory,
        visualStyle: IdeaVisualStyle,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.visualStyle = visualStyle
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum IdeaCategory: String, CaseIterable, Identifiable {
    case quickWin = "Quick Win"
    case longTerm = "Long Term"
    case creatorMode = "Creator Mode"
    case experiment = "Experiment"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .quickWin: return "bolt.fill"
        case .longTerm: return "clock.fill"
        case .creatorMode: return "paintpalette.fill"
        case .experiment: return "flask.fill"
        }
    }
}

enum IdeaVisualStyle: String, CaseIterable, Identifiable {
    case mist = "Mist"
    case sage = "Sage"
    case paper = "Paper"
    case night = "Night"

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .mist: return Color(red: 0.92, green: 0.96, blue: 0.95)
        case .sage: return Color(red: 0.84, green: 0.91, blue: 0.89)
        case .paper: return Color.white
        case .night: return Color.midnightGreen.opacity(0.14)
        }
    }
}
