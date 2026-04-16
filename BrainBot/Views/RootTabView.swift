//
//  RootTabView.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            IdeaFeedView()
                .tabItem {
                    Label("Ideas", systemImage: "lightbulb.max.fill")
                }

            CaptureIdeaView()
                .tabItem {
                    Label("Capture", systemImage: "plus.circle.fill")
                }

            DailyChallengeView()
                .tabItem {
                    Label("Daily", systemImage: "target")
                }
        }
        .tint(.midnightGreen)
    }
}
