//
//  CaptureIdeaView.swift
//  BrainBot

internal import SwiftUI
import AVFoundation
import Combine
import Speech

struct CaptureIdeaView: View {
    @EnvironmentObject private var store: IdeaStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = IdeaAudioRecorder()

    @State private var step = 1
    @State private var selectedCategory: IdeaCategory = .creatorMode
    @State private var selectedStyle: IdeaVisualStyle = .sage
    @State private var title = ""
    @State private var ideaText = ""
    @State private var draftIdeaID: UUID?
    @State private var isGenerating = false
    @State private var isRefining = false
    @State private var hasStartedGeneration = false
    @State private var generationError: String?
    @State private var plantedPathwayIDs: Set<UUID> = []
    @State private var notesFlash = false

    private var pathways: [IdeaSuggestion] {
        guard let id = draftIdeaID, let idea = store.idea(withID: id) else { return [] }
        return idea.assistanceResults.first?.suggestions.filter { $0.kind == .pathway } ?? []
    }

    private var canProceedFromStep1: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private var wordCount: String {
        let all = (ideaText + " " + recorder.transcript).trimmingCharacters(in: .whitespacesAndNewlines)
        let count = all.split(separator: " ").count
        return "\(count) word\(count == 1 ? "" : "s")"
    }

    private var assistanceBody: String {
        let t = ideaText.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? recorder.transcript : t
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            stepContent
            sheetFooter
        }
        .background(Color.gardenSurface2.ignoresSafeArea())
        .onAppear { recorder.requestPermissions() }
        .onChange(of: step) {
            if step == 3 && !hasStartedGeneration {
                hasStartedGeneration = true
                Task { await generateSuggestionsWithFallback() }
            }
        }
    }

    // MARK: - Sheet header

    private var sheetHeader: some View {
        HStack(spacing: 12) {
            if step > 1 {
                Button { withAnimation(.easeOut(duration: 0.32)) { step -= 1 } } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                        .foregroundStyle(Color.gardenInk)
                }
            } else {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                        .foregroundStyle(Color.gardenInk)
                }
            }

            Spacer()
            StepDotsView(step: step, total: 3)
            Spacer()

            Text("\(step) / 3")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.mossSoft)
                .foregroundStyle(Color.mossDark)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        ZStack {
            if step == 1 { step1.transition(stepTransition(forwards: true)) }
            if step == 2 { step2.transition(stepTransition(forwards: step > 1)) }
            if step == 3 { step3.transition(stepTransition(forwards: true)) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stepTransition(forwards: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: forwards ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: forwards ? .leading : .trailing).combined(with: .opacity)
        )
    }

    // MARK: Step 1 – Shape + name

    private var step1: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plant a seed")
                        .font(.display(26))
                        .foregroundStyle(Color.gardenInk)
                    Text("Pick its shape, then give it a name.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gardenInk2)
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Soil type")
                    CategoryPickerView(value: $selectedCategory)
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Botanical hue")
                    HuePickerView(value: $selectedStyle)
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("Seed name")
                    TextField("e.g. Podcast hook ideas", text: $title)
                        .font(.system(size: 15))
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.10), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .padding(.bottom, 16)
        }
    }

    // MARK: Step 2 – Story + voice

    private var step2: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tell its story")
                        .font(.display(26))
                        .foregroundStyle(Color.gardenInk)
                    Text("Type or speak — as much or little as you need.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gardenInk2)
                }

                TextEditor(text: $ideaText)
                    .font(.system(size: 15))
                    .frame(minHeight: 180)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.10), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if ideaText.isEmpty {
                                Text("What's the idea?")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.gardenInk3)
                                    .padding(.horizontal, 18)
                                    .padding(.top, 22)
                                    .allowsHitTesting(false)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                    )

                voiceSection

                if !recorder.transcript.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        sectionLabel("Transcript")
                        Text(recorder.transcript)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.gardenInk2)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.mossSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var voiceSection: some View {
        if recorder.isRecording {
            // Active recording state
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.amber)
                            .frame(width: 36, height: 36)
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: Color.amber.opacity(0.40), radius: 4, y: 2)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Listening…")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.gardenInk)
                        Text("Transcribing on-device")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gardenInk3)
                    }
                    Spacer()
                    Image(systemName: "waveform")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.amber)
                        .symbolEffect(.pulse)
                }

                HStack(spacing: 8) {
                    Button { recorder.toggleRecording() } label: {
                        Text("Stop")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundStyle(Color.mossDark)
                            .background(Color.mossSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button { recorder.finishSession(shouldTranscribe: true) } label: {
                        Text("Finish & insert")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundStyle(.white)
                            .background(Color.moss)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.amber, lineWidth: 1.5)
            )
            .shadow(color: Color.amber.opacity(0.15), radius: 8, y: 3)
        } else {
            Button { recorder.toggleRecording() } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.mossSoft)
                            .frame(width: 40, height: 40)
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.moss)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Use your voice")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.gardenInk)
                        Text("Tap and speak — we'll transcribe")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gardenInk2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gardenInk3)
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
            }
            .buttonStyle(.plain)
            .disabled(recorder.didFinishSession || recorder.isTranscribing)

            if recorder.isTranscribing {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Transcribing…")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gardenInk2)
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: Step 3 – Pathways + notes preview

    private var step3: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.amber)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Pathways")
                        .font(.display(22))
                        .foregroundStyle(Color.gardenInk)
                    Text("Tap \"Plant this\" to weave one into your notes.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Color.gardenInk2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 8) {
                    pathwaysList
                    notesPreview
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private var pathwaysList: some View {
        if isGenerating {
            // Skeleton shimmer
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .frame(height: 80)
                        .overlay(Color.gardenBgDeep.opacity(0.5))
                        .shimmer()
                }
                Text("Growing pathways…")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.gardenInk2)
                    .padding(.top, 4)
            }
        } else if pathways.isEmpty {
            // No pathways yet
            VStack(spacing: 12) {
                Text("Ask the Garden to grow pathways for this idea.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gardenInk2)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)

                if let err = generationError {
                    HStack(spacing: 8) {
                        Text("⚠️")
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "7A4F12"))
                    }
                    .padding(14)
                    .background(Color(hex: "FCF5E8"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        } else {
            VStack(spacing: 8) {
            ForEach(Array(pathways.enumerated()), id: \.element.id) { idx, pathway in
                let planted = plantedPathwayIDs.contains(pathway.id)
                HStack(alignment: .top, spacing: 10) {
                    Text("\(idx + 1)")
                        .font(.display(12, weight: .bold))
                        .frame(width: 24, height: 24)
                        .foregroundStyle(planted ? .white : Color.moss)
                        .background(planted ? Color.moss : Color.mossSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(pathway.text)
                            .font(.system(size: 13.5, weight: .medium))
                            .foregroundStyle(Color.gardenInk)
                            .lineSpacing(1.5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text("LOCAL")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.mossSoft)
                                .foregroundStyle(Color.mossDark)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                            Spacer()

                            Button {
                                plantPathway(pathway)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: planted ? "checkmark" : "leaf.fill")
                                        .font(.system(size: 11))
                                    Text(planted ? "Planted" : "Plant this")
                                        .font(.system(size: 11.5, weight: .bold))
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 26)
                                .foregroundStyle(planted ? Color.mossDark : .white)
                                .background(planted ? Color.white : Color.moss)
                                .clipShape(Capsule())
                                .shadow(color: planted ? .clear : Color.moss.opacity(0.20), radius: 3, y: 1)
                            }
                            .buttonStyle(.plain)
                            .disabled(planted)
                        }
                    }
                }
                .padding(12)
                .background(planted ? Color(hex: "B8DAB7") : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(planted ? Color(hex: "7BB47A") : Color.black.opacity(0.08), lineWidth: planted ? 1.5 : 1)
                )
                .animation(.easeOut(duration: 0.25), value: planted)
            }

            if isRefining {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Refining with local AI…")
                        .font(.system(size: 11.5))
                        .foregroundStyle(Color.gardenInk3)
                }
                .padding(.horizontal, 4)
                .padding(.top, 2)
            }
            } // VStack
        }
    }

    private var notesPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gardenInk2)
                    Text("Your seed notes")
                        .font(.system(size: 10.5, weight: .heavy))
                        .textCase(.uppercase)
                        .tracking(0.6)
                        .foregroundStyle(Color.gardenInk2)
                }
                Spacer()
                Text(wordCount)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Color.gardenInk3)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            TextEditor(text: $ideaText)
                .font(.system(size: 13.5))
                .foregroundStyle(Color.gardenInk)
                .frame(height: 90)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(notesFlash ? Color.sprout : Color.black.opacity(0.10),
                        lineWidth: notesFlash ? 1.5 : 1)
        )
        .shadow(
            color: notesFlash ? Color.sprout.opacity(0.18) : .black.opacity(0.05),
            radius: notesFlash ? 6 : 2, y: 1
        )
        .animation(.easeOut(duration: 0.25), value: notesFlash)
    }

    // MARK: - Footer

    private var sheetFooter: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.5)
            Group {
                switch step {
                case 1:
                    Button("Name it & continue") {
                        advance()
                    }
                    .buttonStyle(GardenButtonStyle(isDisabled: !canProceedFromStep1))
                    .disabled(!canProceedFromStep1)

                case 2:
                    HStack(spacing: 10) {
                        Button("Save now") { saveSeed() }
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(Color.gardenInk2)

                        Button {
                            autosave()
                            advance()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Get pathways")
                                Image(systemName: "sparkles")
                            }
                        }
                        .buttonStyle(GardenButtonStyle())
                        .frame(maxWidth: .infinity)
                    }

                default:
                    HStack(spacing: 10) {
                        Button("Skip") { saveSeed() }
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(Color.gardenInk2)

                        Button {
                            saveSeed()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Save seed")
                                Image(systemName: "leaf.fill")
                            }
                        }
                        .buttonStyle(GardenButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(Color.gardenSurface2)
    }

    // MARK: - Actions

    private func advance() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            step = min(step + 1, 3)
        }
    }


    private func plantPathway(_ pathway: IdeaSuggestion) {
        guard !plantedPathwayIDs.contains(pathway.id) else { return }
        plantedPathwayIDs.insert(pathway.id)
        let separator = ideaText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : "\n\n• "
        if ideaText.isEmpty {
            ideaText = "• " + pathway.text
        } else {
            ideaText += separator + pathway.text
        }
        withAnimation { notesFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { notesFlash = false }
        }
    }

    private func saveSeed() {
        autosave()
        store.grantXP(15)
        dismiss()
    }

    private func autosave() {
        let body: String = {
            let t = ideaText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { return ideaText }
            if !recorder.transcript.isEmpty { return recorder.transcript }
            if recorder.didFinishSession { return "Audio recording saved without transcript." }
            return ideaText
        }()

        draftIdeaID = store.autosaveIdea(
            id: draftIdeaID,
            title: title,
            body: body,
            category: selectedCategory,
            style: selectedStyle,
            audioRecordingURL: recorder.didFinishSession ? recorder.recordingURL : nil,
            transcript: recorder.transcript
        )
    }

    private func generateSuggestionsWithFallback() async {
        let request = IdeaAssistanceRequest(title: title, body: assistanceBody, assistanceLevel: .standard)

        await MainActor.run {
            isGenerating = true
            generationError = nil
            autosave()
        }

        // Phase 1: heuristic (instant — always works, zero wait)
        if let heuristicResult = try? await HeuristicIdeaProvider().suggestions(for: request) {
            await MainActor.run {
                if let id = draftIdeaID { store.addAssistanceResult(heuristicResult, to: id) }
                isGenerating = false
                isRefining = true
            }
        } else {
            await MainActor.run { isGenerating = false }
            return
        }

        // Phase 2: local LLM upgrade (3–8s) — user sees heuristic while this runs
        do {
            let localResult = try await LlamaCppLocalIdeaProvider().suggestions(for: request)
            if IdeaAssistantService.passesQualityGate(localResult) {
                await MainActor.run {
                    if let id = draftIdeaID { store.addAssistanceResult(localResult, to: id) }
                }
            }
        } catch { /* silently discard — heuristic results already visible */ }

        await MainActor.run { isRefining = false }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(Color.gardenInk3)
    }
}

// MARK: - Shimmer modifier

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.4), location: 0.5),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 3)
                    .offset(x: phase * geo.size.width * 3)
                    .onAppear {
                        withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
                }
                .clipped()
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - IdeaAudioRecorder (unchanged)

@MainActor
final class IdeaAudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var hasRecording = false
    @Published var didFinishSession = false
    @Published var isTranscribing = false
    @Published var transcript = ""
    @Published var statusText = "Start a voice session. Pause and resume as much as you want."

    private var audioRecorder: AVAudioRecorder?
    private var recognitionTask: SFSpeechRecognitionTask?
    private(set) var recordingURL: URL?

    var primaryActionTitle: String {
        if isRecording { return "Stop" }
        return hasRecording ? "Resume" : "Start"
    }

    var hasUnfinishedRecording: Bool {
        hasRecording && !didFinishSession
    }

    func requestPermissions() {
        requestMicrophonePermission()
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self?.statusText = "Speech permission is needed for transcripts and AI suggestions."
                }
            }
        }
    }

    private func requestMicrophonePermission() {
        let completion: @Sendable (Bool) -> Void = { [weak self] allowed in
            Task { @MainActor [weak self] in
                if !allowed { self?.statusText = "Microphone permission is needed to record ideas." }
            }
        }
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: completion)
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission(completion)
        }
    }

    func toggleRecording() {
        if isRecording { pauseRecording() } else { startOrResumeRecording() }
    }

    func finishSession(shouldTranscribe: Bool) {
        if isRecording { pauseRecording() }
        guard let url = recordingURL else { return }
        audioRecorder?.stop()
        audioRecorder = nil
        hasRecording = true
        didFinishSession = true
        statusText = shouldTranscribe ? "Recording saved. Preparing transcript." : "Recording saved without transcription."
        guard shouldTranscribe else { return }
        transcribeRecording(at: url)
    }

    func resetSession() {
        if isRecording { audioRecorder?.stop() }
        audioRecorder = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        recordingURL = nil
        isRecording = false
        hasRecording = false
        didFinishSession = false
        isTranscribing = false
        transcript = ""
        statusText = "Start a voice session. Pause and resume as much as you want."
    }

    private func startOrResumeRecording() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            if audioRecorder == nil {
                let url = makeRecordingURL()
                recordingURL = url
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                audioRecorder?.delegate = self
            }
            audioRecorder?.record()
            isRecording = true
            hasRecording = true
            didFinishSession = false
            statusText = "Recording. Tap Stop to pause this session."
        } catch {
            statusText = "Could not start recording: \(error.localizedDescription)"
        }
    }

    private func pauseRecording() {
        audioRecorder?.pause()
        isRecording = false
        hasRecording = true
        didFinishSession = false
        statusText = "Paused. Tap Resume to keep adding to the same recording."
    }

    private func transcribeRecording(at url: URL) {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            statusText = "Speech recognition is not available right now."
            return
        }
        isTranscribing = true
        recognitionTask?.cancel()
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let result { self.transcript = result.bestTranscription.formattedString }
                if result?.isFinal == true || error != nil {
                    self.isTranscribing = false
                    self.statusText = error == nil ? "Recording saved with transcript." : "Recording saved, but transcription failed."
                }
            }
        }
    }

    private func makeRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("BrainBotRecordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("idea-\(UUID().uuidString).m4a")
    }
}
