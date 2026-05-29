//
//  IdeaBubbleMapView.swift
//  BrainBot

internal import SwiftUI

struct IdeaBubbleMapView: View {
    @EnvironmentObject private var store: IdeaStore
    @Environment(\.dismiss) private var dismiss

    @State private var seedText = ""
    @State private var branches: [MapBranch] = []
    @State private var isGenerating = false
    @State private var selectedIndex: Int? = nil
    @State private var history: [String] = []           // breadcrumb stack for "back"
    @State private var category: IdeaCategory = .creatorMode
    @State private var showCustomInput = false
    @State private var customDraft = ""
    @State private var shimmer = false
    @State private var canvasMap: BubbleMap = BubbleMap()
    @State private var showCanvas = false
    @FocusState private var seedFocused: Bool
    @FocusState private var customFocused: Bool

    // Pre-fetch to hide latency
    @State private var prefetchTask: Task<IdeaAssistanceResult?, Never>? = nil
    @State private var debounceTask: Task<Void, Never>? = nil

    // Layout
    private let centralY: CGFloat = 108
    private let centralW: CGFloat = 184
    private let centralH: CGFloat = 64
    private let lineLen:  CGFloat = 144
    private let bubbleW:  CGFloat = 148
    private let bubbleH:  CGFloat = 72
    private let angles: [Double] = [-44, -15, 15, 44]

    private func branchCenter(index: Int, cx: CGFloat) -> CGPoint {
        let rad = angles[index] * .pi / 180
        let startY = centralY + centralH / 2
        return CGPoint(
            x: cx + CGFloat(sin(rad)) * lineLen,
            y: startY + CGFloat(cos(rad)) * lineLen
        )
    }

    private var canvasHeight: CGFloat {
        centralY + centralH / 2 + lineLen + bubbleH / 2 + 28
    }

    var body: some View {
        VStack(spacing: 0) {
            mapHeader
            ScrollView {
                VStack(spacing: 14) {
                    seedCard
                    if isGenerating && branches.isEmpty { generatingCard }
                    if !branches.isEmpty {
                        bubbleCanvas
                        if showCustomInput { customInputCard }
                        if selectedBranchIsReady { extendBar }
                        categoryPicker
                        plantRow
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 28)
            }
        }
        .background(Color.gardenSurface2.ignoresSafeArea())
        .onAppear { shimmer = true }
        .onChange(of: seedText) { _, newValue in startDebounce(for: newValue) }
        .fullScreenCover(isPresented: $showCanvas) {
            canvasSheet
        }
    }

    private var canvasSheet: some View {
        NavigationStack {
            IdeaBubbleCanvasView(map: $canvasMap, onSave: {})
                .navigationTitle("Bubble Canvas")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") { showCanvas = false }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.moss)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            plantMapFromCanvas()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Plant")
                                Image(systemName: "leaf.fill")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.moss)
                        }
                    }
                }
        }
    }

    // MARK: - Derived state

    private var selectedBranchIsReady: Bool {
        guard let idx = selectedIndex, idx < branches.count else { return false }
        let b = branches[idx]
        if b.isCustomPlaceholder { return false }
        return !b.text.isEmpty && !b.isSkeleton
    }

    // MARK: - Header

    private var mapHeader: some View {
        HStack {
            if history.isEmpty {
                Button { dismiss() } label: { xButton }
            } else {
                Button {
                    let prev = history.removeLast()
                    seedText = prev
                    branches = []
                    selectedIndex = nil
                    showCustomInput = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                        .foregroundStyle(Color.gardenInk)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Bubble Map")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.gardenInk)
                if !history.isEmpty {
                    Text("Level \(history.count + 1)")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.moss)
                } else {
                    Text("Branch your idea with AI")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gardenInk3)
                }
            }

            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var xButton: some View {
        Image(systemName: "xmark")
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 36, height: 36)
            .background(Color.white.opacity(0.92))
            .clipShape(Circle())
            .foregroundStyle(Color.gardenInk)
    }

    // MARK: - Seed input

    private var seedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(history.isEmpty ? "Your core idea" : "Drilling into")
                    .font(.system(size: 11, weight: .heavy))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Color.gardenInk3)
                Spacer()
                if prefetchTask != nil && !isGenerating {
                    HStack(spacing: 5) {
                        ProgressView().scaleEffect(0.6)
                        Text("Pre-loading…")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.gardenInk3)
                    }
                }
            }

            TextField("Type your idea here…", text: $seedText, axis: .vertical)
                .font(.system(size: 15))
                .foregroundStyle(Color.gardenInk)
                .lineLimit(3)
                .focused($seedFocused)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            seedText.isEmpty ? Color.black.opacity(0.10) : Color.moss.opacity(0.5),
                            lineWidth: seedText.isEmpty ? 1 : 1.5
                        )
                )

            Button { Task { await sprout() } } label: {
                HStack(spacing: 8) {
                    Image(systemName: branches.isEmpty ? "sparkles" : "arrow.clockwise")
                    Text(isGenerating ? "Growing…" : branches.isEmpty ? "Sprout branches" : "Re-sprout")
                }
            }
            .buttonStyle(GardenButtonStyle(
                isDisabled: isGenerating || seedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ))
            .disabled(isGenerating || seedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
        )
    }

    // MARK: - Generating indicator (only shown before first branches appear)

    private var generatingCard: some View {
        HStack(spacing: 10) {
            ProgressView().scaleEffect(0.85)
            Text("Growing branches with AI…")
                .font(.system(size: 13))
                .foregroundStyle(Color.gardenInk2)
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.moss.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Bubble canvas

    private var bubbleCanvas: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2

            ZStack {
                // Lines
                ForEach(Array(branches.enumerated()), id: \.element.id) { i, branch in
                    let pos = branchCenter(index: i, cx: cx)
                    BranchConnectorShape(
                        from: CGPoint(x: cx, y: centralY + centralH / 2),
                        to:   CGPoint(x: pos.x, y: pos.y - bubbleH / 2)
                    )
                    .stroke(
                        selectedIndex == i ? Color.moss.opacity(0.65) : Color.moss.opacity(0.28),
                        style: StrokeStyle(lineWidth: selectedIndex == i ? 2.5 : 1.5, lineCap: .round)
                    )
                    .opacity(branch.revealed ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(Double(i) * 0.09), value: branch.revealed)
                    .animation(.easeOut(duration: 0.2), value: selectedIndex)
                }

                // Central bubble
                Text(seedText.isEmpty ? "Your idea" : seedText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .frame(width: centralW, height: centralH, alignment: .center)
                    .background(Color.moss)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.moss.opacity(0.40), radius: 10, y: 5)
                    .position(x: cx, y: centralY)

                // Branch bubbles
                ForEach(Array(branches.enumerated()), id: \.element.id) { i, branch in
                    let pos = branchCenter(index: i, cx: cx)
                    branchBubble(branch, index: i)
                        .opacity(branch.revealed ? (selectedIndex != nil && selectedIndex != i ? 0.55 : 1) : 0)
                        .scaleEffect(branch.revealed ? (selectedIndex == i ? 1.04 : 1) : 0.4)
                        .animation(.spring(response: 0.38, dampingFraction: 0.7).delay(Double(i) * 0.09 + 0.04), value: branch.revealed)
                        .animation(.easeOut(duration: 0.18), value: selectedIndex)
                        .position(x: pos.x, y: pos.y)
                }
            }
            .frame(width: geo.size.width, height: canvasHeight)
        }
        .frame(height: canvasHeight)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func branchBubble(_ branch: MapBranch, index: Int) -> some View {
        let isSelected = selectedIndex == index

        if branch.isSkeleton {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.gardenSurface2)
                .frame(width: bubbleW, height: bubbleH)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.07), lineWidth: 1)
                )
                .opacity(shimmer ? 0.45 : 0.85)
                .animation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true).delay(Double(index) * 0.15), value: shimmer)

        } else if branch.isCustomPlaceholder {
            Button {
                showCustomInput = true
                customFocused = true
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Color.white : Color.moss)
                    Text("Your direction")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.moss)
                }
                .frame(width: bubbleW, height: bubbleH)
                .background(isSelected ? Color.moss : Color.mossSoft)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            isSelected ? Color.moss : Color.moss.opacity(0.35),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                )
                .shadow(color: isSelected ? Color.moss.opacity(0.25) : .clear, radius: 6, y: 3)
            }
            .buttonStyle(.plain)

        } else {
            Button {
                withAnimation(.easeOut(duration: 0.18)) {
                    selectedIndex = selectedIndex == index ? nil : index
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 4) {
                        branchKindBadge(branch.kind, selected: isSelected)
                        Text(branch.text)
                            .font(.system(size: 11.5))
                            .foregroundStyle(isSelected ? Color.white : Color.gardenInk)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(width: bubbleW, height: bubbleH, alignment: .center)
                    .background(isSelected ? Color.moss : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                isSelected ? Color.mossDark : kindBorderColor(branch.kind),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(color: isSelected ? Color.moss.opacity(0.30) : .black.opacity(0.05), radius: isSelected ? 8 : 4, y: isSelected ? 4 : 2)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .background(Color.moss, in: Circle())
                            .offset(x: 6, y: -6)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Custom input card

    private var customInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your direction")
                .font(.system(size: 11, weight: .heavy))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color.gardenInk3)

            TextField("Where would you take this?…", text: $customDraft, axis: .vertical)
                .font(.system(size: 14))
                .foregroundStyle(Color.gardenInk)
                .lineLimit(3)
                .focused($customFocused)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.moss.opacity(0.45), lineWidth: 1.5)
                )

            HStack(spacing: 10) {
                Button { showCustomInput = false } label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(Color.gardenInk2)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.black.opacity(0.10), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button { commitCustom() } label: {
                    Text("Set direction")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(.white)
                        .background(customDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.moss.opacity(0.45) : Color.moss)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(customDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.moss.opacity(0.25), lineWidth: 1.5)
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Extend bar

    private var extendBar: some View {
        Button {
            guard let idx = selectedIndex else { return }
            let selectedText = branches[idx].text
            history.append(seedText)
            seedText = selectedText
            selectedIndex = nil
            showCustomInput = false
            branches = []
            Task { await sprout() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18))
                Text("Follow this path")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.6)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.moss)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.moss.opacity(0.30), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Category picker

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Save to")
                .font(.system(size: 11, weight: .heavy))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color.gardenInk3)

            HStack(spacing: 8) {
                ForEach(IdeaCategory.allCases) { cat in
                    Button { category = cat } label: {
                        HStack(spacing: 5) {
                            Text(cat.emoji).font(.system(size: 13))
                            Text(cat.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .foregroundStyle(category == cat ? .white : Color.gardenInk2)
                        .background(category == cat ? Color.moss : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(
                                category == cat ? Color.clear : Color.black.opacity(0.10),
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeOut(duration: 0.15), value: category)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
        )
    }

    // MARK: - Plant row

    private var plantRow: some View {
        VStack(spacing: 10) {
            Button {
                buildCanvasMap()
                showCanvas = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.3x3.fill")
                    Text("Explore on canvas")
                }
            }
            .buttonStyle(GardenButtonStyle(kind: .soft))

            Button { plantMap() } label: {
                HStack(spacing: 8) {
                    Text("Plant this map")
                    Image(systemName: "leaf.fill")
                }
            }
            .buttonStyle(GardenButtonStyle())
        }
    }

    // MARK: - Helper views

    private func branchKindBadge(_ kind: IdeaSuggestionKind, selected: Bool) -> some View {
        Text(kindLabel(kind))
            .font(.system(size: 9, weight: .heavy))
            .textCase(.uppercase)
            .tracking(0.3)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .foregroundStyle(selected ? Color.white.opacity(0.85) : kindFg(kind))
            .background(selected ? Color.white.opacity(0.20) : kindBg(kind))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    private func kindLabel(_ k: IdeaSuggestionKind) -> String {
        switch k {
        case .question:   return "Question"
        case .pathway:    return "Pathway"
        case .assumption: return "Assumption"
        }
    }

    private func kindBg(_ k: IdeaSuggestionKind) -> Color {
        switch k {
        case .question:   return Color(hex: "E7F0F6")
        case .pathway:    return Color.mossSoft
        case .assumption: return Color(hex: "F6E4C5")
        }
    }

    private func kindFg(_ k: IdeaSuggestionKind) -> Color {
        switch k {
        case .question:   return Color(hex: "214F86")
        case .pathway:    return Color.mossDark
        case .assumption: return Color(hex: "7A4F12")
        }
    }

    private func kindBorderColor(_ k: IdeaSuggestionKind) -> Color {
        switch k {
        case .question:   return Color(hex: "C0D5E8")
        case .pathway:    return Color.moss.opacity(0.22)
        case .assumption: return Color(hex: "E0C896")
        }
    }

    // MARK: - Pre-fetch (debounced, runs off main thread)

    private func startDebounce(for text: String) {
        debounceTask?.cancel()
        prefetchTask?.cancel()
        prefetchTask = nil

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(1200))
            guard !Task.isCancelled else { return }
            prefetchTask = Task {
                await Self.runInference(for: trimmed)
            }
        }
    }

    private static func runInference(for text: String) async -> IdeaAssistanceResult? {
        let request = IdeaAssistanceRequest(title: text, body: text, assistanceLevel: .standard)
        return try? await Task.detached(priority: .userInitiated) {
            try await LlamaCppLocalIdeaProvider().suggestions(for: request)
        }.value
    }

    // MARK: - Sprout (with instant skeletons)

    @MainActor
    private func sprout() async {
        seedFocused = false
        selectedIndex = nil
        showCustomInput = false
        isGenerating = true

        // Show skeleton bubbles immediately so there's no blank wait
        branches = (0..<4).map { _ in MapBranch(text: "", kind: .pathway, isSkeleton: true, revealed: true) }

        // Use pre-fetched result if ready, otherwise fetch now (off main thread)
        let result: IdeaAssistanceResult?
        if let existing = prefetchTask {
            result = await existing.value
        } else {
            result = await Self.runInference(for: seedText)
        }
        prefetchTask = nil

        isGenerating = false

        // Build real branches from result
        var newBranches: [MapBranch] = []
        if let r = result {
            newBranches = r.suggestions.prefix(3).map { MapBranch(text: $0.text, kind: $0.kind) }
        }
        while newBranches.count < 3 {
            newBranches.append(contentsOf: [
                MapBranch(text: "What problem does this solve?", kind: .question),
                MapBranch(text: "How might this grow over time?", kind: .pathway),
                MapBranch(text: "What are you assuming here?", kind: .assumption),
            ].prefix(3 - newBranches.count))
        }
        // 4th slot: user's custom direction
        newBranches.append(MapBranch(text: "", kind: .pathway, isCustomPlaceholder: true))

        // Replace skeletons with real content, staggered
        branches = newBranches.map { var b = $0; b.revealed = false; return b }
        for i in 0..<branches.count {
            try? await Task.sleep(for: .milliseconds(80))
            branches[i].revealed = true
        }
    }

    // MARK: - Other actions

    private func commitCustom() {
        guard !customDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let idx = branches.indices.first(where: { branches[$0].isCustomPlaceholder }) else { return }
        branches[idx].text = customDraft
        branches[idx].isCustomPlaceholder = false
        customDraft = ""
        showCustomInput = false
        // Auto-select the custom branch
        selectedIndex = idx
    }

    private func buildCanvasMap() {
        var map = BubbleMap()
        let root = BubbleMapNode(text: seedText, kind: .pathway, x: 0, y: 0, isRoot: true)
        map.nodes.append(root)

        let realBranches = branches.filter { !$0.isSkeleton && !$0.isCustomPlaceholder && !$0.text.isEmpty }
        let positions = BubbleMap.childPositions(parentX: 0, parentY: 0, count: realBranches.count)
        for (i, branch) in realBranches.enumerated() {
            let node = BubbleMapNode(
                text: branch.text,
                kind: branch.kind,
                x: positions[i].x,
                y: positions[i].y,
                parentId: root.id
            )
            map.nodes.append(node)
        }
        canvasMap = map
    }

    private func plantMap() {
        buildCanvasMap()
        let lines = branches
            .filter { !$0.isCustomPlaceholder && !$0.text.isEmpty && !$0.isSkeleton }
            .map { "• " + $0.text }
            .joined(separator: "\n")

        let trail = history.isEmpty ? "" : "Path: \(history.joined(separator: " → "))\n\n"
        let body = trail + (lines.isEmpty ? seedText : "Branches:\n\(lines)")

        let ideaId = store.autosaveIdea(
            id: nil,
            title: seedText,
            body: body,
            category: category,
            style: .sage,
            audioRecordingURL: nil,
            transcript: nil
        )
        if let id = ideaId {
            store.updateBubbleMap(canvasMap, for: id)
        }
        store.grantXP(15)
        dismiss()
    }

    private func plantMapFromCanvas() {
        let root = canvasMap.rootNode
        let lines = canvasMap.nodes
            .filter { !$0.isRoot && !$0.isSkeleton && !$0.text.isEmpty }
            .map { "• " + $0.text }
            .joined(separator: "\n")

        let body = lines.isEmpty ? seedText : "Branches:\n\(lines)"

        let ideaId = store.autosaveIdea(
            id: nil,
            title: root?.text ?? seedText,
            body: body,
            category: category,
            style: .sage,
            audioRecordingURL: nil,
            transcript: nil
        )
        if let id = ideaId {
            store.updateBubbleMap(canvasMap, for: id)
        }
        store.grantXP(15)
        showCanvas = false
        dismiss()
    }
}

// MARK: - Branch data model

struct MapBranch: Identifiable {
    let id = UUID()
    var text: String
    var kind: IdeaSuggestionKind
    var isCustomPlaceholder: Bool = false
    var isSkeleton: Bool = false
    var revealed: Bool = false
}

// MARK: - Bezier connector shape

private struct BranchConnectorShape: Shape {
    let from: CGPoint
    let to: CGPoint

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: from)
        let dy = to.y - from.y
        let ctrl1 = CGPoint(x: from.x, y: from.y + dy * 0.42)
        let ctrl2 = CGPoint(x: to.x,   y: to.y   - dy * 0.42)
        p.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        return p
    }
}
