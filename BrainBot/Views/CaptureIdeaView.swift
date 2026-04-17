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
    @State private var selectedAssistanceLevel: IdeaAssistanceLevel = .standard
    @State private var draftIdeaID: UUID?
    @State private var isGeneratingSuggestions = false
    @State private var generationError: String?
    @State private var showsGenerationError = false

    private let assistantService = IdeaAssistantService()

    private var autosaveKey: String {
        [
            title,
            ideaText,
            selectedCategory.rawValue,
            selectedStyle.rawValue
        ].joined(separator: "|")
    }

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
                        body: ideaText,
                        assistanceLevel: selectedAssistanceLevel
                    ).isReady)

                    if let generationError {
                        Text(generationError)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if let draftIdeaID, let idea = store.idea(withID: draftIdeaID) {
                        AssistanceResultsView(results: idea.assistanceResults)
                    }
                }

                Section {
                    Button("Start a Fresh Note") {
                        title = ""
                        ideaText = ""
                        selectedCategory = .quickWin
                        selectedStyle = .mist
                        draftIdeaID = nil
                        generationError = nil
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } footer: {
                    Text("Notes autosave while you type.")
                }
            }
            .navigationTitle("Capture")
            .alert("AI Assistant Unavailable", isPresented: $showsGenerationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(generationError ?? "The local AI model is not ready yet.")
            }
            .task(id: autosaveKey) {
                try? await Task.sleep(for: .milliseconds(700))
                await MainActor.run {
                    draftIdeaID = store.autosaveIdea(
                        id: draftIdeaID,
                        title: title,
                        body: ideaText,
                        category: selectedCategory,
                        style: selectedStyle
                    )
                }
            }
        }
    }

    private func generateSuggestions() async {
        await MainActor.run {
            isGeneratingSuggestions = true
            generationError = nil
            draftIdeaID = store.autosaveIdea(
                id: draftIdeaID,
                title: title,
                body: ideaText,
                category: selectedCategory,
                style: selectedStyle
            )
        }

        do {
            let result = try await assistantService.generateSuggestions(
                for: IdeaAssistanceRequest(
                    title: title,
                    body: ideaText,
                    assistanceLevel: selectedAssistanceLevel
                )
            )

            await MainActor.run {
                if let draftIdeaID {
                    store.addAssistanceResult(result, to: draftIdeaID)
                }
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
