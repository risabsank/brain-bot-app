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
    @StateObject private var generation = GenerationCoordinator()

    @State private var title = ""
    @State private var ideaText = ""
    @State private var draftIdeaID: UUID?
    @State private var plantedSuggestionIDs: Set<UUID> = []

    private var suggestions: [IdeaSuggestion] {
        guard let id = draftIdeaID, let idea = store.idea(withID: id) else { return [] }
        return idea.assistanceResults.first?.suggestions ?? []
    }

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
            captureHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    titleField
                    bodyEditor
                    voiceSection
                    if !recorder.transcript.isEmpty {
                        transcriptCard
                    }
                    suggestionArea
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            captureFooter
        }
        .background(Color.gardenSurface2.ignoresSafeArea())
        .onAppear {
            recorder.requestPermissions()
            generation.startPolling()
        }
        .onChange(of: title) { generation.currentTitle = title }
        .onChange(of: ideaText) { generation.currentBody = assistanceBody }
        .onChange(of: recorder.transcript) { generation.currentBody = assistanceBody }
        .onChange(of: generation.pendingResult) {
            guard let result = generation.pendingResult else { return }
            autosave()
            if let id = draftIdeaID { store.addAssistanceResult(result, to: id) }
            generation.clearPendingResult()
        }
        .onDisappear { generation.stopPolling() }
    }

    // MARK: - Header

    private var captureHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
                    .foregroundStyle(Color.gardenInk)
            }
            Spacer()
            Text("New Idea")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.gardenInk)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Input fields

    private var titleField: some View {
        TextField("Idea title", text: $title)
            .font(.display(20, weight: .semibold))
            .foregroundStyle(Color.gardenInk)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.10), lineWidth: 1)
            )
    }

    private var bodyEditor: some View {
        ZStack(alignment: .topLeading) {
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
            if ideaText.isEmpty {
                Text("What's the idea?")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gardenInk3)
                    .padding(.horizontal, 18)
                    .padding(.top, 22)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Voice

    @ViewBuilder
    private var voiceSection: some View {
        if recorder.isRecording {
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

    private var transcriptCard: some View {
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

    // MARK: - AI suggestion area

    @ViewBuilder
    private var suggestionArea: some View {
        if suggestions.isEmpty {
            if generation.isGenerating {
                generationProgressCard
            } else if generation.lastGenerationFailed {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(Color(hex: "B57A12"))
                    Text("AI model unavailable — add the model file to enable pathways.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "7A4F12"))
                }
                .padding(14)
                .background(Color(hex: "FCF5E8"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gardenInk3)
                    Text("Tap the brain button for thought-starters on your idea.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gardenInk3)
                }
                .padding(14)
                .background(Color.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        } else {
            VStack(spacing: 8) {
                ForEach(suggestions) { suggestion in
                    let planted = plantedSuggestionIDs.contains(suggestion.id)
                    HStack(alignment: .top, spacing: 10) {
                        SuggestionBadgeView(kind: suggestion.kind)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(suggestion.text)
                                .font(.system(size: 13.5, weight: .medium))
                                .foregroundStyle(Color.gardenInk)
                                .lineSpacing(1.5)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack {
                                Text("LOCAL AI")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.mossSoft)
                                    .foregroundStyle(Color.mossDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                                Spacer()

                                Button { plantSuggestion(suggestion) } label: {
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

                if generation.isGenerating {
                    HStack(spacing: 6) {
                        ProgressView().scaleEffect(0.75)
                        Text("Refreshing with latest notes…")
                            .font(.system(size: 11.5))
                            .foregroundStyle(Color.gardenInk3)
                    }
                    .padding(.top, 2)
                }
            }
        }
    }

    private var generationProgressCard: some View {
        VStack(spacing: 8) {
            ProgressView(value: generation.generationProgress)
                .tint(Color.moss)
                .animation(.linear(duration: 0.15), value: generation.generationProgress)

            let secondsLeft = max(0, Int(ceil(generation.estimatedDuration * (1 - generation.generationProgress))))
            Text(generation.generationProgress < 0.04
                    ? "Starting local AI…"
                    : "~\(secondsLeft)s left")
                .font(.system(size: 12))
                .foregroundStyle(Color.gardenInk3)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.moss.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Footer

    private var captureFooter: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.5)
            HStack(spacing: 12) {
                Button { generation.triggerImmediate() } label: {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20))
                        .frame(width: 52, height: 52)
                        .foregroundStyle(generation.isGenerating ? Color.gardenInk3 : Color.moss)
                        .background(generation.isGenerating ? Color.gardenSurface2 : Color.mossSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    generation.isGenerating ? Color.black.opacity(0.08) : Color.moss.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
                .disabled(generation.isGenerating)

                Button { saveSeed() } label: {
                    HStack(spacing: 8) {
                        Text("Plant")
                        Image(systemName: "leaf.fill")
                    }
                }
                .buttonStyle(GardenButtonStyle())
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(Color.gardenSurface2)
    }

    // MARK: - Actions

    private func plantSuggestion(_ suggestion: IdeaSuggestion) {
        guard !plantedSuggestionIDs.contains(suggestion.id) else { return }
        plantedSuggestionIDs.insert(suggestion.id)
        if ideaText.isEmpty {
            ideaText = "• " + suggestion.text
        } else {
            ideaText += "\n\n• " + suggestion.text
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
            category: .creatorMode,
            style: .sage,
            audioRecordingURL: recorder.didFinishSession ? recorder.recordingURL : nil,
            transcript: recorder.transcript
        )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(Color.gardenInk3)
    }
}

// MARK: - Generation coordinator

@MainActor
final class GenerationCoordinator: ObservableObject {
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0
    @Published var pendingResult: IdeaAssistanceResult?
    @Published var lastGenerationFailed = false

    var estimatedDuration: TimeInterval = 8
    var currentTitle = ""
    var currentBody = ""

    private var pollingTask: Task<Void, Never>?
    private var progressTask: Task<Void, Never>?

    func startPolling() {
        guard pollingTask == nil else { return }
        pollingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let title = self.currentTitle
                let body = self.currentBody
                let hasContent = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                 || !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                if hasContent {
                    let start = Date()
                    await self.runGeneration(title: title, body: body)
                    let elapsed = Date().timeIntervalSince(start)
                    if elapsed > 1 { self.estimatedDuration = elapsed }
                    let wait = max(5.0, elapsed + 2.0)
                    try? await Task.sleep(for: .seconds(wait))
                } else {
                    try? await Task.sleep(for: .seconds(2))
                }
                if Task.isCancelled { break }
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        progressTask?.cancel()
        progressTask = nil
        isGenerating = false
        generationProgress = 0
    }

    func triggerImmediate() {
        stopPolling()
        startPolling()
    }

    func clearPendingResult() { pendingResult = nil }

    private func runGeneration(title: String, body: String) async {
        isGenerating = true
        generationProgress = 0
        lastGenerationFailed = false
        let startTime = Date()

        progressTask?.cancel()
        progressTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                let elapsed = Date().timeIntervalSince(startTime)
                self.generationProgress = min(0.95, elapsed / self.estimatedDuration)
                try? await Task.sleep(for: .milliseconds(100))
            }
        }

        let request = IdeaAssistanceRequest(title: title, body: body, assistanceLevel: .standard)
        do {
            let result = try await LlamaCppLocalIdeaProvider().suggestions(for: request)
            if IdeaAssistantService.passesQualityGate(result) {
                pendingResult = result
                generationProgress = 1.0
            } else {
                lastGenerationFailed = true
                generationProgress = 0
            }
        } catch {
            lastGenerationFailed = true
            generationProgress = 0
        }

        progressTask?.cancel()
        progressTask = nil
        isGenerating = false
    }
}

// MARK: - IdeaAudioRecorder

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
