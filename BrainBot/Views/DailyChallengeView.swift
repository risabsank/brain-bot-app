//
//  DailyChallengeView.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

struct DailyChallengeView: View {
    @EnvironmentObject private var store: IdeaStore
    @State private var entry = ""
    @State private var progress: Double = 0.35
    private let challenge = AlternateUsesChallenge.today()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Creativity Sprint")
                            .font(.title2.bold())
                            .foregroundStyle(Color.midnightGreen)

                        ProgressView(value: progress)
                            .tint(Color.midnightGreen)

                        Text("Object: \(challenge.object)")
                            .font(.headline)
                        Text(challenge.prompt)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add alternate use")
                            .font(.headline)

                        TextField("Example: Use it as a desk cable organizer", text: $entry)
                            .textFieldStyle(.roundedBorder)

                        Button("Add") {
                            store.saveChallengeEntry(entry)
                            entry = ""
                            progress = min(progress + 0.07, 1)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.midnightGreen)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today’s ideas")
                            .font(.headline)

                        if store.dailyEntries.isEmpty {
                            Text("No entries yet. Aim for 10+ uses.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(store.dailyEntries.enumerated()), id: \.offset) { index, item in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(index + 1).")
                                        .foregroundStyle(Color.midnightGreen)
                                        .fontWeight(.semibold)
                                    Text(item)
                                }
                            }
                        }
                    }
                    .cardStyle()
                }
                .padding()
            }
            .background(Color.cloud)
            .navigationTitle("Daily")
        }
    }
}
