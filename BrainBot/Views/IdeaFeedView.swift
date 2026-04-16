//
//  IdeaFeedView.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

struct IdeaFeedView: View {
    @EnvironmentObject private var store: IdeaStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    topChips

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.filteredIdeas) { idea in
                            NavigationLink(value: idea) {
                                IdeaCardView(idea: idea)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .background(Color.cloud)
            .searchable(text: $store.searchText, prompt: "Search ideas")
            .navigationTitle("Your Ideas")
            .navigationDestination(for: Idea.self) { idea in
                IdeaDetailView(idea: idea)
            }
        }
    }

    private var topChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("For you", highlighted: true)
                chip("Quick wins")
                chip("Experiments")
                chip("Creator")
            }
        }
    }

    private func chip(_ text: String, highlighted: Bool = false) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(highlighted ? .white : Color.midnightGreen)
            .background(highlighted ? Color.midnightGreen : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.midnightGreen.opacity(0.15), lineWidth: highlighted ? 0 : 1)
            )
    }
}

private struct IdeaCardView: View {
    let idea: Idea

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(idea.category.rawValue, systemImage: idea.category.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.midnightGreen)

            Text(idea.title)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)

            Text(idea.body)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(idea.visualStyle.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
