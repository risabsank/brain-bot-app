//
//  IdeaStoreTests.swift
//  BrainBot
//
//  Created by Banupriya Natarajan on 4/15/26.
//

import XCTest
@testable import BrainBot

final class IdeaStoreTests: XCTestCase {
    func testSearchReturnsMatchingItems() {
        let store = IdeaStore()
        store.searchText = "newsletter"

        XCTAssertEqual(store.filteredIdeas.count, 1)
        XCTAssertEqual(store.filteredIdeas.first?.title, "Newsletter growth")
    }

    func testAddIdeaIgnoresBlankData() {
        let store = IdeaStore()
        let initial = store.ideas.count

        store.addIdea(title: "  ", body: "", category: .quickWin, style: .mist)

        XCTAssertEqual(store.ideas.count, initial)
    }

    func testAutosaveCreatesAndUpdatesDraftIdea() {
        let store = IdeaStore()
        let initial = store.ideas.count

        let draftID = store.autosaveIdea(
            id: nil,
            title: "",
            body: "A pocket notebook that nudges unfinished thoughts",
            category: .experiment,
            style: .sage
        )

        XCTAssertNotNil(draftID)
        XCTAssertEqual(store.ideas.count, initial + 1)
        XCTAssertEqual(store.idea(withID: draftID!)?.title, "Untitled idea")

        let updatedID = store.autosaveIdea(
            id: draftID,
            title: "Pocket thinking coach",
            body: "A pocket notebook that nudges unfinished thoughts",
            category: .creatorMode,
            style: .night
        )

        XCTAssertEqual(updatedID, draftID)
        XCTAssertEqual(store.ideas.count, initial + 1)
        XCTAssertEqual(store.idea(withID: draftID!)?.title, "Pocket thinking coach")
        XCTAssertEqual(store.idea(withID: draftID!)?.category, .creatorMode)
    }

    func testAssistanceResultsAreStoredNewestFirst() {
        let store = IdeaStore()
        let ideaID = store.ideas[0].id
        let first = IdeaAssistanceResult(
            suggestions: [IdeaSuggestion(kind: .question, text: "First?")],
            source: .localFallback,
            assistanceLevel: .minimal,
            modelName: "test"
        )
        let second = IdeaAssistanceResult(
            suggestions: [IdeaSuggestion(kind: .question, text: "Second?")],
            source: .cloud,
            assistanceLevel: .standard,
            modelName: "test"
        )

        store.addAssistanceResult(first, to: ideaID)
        store.addAssistanceResult(second, to: ideaID)

        XCTAssertEqual(store.idea(withID: ideaID)?.assistanceResults.first, second)
    }
}
