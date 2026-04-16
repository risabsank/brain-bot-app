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
}
