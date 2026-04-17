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
    @State private var selectedAssistanceLevel: IdeaAssistanceLevel = .standard
    @State private var isGeneratingSuggestions = false
    @State private var generationError: String?
    @State private var showsGenerationError = false

    private let idea: Idea
    private let assistantService = IdeaAssistantService()

    init(idea: Idea) {
        self.idea = idea
        _title = State(initialValue: idea.title)
        _bodyText = State(initialValue: idea.body)
        _category = State(initialValue: idea.category)
        _style = State(initialValue: idea.visualStyle)
    }

    private var autosaveKey: String {
        [
            title,
            bodyText,
            category.rawValue,
            style.rawValue
        ].joined(separator: "|")
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

            Section("Brainstorm") {
                Picker("Help level", selection: $selectedAssistanceLevel) {
                    ForEach(IdeaAssistanceLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }

                Button {
                    Task { await generateSuggestions() }
                } label: {
                    Label(
                        isGeneratingSuggestions ? "Thinking..." : "Brain Button",
                        systemImage: "brain.head.profile"
                    )
                }
                .disabled(isGeneratingSuggestions || !IdeaAssistanceRequest(
                    title: title,
                    body: bodyText,
                    assistanceLevel: selectedAssistanceLevel
                ).isReady)

                if let generationError {
                    Text(generationError)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                AssistanceResultsView(results: store.idea(withID: idea.id)?.assistanceResults ?? [])
            }

            Section {
                Button("Save Now") {
                    autosave()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } footer: {
                Text("Changes autosave while you type.")
            }
        }
        .navigationTitle("Edit Idea")
        .alert("AI Assistant Unavailable", isPresented: $showsGenerationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(generationError ?? "The local AI model is not ready yet.")
        }
        .task(id: autosaveKey) {
            try? await Task.sleep(for: .milliseconds(700))
            await MainActor.run {
                autosave()
            }
        }
        .onDisappear {
            autosave()
        }
    }

    private func autosave() {
        store.updateIdea(idea, title: title, body: bodyText, category: category, style: style)
    }

    private func generateSuggestions() async {
        await MainActor.run {
            isGeneratingSuggestions = true
            generationError = nil
            autosave()
        }

        do {
            let result = try await assistantService.generateSuggestions(
                for: IdeaAssistanceRequest(
                    title: title,
                    body: bodyText,
                    assistanceLevel: selectedAssistanceLevel
                )
            )

            await MainActor.run {
                store.addAssistanceResult(result, to: idea.id)
                isGeneratingSuggestions = false
            }
        } catch {
            await MainActor.run {
                generationError = error.localizedDescription
                showsGenerationError = true
                isGeneratingSuggestions = false
            }
        }
    }
}
