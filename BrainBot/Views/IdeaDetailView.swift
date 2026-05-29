//
//  IdeaDetailView.swift
//  BrainBot

internal import SwiftUI
import AVFoundation
import Combine

struct IdeaDetailView: View {
    @EnvironmentObject private var store: IdeaStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = IdeaAudioPlayer()

    @State private var tab: DetailTab = .seed
    @State private var title: String
    @State private var bodyText: String
    @State private var category: IdeaCategory
    @State private var style: IdeaVisualStyle
    @State private var transcript: String
    @State private var selectedAssistanceLevel: IdeaAssistanceLevel = .standard
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0
    @State private var estimatedDuration: TimeInterval = 8
    @State private var generationError: String?
    @State private var showsGenerationError = false
    @State private var showBubbleCanvas = false
    @State private var liveMap: BubbleMap = BubbleMap()

    private let idea: Idea
    private let assistantService = IdeaAssistantService()

    enum DetailTab: String, CaseIterable {
        case seed    = "Seed"
        case ai      = "Ask the Garden"
        case styleTab = "Style"
    }

    init(idea: Idea) {
        self.idea = idea
        _title    = State(initialValue: idea.title)
        _bodyText = State(initialValue: idea.body)
        _category = State(initialValue: idea.category)
        _style    = State(initialValue: idea.visualStyle)
        _transcript = State(initialValue: idea.transcript ?? "")
        _liveMap  = State(initialValue: idea.bubbleMap ?? BubbleMap())
    }

    private var autosaveKey: String {
        [title, bodyText, category.rawValue, style.rawValue, transcript].joined(separator: "|")
    }

    var body: some View {
        VStack(spacing: 0) {
            hueHeader
            tabPills
            tabBody
            footer
        }
        .background(Color.gardenSurface2.ignoresSafeArea())
        .fullScreenCover(isPresented: $showBubbleCanvas) {
            NavigationStack {
                IdeaBubbleCanvasView(map: $liveMap, onSave: {
                    store.updateBubbleMap(liveMap, for: idea.id)
                })
                .navigationTitle("Bubble Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") { showBubbleCanvas = false }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.moss)
                    }
                }
            }
        }
        .alert("AI Assistant Unavailable", isPresented: $showsGenerationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(generationError ?? "The local AI model is not ready yet.")
        }
        .task(id: autosaveKey) {
            try? await Task.sleep(for: .milliseconds(700))
            await MainActor.run { autosave() }
        }
        .onDisappear { autosave() }
    }

    // MARK: - Hue header strip

    private var hueHeader: some View {
        ZStack(alignment: .topTrailing) {
            Text(category.emoji)
                .font(.system(size: 50))
                .opacity(0.25)
                .padding([.top, .trailing], 10)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Text(category.emoji)
                        .font(.system(size: 12))
                    Text(category.rawValue)
                        .font(.system(size: 10.5, weight: .heavy))
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.7))
                .foregroundStyle(style.foregroundColor)
                .clipShape(Capsule())

                Text(title.isEmpty ? "Untitled" : title)
                    .font(.display(19))
                    .foregroundStyle(style.foregroundColor)
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .bottomLeading)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .clipped()
    }

    // MARK: - Tab pills

    private var tabPills: some View {
        HStack(spacing: 6) {
            ForEach(DetailTab.allCases, id: \.self) { t in
                Button { withAnimation(.easeOut(duration: 0.15)) { tab = t } } label: {
                    Text(t.rawValue)
                        .font(.system(size: 12.5, weight: .bold))
                        .tracking(-0.1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .foregroundStyle(tab == t ? .white : Color.gardenInk2)
                        .background(tab == t ? Color.moss : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Tab body

    @ViewBuilder
    private var tabBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                switch tab {
                case .seed:    seedTab
                case .ai:      aiTab
                case .styleTab: styleTab
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    // MARK: Seed tab

    private var seedTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Idea title", text: $title)
                .font(.display(17, weight: .semibold))
                .foregroundStyle(Color.gardenInk)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.10), lineWidth: 1)
                )

            ZStack(alignment: .topLeading) {
                TextEditor(text: $bodyText)
                    .font(.system(size: 14.5))
                    .foregroundStyle(Color.gardenInk)
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.10), lineWidth: 1)
                    )
                if bodyText.isEmpty {
                    Text("Notes…")
                        .font(.system(size: 14.5))
                        .foregroundStyle(Color.gardenInk3)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .allowsHitTesting(false)
                }
            }

            if let url = idea.audioRecordingURL {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(audioPlayer.isPlaying ? Color.amber : Color.mossSoft)
                            .frame(width: 40, height: 40)
                        Image(systemName: audioPlayer.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(audioPlayer.isPlaying ? .white : Color.moss)
                    }
                    .shadow(color: audioPlayer.isPlaying ? Color.amber.opacity(0.30) : .clear, radius: 4, y: 2)
                    .animation(.easeOut(duration: 0.2), value: audioPlayer.isPlaying)
                    .onTapGesture { audioPlayer.toggle(url: url) }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Voice recording")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.gardenInk)
                        Text(audioPlayer.isPlaying ? "Playing…" : "Tap to replay")
                            .font(.system(size: 11.5))
                            .foregroundStyle(Color.gardenInk3)
                    }

                    Spacer()

                    if audioPlayer.isPlaying {
                        Image(systemName: "waveform")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.amber)
                            .symbolEffect(.pulse)
                    }
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(audioPlayer.isPlaying ? Color.amber.opacity(0.5) : Color.black.opacity(0.08), lineWidth: 1)
                )
                .animation(.easeOut(duration: 0.2), value: audioPlayer.isPlaying)
            }

            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Voice transcript")
                        .font(.system(size: 11, weight: .heavy))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Color.gardenInk3)
                    TextEditor(text: $transcript)
                        .font(.system(size: 14))
                        .frame(minHeight: 80)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            // Bubble map entry point
            Button {
                if liveMap.nodes.isEmpty, let saved = store.idea(withID: idea.id)?.bubbleMap {
                    liveMap = saved
                }
                showBubbleCanvas = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.moss)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(liveMap.nodes.isEmpty ? "Create Bubble Map" : "Edit Bubble Map")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.gardenInk)
                        Text(liveMap.nodes.isEmpty
                             ? "Visually explore this idea"
                             : "\(liveMap.nodes.count) bubble\(liveMap.nodes.count == 1 ? "" : "s")")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gardenInk3)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.gardenInk3)
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.moss.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Autosave indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.sprout)
                    .frame(width: 6, height: 6)
                Text("Autosaving while you type")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.mossDark)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.mossSoft)
            .clipShape(Capsule())
            .padding(.top, 4)
        }
        .padding(.top, 8)
    }

    // MARK: Ask the Garden tab

    private var aiTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Assistance level picker
            HStack(spacing: 6) {
                ForEach(IdeaAssistanceLevel.allCases) { level in
                    Button { selectedAssistanceLevel = level } label: {
                        Text(level.rawValue)
                            .font(.system(size: 12.5, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .foregroundStyle(selectedAssistanceLevel == level ? Color.moss : Color.gardenInk)
                            .background(
                                selectedAssistanceLevel == level
                                    ? Color.white
                                    : Color.white.opacity(0.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        selectedAssistanceLevel == level ? Color.moss : Color.black.opacity(0.08),
                                        lineWidth: selectedAssistanceLevel == level ? 1.5 : 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Button {
                Task { await generateSuggestions() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                    Text(isGenerating ? "Thinking…" : "Ask the Garden")
                    Spacer()
                    Image(systemName: "sparkles")
                }
            }
            .buttonStyle(GardenButtonStyle(isDisabled: isGenerating))
            .disabled(isGenerating)

            let results = store.idea(withID: idea.id)?.assistanceResults ?? []
            if results.isEmpty && !isGenerating {
                Text("Tap the button to get questions, pathways, and assumptions for this idea.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.gardenInk2)
                    .padding(.vertical, 8)
            }

            if isGenerating {
                VStack(spacing: 6) {
                    ProgressView(value: generationProgress)
                        .tint(Color.moss)
                        .animation(.linear(duration: 0.15), value: generationProgress)
                    let secondsLeft = max(0, Int(ceil(estimatedDuration * (1 - generationProgress))))
                    Text(generationProgress < 0.04 ? "Starting local AI…" : "~\(secondsLeft)s left")
                        .font(.system(size: 11.5))
                        .foregroundStyle(Color.gardenInk3)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical, 6)
            }

            ForEach(results.prefix(3)) { result in
                VStack(alignment: .leading, spacing: 0) {
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
                    .padding(.bottom, 10)

                    ForEach(result.suggestions) { suggestion in
                        VStack(alignment: .leading, spacing: 4) {
                            SuggestionBadgeView(kind: suggestion.kind)
                            Text(suggestion.text)
                                .font(.system(size: 13.5))
                                .foregroundStyle(Color.gardenInk)
                                .lineSpacing(1.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .overlay(
                            Divider()
                                .opacity(0.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        )
                    }
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }

    // MARK: Style tab

    private var styleTab: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Soil type")
                    .font(.system(size: 11, weight: .heavy))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Color.gardenInk3)
                CategoryPickerView(value: $category)
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("Botanical hue")
                    .font(.system(size: 11, weight: .heavy))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Color.gardenInk3)
                HuePickerView(value: $style)
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.5)
            Button {
                autosave()
                store.grantXP(5)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Text("Save & close")
                    Image(systemName: "checkmark")
                }
            }
            .buttonStyle(GardenButtonStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(Color.gardenSurface2)
    }

    // MARK: - Logic

    private func autosave() {
        store.updateIdea(
            idea,
            title: title,
            body: bodyText,
            category: category,
            style: style,
            audioRecordingURL: idea.audioRecordingURL,
            transcript: transcript
        )
    }

    private func generateSuggestions() async {
        let body = transcript.isEmpty ? bodyText : transcript
        isGenerating = true
        generationError = nil
        generationProgress = 0
        let startTime = Date()
        autosave()

        let progressTracking = Task {
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startTime)
                generationProgress = min(0.95, elapsed / estimatedDuration)
                try? await Task.sleep(for: .milliseconds(100))
            }
        }

        do {
            let result = try await assistantService.generateSuggestions(
                for: IdeaAssistanceRequest(title: title, body: body, assistanceLevel: selectedAssistanceLevel)
            )
            let elapsed = Date().timeIntervalSince(startTime)
            progressTracking.cancel()
            store.addAssistanceResult(result, to: idea.id)
            estimatedDuration = max(3, elapsed)
            generationProgress = 1.0
            isGenerating = false
        } catch {
            progressTracking.cancel()
            generationError = error.localizedDescription
            showsGenerationError = true
            generationProgress = 0
            isGenerating = false
        }
    }
}

// MARK: - Audio player (unchanged logic)

@MainActor
final class IdeaAudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var player: AVAudioPlayer?

    func toggle(url: URL) {
        if isPlaying { stop() } else { play(url: url) }
    }

    private func play(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            isPlaying = true
        } catch { isPlaying = false }
    }

    private func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.isPlaying = false; self.player = nil }
    }
}
