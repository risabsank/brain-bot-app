//
//  IdeaBubbleCanvasView.swift
//  BrainBot

internal import SwiftUI

struct IdeaBubbleCanvasView: View {
    @Binding var map: BubbleMap
    let onSave: () -> Void

    @State private var scale: CGFloat = 0.9
    @State private var lastScale: CGFloat = 0.9
    @State private var canvasOffset: CGSize = .zero
    @State private var lastCanvasOffset: CGSize = .zero
    @State private var selectedNodeId: UUID? = nil
    @State private var editingNodeId: UUID? = nil
    @State private var editingText: String = ""
    @State private var nodeDragPrev: [UUID: CGSize] = [:]
    @State private var generatingForNodeId: UUID? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.gardenSurface2.ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.easeOut(duration: 0.15)) { selectedNodeId = nil } }
                    .gesture(panGesture)
                    .simultaneousGesture(zoomGesture)

                // Connection lines
                Canvas { ctx, _ in
                    for node in map.nodes {
                        guard let pid = node.parentId, let parent = map.node(id: pid) else { continue }
                        let from = CGPoint(x: screenX(parent.x, in: geo), y: screenY(parent.y, in: geo))
                        let to   = CGPoint(x: screenX(node.x, in: geo),   y: screenY(node.y, in: geo))
                        var path = Path()
                        path.move(to: from)
                        let dy = to.y - from.y
                        path.addCurve(
                            to: to,
                            control1: CGPoint(x: from.x, y: from.y + dy * 0.5),
                            control2: CGPoint(x: to.x,   y: to.y   - dy * 0.5)
                        )
                        let sel = selectedNodeId == node.id || selectedNodeId == pid
                        ctx.stroke(path, with: .color(sel ? Color.moss.opacity(0.65) : Color.moss.opacity(0.28)),
                                   style: StrokeStyle(lineWidth: sel ? 2.5 : 1.5, lineCap: .round))
                    }
                }
                .allowsHitTesting(false)

                // Nodes
                ForEach(map.nodes) { node in
                    bubbleNode(node: node, geo: geo)
                        .position(x: screenX(node.x, in: geo), y: screenY(node.y, in: geo))
                }

                // Floating action buttons
                if let selId = selectedNodeId, let node = map.node(id: selId) {
                    actionButtons(for: node, geo: geo)
                }

                // Edit overlay
                if editingNodeId != nil {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture { cancelEdit() }
                        .transition(.opacity)

                    editCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: editingNodeId != nil)
    }

    // MARK: - Coordinate helpers

    private func screenX(_ cx: Double, in geo: GeometryProxy) -> CGFloat {
        CGFloat(cx) * scale + canvasOffset.width + geo.size.width / 2
    }

    private func screenY(_ cy: Double, in geo: GeometryProxy) -> CGFloat {
        CGFloat(cy) * scale + canvasOffset.height + geo.size.height / 3
    }

    // MARK: - Gestures

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { v in
                canvasOffset = CGSize(
                    width:  lastCanvasOffset.width  + v.translation.width,
                    height: lastCanvasOffset.height + v.translation.height
                )
            }
            .onEnded { _ in lastCanvasOffset = canvasOffset }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { v in scale = max(0.3, min(2.5, lastScale * v)) }
            .onEnded   { _ in lastScale = scale }
    }

    // MARK: - Node view

    @ViewBuilder
    private func bubbleNode(node: BubbleMapNode, geo: GeometryProxy) -> some View {
        let isSelected = selectedNodeId == node.id
        let isGenerating = generatingForNodeId == node.id
        let nodeW: CGFloat = node.isRoot ? 160 : 140

        Group {
            if node.isSkeleton || isGenerating {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.gardenSurface2)
                    .frame(width: nodeW, height: 60)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.07), lineWidth: 1))
                    .opacity(0.7)
            } else {
                VStack(spacing: 3) {
                    if !node.isRoot {
                        Text(kindLabel(node.kind))
                            .font(.system(size: 9, weight: .heavy))
                            .textCase(.uppercase)
                            .tracking(0.5)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .foregroundStyle(isSelected ? Color.white.opacity(0.9) : kindFg(node.kind))
                            .background(isSelected ? Color.white.opacity(0.2) : kindBg(node.kind))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Text(node.text.isEmpty ? "Tap ✏️ to edit" : node.text)
                        .font(.system(size: node.isRoot ? 13 : 11.5, weight: node.isRoot ? .bold : .medium))
                        .foregroundStyle(isSelected || node.isRoot ? Color.white : (node.text.isEmpty ? Color.gardenInk3 : Color.gardenInk))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(width: nodeW, height: 60, alignment: .center)
                .background(isSelected || node.isRoot ? Color.moss : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isSelected ? Color.mossDark : (node.isRoot ? Color.clear : kindBorderColor(node.kind)),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: (isSelected || node.isRoot) ? Color.moss.opacity(0.30) : .black.opacity(0.06),
                    radius: isSelected ? 10 : 4, y: isSelected ? 4 : 2
                )
                .scaleEffect(isSelected ? 1.04 : 1)
                .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isSelected)
            }
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 3)
                .onChanged { v in
                    let prev = nodeDragPrev[node.id] ?? v.translation
                    let dx = Double((v.translation.width  - prev.width)  / scale)
                    let dy = Double((v.translation.height - prev.height) / scale)
                    nodeDragPrev[node.id] = v.translation
                    if let idx = map.nodes.firstIndex(where: { $0.id == node.id }) {
                        map.nodes[idx].x += dx
                        map.nodes[idx].y += dy
                    }
                    if selectedNodeId != node.id {
                        withAnimation(.easeOut(duration: 0.1)) { selectedNodeId = node.id }
                    }
                }
                .onEnded { _ in
                    nodeDragPrev.removeValue(forKey: node.id)
                    onSave()
                }
        )
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedNodeId = selectedNodeId == node.id ? nil : node.id
            }
        }
    }

    // MARK: - Action buttons

    @ViewBuilder
    private func actionButtons(for node: BubbleMapNode, geo: GeometryProxy) -> some View {
        let sx = screenX(node.x, in: geo)
        let sy = screenY(node.y, in: geo)

        HStack(spacing: 8) {
            actionBtn(icon: "pencil", label: "Edit", color: Color.gardenInk) {
                withAnimation(.spring(response: 0.3)) {
                    editingNodeId = node.id
                    editingText = node.text
                }
            }

            if !node.isRoot {
                actionBtn(icon: "trash", label: "Delete", color: Color(hex: "E55151")) {
                    withAnimation(.spring(response: 0.35)) {
                        map.deleteSubtree(id: node.id)
                        selectedNodeId = nil
                        onSave()
                    }
                }
            }

            actionBtn(icon: "sparkles", label: "AI", color: Color.moss) {
                let captured = node
                selectedNodeId = nil
                Task { await addAIBranches(to: captured) }
            }

            actionBtn(icon: "plus", label: "Add", color: Color.moss) {
                addManualBranch(to: node)
                selectedNodeId = nil
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        .position(x: sx, y: sy - 56 - 28)
        .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedNodeId)
    }

    private func actionBtn(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.gardenInk3)
            }
            .frame(width: 44, height: 44)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Edit card

    private var editCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Edit bubble")
                    .font(.system(size: 11, weight: .heavy))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Color.gardenInk3)
                Spacer()
                Button { cancelEdit() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.gardenInk3)
                }
                .buttonStyle(.plain)
            }

            TextField("Bubble text…", text: $editingText, axis: .vertical)
                .font(.system(size: 15))
                .foregroundStyle(Color.gardenInk)
                .lineLimit(4)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.moss.opacity(0.4), lineWidth: 1.5)
                )

            HStack(spacing: 10) {
                Button { cancelEdit() } label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(Color.gardenInk2)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.10), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button { commitEdit() } label: {
                    Text("Save")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(.white)
                        .background(editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.moss.opacity(0.45) : Color.moss)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .background(Color.gardenSurface2)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: -4)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Edit actions

    private func cancelEdit() {
        editingNodeId = nil
        editingText = ""
    }

    private func commitEdit() {
        guard let nodeId = editingNodeId,
              let idx = map.nodes.firstIndex(where: { $0.id == nodeId }),
              !editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelEdit()
            return
        }
        map.nodes[idx].text = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave()
        cancelEdit()
    }

    // MARK: - Branch actions

    private func addManualBranch(to parent: BubbleMapNode) {
        let positions = BubbleMap.childPositions(parentX: parent.x, parentY: parent.y, count: 1)
        var newNode = BubbleMapNode(text: "", kind: .pathway, x: positions[0].x, y: positions[0].y, parentId: parent.id)
        let newId = newNode.id
        map.nodes.append(newNode)
        onSave()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3)) {
                editingNodeId = newId
                editingText = ""
            }
        }
    }

    @MainActor
    private func addAIBranches(to parent: BubbleMapNode) async {
        let existing = map.children(of: parent.id)
        let count = 3
        var positions = BubbleMap.childPositions(parentX: parent.x, parentY: parent.y + Double(existing.count) * 0, count: count)

        // Offset Y below existing children
        let childYBase = parent.y + 160 + (existing.isEmpty ? 0 : 170)
        positions = BubbleMap.childPositions(parentX: parent.x, parentY: existing.isEmpty ? parent.y : parent.y + 170, count: count)

        var skeletonIds: [UUID] = []
        for pos in positions {
            let skeleton = BubbleMapNode(text: "", kind: .pathway, x: pos.x, y: pos.y, parentId: parent.id, isSkeleton: true)
            skeletonIds.append(skeleton.id)
            map.nodes.append(skeleton)
        }

        let result = await Self.runInference(for: parent.text)

        var suggestions: [IdeaSuggestion] = result.map { Array($0.suggestions.prefix(3)) } ?? []
        while suggestions.count < 3 {
            let defaults: [IdeaSuggestion] = [
                IdeaSuggestion(kind: .question,   text: "What problem does this solve?"),
                IdeaSuggestion(kind: .pathway,    text: "How might this grow over time?"),
                IdeaSuggestion(kind: .assumption, text: "What are you assuming here?"),
            ]
            suggestions.append(defaults[suggestions.count % 3])
        }

        for (i, skelId) in skeletonIds.enumerated() {
            if let idx = map.nodes.firstIndex(where: { $0.id == skelId }) {
                map.nodes[idx].text = suggestions[i].text
                map.nodes[idx].kind = suggestions[i].kind
                map.nodes[idx].isSkeleton = false
            }
        }
        onSave()
    }

    private static func runInference(for text: String) async -> IdeaAssistanceResult? {
        let request = IdeaAssistanceRequest(title: text, body: text, assistanceLevel: .standard)
        return try? await Task.detached(priority: .userInitiated) {
            try await LlamaCppLocalIdeaProvider().suggestions(for: request)
        }.value
    }

    // MARK: - Kind helpers

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
}
