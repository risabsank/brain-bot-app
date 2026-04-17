//
//  AssistanceResultsView.swift
//  BrainBot
//
//  Created by Codex on 4/17/26.
//

internal import SwiftUI

struct AssistanceResultsView: View {
    let results: [IdeaAssistanceResult]

    var body: some View {
        if results.isEmpty {
            Text("Tap the brain button when you want someone to bounce the idea back at you.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } else {
            ForEach(results.prefix(3)) { result in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(result.source.label)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.midnightGreen.opacity(0.12))
                            .foregroundStyle(Color.midnightGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        Text(result.modelName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(result.createdAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(result.suggestions) { suggestion in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(label(for: suggestion.kind))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.midnightGreen)

                            Text(suggestion.text)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    private func label(for kind: IdeaSuggestionKind) -> String {
        switch kind {
        case .question: return "Question"
        case .pathway: return "Pathway"
        case .assumption: return "Assumption"
        }
    }
}
