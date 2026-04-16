//
//  IdeaStore.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

import Foundation
import Combine
internal import SwiftUI

final class IdeaStore: ObservableObject {
    @Published var ideas: [Idea] = IdeaStore.sampleIdeas
    @Published var searchText: String = ""
    @Published var dailyEntries: [String] = []

    var filteredIdeas: [Idea] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ideas
        }

        let query = searchText.lowercased()
        return ideas.filter {
            $0.title.lowercased().contains(query) || $0.body.lowercased().contains(query)
        }
    }

    func addIdea(title: String, body: String, category: IdeaCategory, style: IdeaVisualStyle) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty, !cleanBody.isEmpty else { return }

        let idea = Idea(
            title: cleanTitle,
            body: cleanBody,
            category: category,
            visualStyle: style
        )
        ideas.insert(idea, at: 0)
    }

    func updateIdea(_ idea: Idea, title: String, body: String, category: IdeaCategory, style: IdeaVisualStyle) {
        guard let index = ideas.firstIndex(where: { $0.id == idea.id }) else { return }
        ideas[index].title = title
        ideas[index].body = body
        ideas[index].category = category
        ideas[index].visualStyle = style
        ideas[index].updatedAt = .now
    }

    func deleteIdeas(at offsets: IndexSet) {
        ideas.remove(atOffsets: offsets)
    }

    func saveChallengeEntry(_ value: String) {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanValue.isEmpty else { return }
        dailyEntries.append(cleanValue)
    }

    private static let sampleIdeas: [Idea] = [
        Idea(
            title: "Podcast hook ideas",
            body: "Open each episode with a 20-second true story before the lesson.",
            category: .creatorMode,
            visualStyle: .mist
        ),
        Idea(
            title: "Weekend pop-up cart",
            body: "Test a one-day iced tea cart near the bike trail and track repeat buyers.",
            category: .experiment,
            visualStyle: .sage
        ),
        Idea(
            title: "Fitness challenge mini-app",
            body: "7-day bodyweight challenge with daily check-ins and buddy invites.",
            category: .longTerm,
            visualStyle: .paper
        ),
        Idea(
            title: "Newsletter growth",
            body: "Offer one practical template every Friday to increase referrals.",
            category: .quickWin,
            visualStyle: .night
        )
    ]
}
