//
//  CaptureIdeaView.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

struct CaptureIdeaView: View {
    @EnvironmentObject private var store: IdeaStore
    @State private var title = ""
    @State private var ideaText = ""
    @State private var selectedCategory: IdeaCategory = .quickWin
    @State private var selectedStyle: IdeaVisualStyle = .mist

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Capture") {
                    TextField("Title", text: $title)
                    TextField("What is your idea?", text: $ideaText, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Voice Input") {
                    Label("Voice-to-text will be connected with Apple Speech in next iteration.", systemImage: "mic.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(IdeaCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("Visual Style") {
                    Picker("Style", selection: $selectedStyle) {
                        ForEach(IdeaVisualStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button("Save Idea") {
                    store.addIdea(title: title, body: ideaText, category: selectedCategory, style: selectedStyle)
                    title = ""
                    ideaText = ""
                }
                .buttonStyle(.borderedProminent)
                .tint(.midnightGreen)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Capture")
        }
    }
}
