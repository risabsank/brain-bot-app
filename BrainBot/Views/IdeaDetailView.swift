//
//  Idea.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

struct IdeaDetailView: View {
    @EnvironmentObject private var store: IdeaStore
    @State private var title: String
    @State private var bodyText: String
    @State private var category: IdeaCategory
    @State private var style: IdeaVisualStyle

    private let idea: Idea

    init(idea: Idea) {
        self.idea = idea
        _title = State(initialValue: idea.title)
        _bodyText = State(initialValue: idea.body)
        _category = State(initialValue: idea.category)
        _style = State(initialValue: idea.visualStyle)
    }

    var body: some View {
        Form {
            Section("Title") {
                TextField("Idea title", text: $title)
            }

            Section("Details") {
                TextEditor(text: $bodyText)
                    .frame(minHeight: 140)
            }

            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(IdeaCategory.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Card Style") {
                Picker("Style", selection: $style) {
                    ForEach(IdeaVisualStyle.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.menu)
            }

            Button("Save Changes") {
                store.updateIdea(idea, title: title, body: bodyText, category: category, style: style)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Edit Idea")
    }
}
