//
//  BrainBotApp.swift
//  BrainBot
//
//  Created by Banupriya Natarajan on 4/15/26.
//

internal import SwiftUI

@main
struct BrainBotApp: App {
    @StateObject private var ideaStore = IdeaStore()

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(ideaStore)
        }
    }
}
