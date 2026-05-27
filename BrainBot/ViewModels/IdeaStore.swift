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
    @Published var ideas: [Idea] = []
    @Published var searchText: String = ""
    @Published var dailyEntries: [String] = []

    // Gamification
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var streak: Int = 0
    @Published var sproutsToday: Int = 0

    func grantXP(_ amount: Int) {
        xp += amount
        sproutsToday += 1
        while xp >= 100 { xp -= 100; level += 1 }
    }

    var filteredIdeas: [Idea] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ideas
        }

        let query = searchText.lowercased()
        return ideas.filter {
            $0.title.lowercased().contains(query) || $0.body.lowercased().contains(query)
        }
    }

    var currentWeekContributionDays: [Date: Int] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: .now)
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: todayStart) else {
            return [:]
        }

        var counts: [Date: Int] = [:]
        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: weekStart) {
                counts[day] = 0
            }
        }

        for idea in ideas {
            let day = calendar.startOfDay(for: idea.createdAt)
            guard day >= weekStart, day <= todayStart else { continue }
            counts[day, default: 0] += 1
        }

        return counts
    }

    var currentWeekContributionTotal: Int {
        currentWeekContributionDays.values.reduce(0, +)
    }

    func addIdea(
        title: String,
        body: String,
        category: IdeaCategory,
        style: IdeaVisualStyle,
        audioRecordingURL: URL? = nil,
        transcript: String? = nil
    ) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTranscript = transcript?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty, !cleanBody.isEmpty || audioRecordingURL != nil else { return }

        let idea = Idea(
            title: cleanTitle,
            body: cleanBody,
            category: category,
            visualStyle: style,
            audioRecordingURL: audioRecordingURL,
            transcript: cleanTranscript?.isEmpty == false ? cleanTranscript : nil
        )
        ideas.insert(idea, at: 0)
    }

    @discardableResult
    func autosaveIdea(
        id: UUID?,
        title: String,
        body: String,
        category: IdeaCategory,
        style: IdeaVisualStyle,
        audioRecordingURL: URL? = nil,
        transcript: String? = nil
    ) -> UUID? {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTranscript = transcript?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty || !cleanBody.isEmpty || audioRecordingURL != nil else { return id }

        if let id, let index = ideas.firstIndex(where: { $0.id == id }) {
            ideas[index].title = cleanTitle.isEmpty ? "Untitled idea" : cleanTitle
            ideas[index].body = cleanBody
            ideas[index].category = category
            ideas[index].visualStyle = style
            ideas[index].audioRecordingURL = audioRecordingURL ?? ideas[index].audioRecordingURL
            ideas[index].transcript = cleanTranscript?.isEmpty == false ? cleanTranscript : ideas[index].transcript
            ideas[index].updatedAt = .now
            return id
        }

        let idea = Idea(
            id: id ?? UUID(),
            title: cleanTitle.isEmpty ? "Untitled idea" : cleanTitle,
            body: cleanBody,
            category: category,
            visualStyle: style,
            audioRecordingURL: audioRecordingURL,
            transcript: cleanTranscript?.isEmpty == false ? cleanTranscript : nil
        )
        ideas.insert(idea, at: 0)
        return idea.id
    }

    func updateIdea(
        _ idea: Idea,
        title: String,
        body: String,
        category: IdeaCategory,
        style: IdeaVisualStyle,
        audioRecordingURL: URL? = nil,
        transcript: String? = nil
    ) {
        guard let index = ideas.firstIndex(where: { $0.id == idea.id }) else { return }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        ideas[index].title = cleanTitle.isEmpty ? "Untitled idea" : cleanTitle
        ideas[index].body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        ideas[index].category = category
        ideas[index].visualStyle = style
        ideas[index].audioRecordingURL = audioRecordingURL ?? ideas[index].audioRecordingURL
        ideas[index].transcript = transcript ?? ideas[index].transcript
        ideas[index].updatedAt = .now
    }

    func idea(withID id: UUID) -> Idea? {
        ideas.first { $0.id == id }
    }

    func addAssistanceResult(_ result: IdeaAssistanceResult, to ideaID: UUID) {
        guard let index = ideas.firstIndex(where: { $0.id == ideaID }) else { return }
        ideas[index].assistanceResults.insert(result, at: 0)
        ideas[index].updatedAt = .now
    }

    func deleteIdeas(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            ideas.remove(at: index)
        }
    }

    func saveChallengeEntry(_ value: String) {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanValue.isEmpty else { return }
        dailyEntries.append(cleanValue)
    }

}
