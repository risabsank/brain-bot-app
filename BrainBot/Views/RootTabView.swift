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

            ActivityTrackerView()
                .tabItem {
                    Label("Activity", systemImage: "calendar")
                }
        }
        .tint(.midnightGreen)
    }
}

private struct ActivityTrackerView: View {
    @EnvironmentObject private var store: IdeaStore

    private var weekDays: [(date: Date, count: Int)] {
        store.currentWeekContributionDays
            .map { (date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Past 7 Days")
                            .font(.title2.bold())
                            .foregroundStyle(Color.midnightGreen)

                        Text("\(store.currentWeekContributionTotal) idea contributions")
                            .font(.headline)

                        Text("Recordings, typed ideas, and saved transcripts all count when an idea is saved.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calendar")
                            .font(.headline)

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(weekDays, id: \.date) { day in
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(color(for: day.count))
                                        .frame(height: height(for: day.count))
                                        .frame(maxHeight: 96, alignment: .bottom)

                                    Text(day.date, format: .dateTime.weekday(.narrow))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.secondary)

                                    Text("\(day.count)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.midnightGreen)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 140)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Contributions")
                            .font(.headline)

                        ForEach(store.ideas.prefix(5)) { idea in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: idea.audioRecordingURL == nil ? "lightbulb.fill" : "waveform")
                                    .foregroundStyle(Color.midnightGreen)
                                    .frame(width: 20)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(idea.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(idea.createdAt, format: .dateTime.weekday().month().day().hour().minute())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .cardStyle()
                }
                .padding()
            }
            .background(Color.cloud)
            .navigationTitle("Activity")
        }
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.18)
        case 1: return Color.midnightGreen.opacity(0.35)
        case 2: return Color.midnightGreen.opacity(0.6)
        default: return Color.midnightGreen
        }
    }

    private func height(for count: Int) -> CGFloat {
        CGFloat(max(18, min(96, 18 + count * 22)))
    }
}
