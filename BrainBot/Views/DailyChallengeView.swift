//
//  DailyChallengeView.swift
//  BrainBot

internal import SwiftUI

struct DailyChallengeView: View {
    @EnvironmentObject private var store: IdeaStore
    let onBack: () -> Void

    @State private var entry = ""
    @State private var pops: [(id: UUID, text: String)] = []
    @State private var celebrate = false
    private let challenge = AlternateUsesChallenge.today()
    private let goal = 10

    private var isComplete: Bool { store.dailyEntries.count >= goal }
    private var progress: CGFloat { min(1, CGFloat(store.dailyEntries.count) / CGFloat(goal)) }

    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [Color(hex: "143B2D"), Color(hex: "0E2A20")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative watermark icon
            Image(systemName: "paperclip")
                .font(.system(size: 200))
                .foregroundStyle(Color(hex: "A6E5C9").opacity(0.08))
                .rotationEffect(.degrees(15))
                .offset(x: 80, y: -100)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                navBar
                heroSection
                progressPips
                entriesPreview
                Spacer()
                inputBar
            }

            // Floating sprout pops
            ForEach(pops, id: \.id) { pop in
                SproutPopView(text: pop.text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 100)
            }

            // Celebration overlay
            if celebrate {
                CelebrationModal(entries: store.dailyEntries) {
                    celebrate = false
                } onDone: {
                    celebrate = false
                    onBack()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: celebrate)
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Day \(store.streak) · Daily Sprint")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: "A6E5C9"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "A6E5C9").opacity(0.18))
                .clipShape(Capsule())

            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 8)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 6) {
            Text("Today's object")
                .font(.system(size: 12, weight: .bold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color(hex: "A6E5C9"))

            Text(challenge.object)
                .font(.display(64))
                .foregroundStyle(.white)
                .tracking(-2)

            Text(challenge.prompt)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(maxWidth: 280)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }

    // MARK: - Progress pips

    private var progressPips: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(0..<goal, id: \.self) { i in
                    let on = i < store.dailyEntries.count
                    Circle()
                        .fill(on ? Color(hex: "A6E5C9") : Color.white.opacity(0.08))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Group {
                                if on {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color(hex: "143B2D"))
                                } else {
                                    Text("\(i + 1)")
                                        .font(.display(12, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.35))
                                }
                            }
                        )
                        .shadow(color: on ? Color(hex: "A6E5C9").opacity(0.4) : .clear, radius: 4, y: 2)
                        .scaleEffect(on ? 1 : 0.85)
                        .animation(.spring(response: 0.3), value: on)
                }
            }

            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(store.dailyEntries.count)")
                        .font(.display(16, weight: .bold))
                        .foregroundStyle(Color(hex: "A6E5C9"))
                    Text("/ \(goal) sprouts")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "A6E5C9").opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 14)
    }

    // MARK: - Last 3 entries preview

    private var entriesPreview: some View {
        VStack(spacing: 6) {
            ForEach(Array(store.dailyEntries.suffix(3).reversed().enumerated()), id: \.offset) { idx, text in
                HStack(spacing: 8) {
                    Text("\(store.dailyEntries.count - idx).")
                        .font(.display(12, weight: .bold))
                        .foregroundStyle(Color(hex: "A6E5C9"))
                        .frame(minWidth: 20, alignment: .trailing)
                    Text(text)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(1 - Double(idx) * 0.25))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.06 - Double(idx) * 0.01))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField(
                isComplete ? "Sprint complete! Tap to see sprouts." : "Use it as a…",
                text: $entry
            )
            .disabled(isComplete)
            .font(.system(size: 15))
            .foregroundStyle(Color.gardenInk)
            .onSubmit { addEntry() }

            Button(action: addEntry) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(entry.trimmingCharacters(in: .whitespaces).isEmpty || isComplete ? Color.gardenInk3 : Color.moss)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.moss.opacity(entry.isEmpty || isComplete ? 0 : 0.30), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .disabled(entry.trimmingCharacters(in: .whitespaces).isEmpty || isComplete)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.20), radius: 14, y: 7)
        .padding(.horizontal, 18)
        .padding(.bottom, 30)
    }

    // MARK: - Actions

    private func addEntry() {
        let text = entry.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isComplete else { return }

        store.saveChallengeEntry(text)
        let popID = UUID()
        pops.append((id: popID, text: text))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            pops.removeAll { $0.id == popID }
        }
        entry = ""

        if store.dailyEntries.count >= goal {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                store.grantXP(30)
                withAnimation { celebrate = true }
            }
        }
    }
}

// MARK: - Sprout pop animation

private struct SproutPopView: View {
    let text: String
    @State private var visible = false
    @State private var offsetY: CGFloat = 0

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 13))
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
        }
        .foregroundStyle(Color(hex: "143B2D"))
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color(hex: "A6E5C9"))
        .clipShape(Capsule())
        .shadow(color: Color(hex: "A6E5C9").opacity(0.4), radius: 6, y: 3)
        .opacity(visible ? 1 : 0)
        .offset(y: offsetY)
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) { visible = true }
            withAnimation(.easeIn(duration: 0.7).delay(0.2)) { offsetY = -70; visible = false }
        }
    }
}

// MARK: - Celebration modal

private struct CelebrationModal: View {
    let entries: [String]
    let onClose: () -> Void
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            ConfettiLayer()

            VStack(spacing: 0) {
                // Trophy
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFC678"), Color.amber],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                }
                .shadow(color: Color.amber.opacity(0.45), radius: 14, y: 6)
                .padding(.bottom, 14)

                Text("Sprint complete!")
                    .font(.display(30))
                    .foregroundStyle(Color.gardenInk)

                Text("You planted \(entries.count) sprouts today.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gardenInk2)
                    .padding(.top, 4)
                    .padding(.bottom, 16)

                // XP row
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.mossSoft)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.amber)
                        )
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Earned")
                            .font(.system(size: 12, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(0.4)
                            .foregroundStyle(Color.gardenInk3)
                        Text("+30 XP · 🔥 streak +1")
                            .font(.display(18))
                            .foregroundStyle(Color.gardenInk)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .padding(.bottom, 14)

                // Sprouts list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { i, text in
                            HStack(spacing: 8) {
                                Text("\(i + 1).")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.moss)
                                    .frame(minWidth: 20, alignment: .trailing)
                                Text(text)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.gardenInk)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                            if i < entries.count - 1 {
                                Divider().opacity(0.5)
                            }
                        }
                    }
                }
                .frame(maxHeight: 130)
                .padding(.bottom, 14)

                Button(action: onDone) {
                    HStack(spacing: 8) {
                        Text("Back to garden")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(GardenButtonStyle())
            }
            .padding(24)
            .background(Color.gardenSurface2)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.40), radius: 24, y: 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 36)
        }
    }
}

// MARK: - Confetti

private struct ConfettiLayer: View {
    private struct Dot: Identifiable {
        let id = UUID()
        let x: CGFloat
        let size: CGFloat
        let color: Color
        let delay: Double
        let isCircle: Bool
    }

    private let dots: [Dot] = (0..<30).map { i in
        Dot(
            x: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 6...12),
            color: [Color.amber, Color.sprout, Color(hex: "E66B5C"), Color(hex: "A6E5C9")][i % 4],
            delay: Double.random(in: 0...0.6),
            isCircle: i % 2 == 0
        )
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(dots) { dot in
                ConfettoPiece(size: dot.size, color: dot.color, isCircle: dot.isCircle, delay: dot.delay)
                    .position(x: dot.x * geo.size.width, y: -20)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

private struct ConfettoPiece: View {
    let size: CGFloat
    let color: Color
    let isCircle: Bool
    let delay: Double

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0

    var body: some View {
        Group {
            if isCircle {
                Circle().fill(color).frame(width: size, height: size)
            } else {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color).frame(width: size, height: size)
            }
        }
        .rotationEffect(.degrees(rotation))
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation(.linear(duration: 2.2).delay(delay)) {
                offsetY = 900
                rotation = 720
                opacity = 0
            }
        }
    }
}
