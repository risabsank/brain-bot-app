//
//  AssistanceResultsView.swift
//  BrainBot

internal import SwiftUI

struct AssistanceResultsView: View {
    let results: [IdeaAssistanceResult]

    var body: some View {
        if results.isEmpty {
            Text("Tap the button when you want someone to bounce the idea back at you.")
                .font(.system(size: 13))
                .foregroundStyle(Color.gardenInk3)
        } else {
            ForEach(results.prefix(3)) { result in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text(result.source.label)
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.mossSoft)
                            .foregroundStyle(Color.mossDark)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                        Text(result.modelName)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gardenInk3)

                        Spacer()

                        Text(result.createdAt, style: .time)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gardenInk3)
                    }

                    ForEach(result.suggestions) { suggestion in
                        VStack(alignment: .leading, spacing: 4) {
                            SuggestionBadgeView(kind: suggestion.kind)
                            Text(suggestion.text)
                                .font(.system(size: 13.5))
                                .foregroundStyle(Color.gardenInk)
                                .lineSpacing(1.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
}
