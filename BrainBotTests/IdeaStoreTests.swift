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

    func testAddIdeaCanSaveAudioOnlyIdea() {
        let store = IdeaStore()
        let url = URL(fileURLWithPath: "/tmp/idea.m4a")

        store.addIdea(title: "Voice idea", body: "", category: .quickWin, style: .mist, audioRecordingURL: url)

        XCTAssertEqual(store.ideas.first?.audioRecordingURL, url)
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

    func testAutosaveCanAttachAudioAndTranscript() {
        let store = IdeaStore()
        let url = URL(fileURLWithPath: "/tmp/idea.m4a")

        let draftID = store.autosaveIdea(
            id: nil,
            title: "Voice idea",
            body: "",
            category: .experiment,
            style: .sage,
            audioRecordingURL: url,
            transcript: "A floating cafe for impossible conversations."
        )

        let idea = store.idea(withID: draftID!)
        XCTAssertEqual(idea?.audioRecordingURL, url)
        XCTAssertEqual(idea?.transcript, "A floating cafe for impossible conversations.")
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
