//
//  CaptureIdeaView.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI
import AVFoundation
import Combine
import Speech

struct CaptureIdeaView: View {
    @EnvironmentObject private var store: IdeaStore
    @StateObject private var recorder = IdeaAudioRecorder()
    @State private var title = ""
    @State private var ideaText = ""
    @State private var selectedCategory: IdeaCategory = .quickWin
    @State private var selectedStyle: IdeaVisualStyle = .mist
    @State private var selectedAssistanceLevel: IdeaAssistanceLevel = .standard
    @State private var transcribeForSuggestions = true
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
            selectedStyle.rawValue,
            recorder.transcript
        ].joined(separator: "|")
    }

    private var assistanceBody: String {
        let cleanIdeaText = ideaText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanIdeaText.isEmpty {
            return cleanIdeaText
        }

        return recorder.transcript
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
                    Toggle("Transcribe for AI suggestions", isOn: $transcribeForSuggestions)

                    VStack(alignment: .leading, spacing: 8) {
                        Label(recorder.statusText, systemImage: recorder.isRecording ? "waveform" : "mic.fill")
                            .font(.subheadline)
                            .foregroundStyle(recorder.isRecording ? Color.midnightGreen : .secondary)

                        HStack {
                            Button(recorder.primaryActionTitle) {
                                recorder.toggleRecording()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(recorder.isRecording ? .red : .midnightGreen)
                            .disabled(recorder.didFinishSession || recorder.isTranscribing)

                            Button("Finish Session") {
                                recorder.finishSession(shouldTranscribe: transcribeForSuggestions)
                            }
                            .buttonStyle(.bordered)
                            .disabled(!recorder.hasRecording || recorder.isTranscribing)
                        }
                    }

                    if recorder.isTranscribing {
                        ProgressView("Transcribing")
                    }

                    if !transcribeForSuggestions {
                        Label("AI suggestions require transcription. Your audio can still be saved without it.", systemImage: "sparkles")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if !recorder.transcript.isEmpty {
                        Text(recorder.transcript)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
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
                            body: assistanceBody,
                            assistanceLevel: selectedAssistanceLevel
                        ).isReady || !transcribeForSuggestions || recorder.isTranscribing || recorder.hasUnfinishedRecording)

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
                        recorder.resetSession()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } footer: {
                    Text("Notes autosave while you type.")
                }
            }
            .navigationTitle("Capture")
            .onAppear {
                recorder.requestPermissions()
            }
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
                        body: autosaveBody(),
                        category: selectedCategory,
                        style: selectedStyle,
                        audioRecordingURL: recorder.didFinishSession ? recorder.recordingURL : nil,
                        transcript: recorder.transcript
                    )
                }
            }
        }
    }

    private func autosaveBody() -> String {
        let cleanIdeaText = ideaText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanIdeaText.isEmpty {
            return ideaText
        }

        if !recorder.transcript.isEmpty {
            return recorder.transcript
        }

        if recorder.didFinishSession {
            return "Audio recording saved without transcript."
        }

        return ideaText
    }

    private func generateSuggestions() async {
        await MainActor.run {
            isGeneratingSuggestions = true
            generationError = nil
            draftIdeaID = store.autosaveIdea(
                id: draftIdeaID,
                title: title,
                body: autosaveBody(),
                category: selectedCategory,
                style: selectedStyle,
                audioRecordingURL: recorder.didFinishSession ? recorder.recordingURL : nil,
                transcript: recorder.transcript
            )
        }

        do {
            let result = try await assistantService.generateSuggestions(
                for: IdeaAssistanceRequest(
                    title: title,
                    body: assistanceBody,
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
                if !allowed {
                    self?.statusText = "Microphone permission is needed to record ideas."
                }
            }
        }

        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: completion)
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission(completion)
        }
    }

    func toggleRecording() {
        if isRecording {
            pauseRecording()
        } else {
            startOrResumeRecording()
        }
    }

    func finishSession(shouldTranscribe: Bool) {
        if isRecording {
            pauseRecording()
        }

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
        if isRecording {
            audioRecorder?.stop()
        }
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

                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }

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
