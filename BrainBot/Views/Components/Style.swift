//
//  Style.swift
//  BrainBot

internal import SwiftUI

// MARK: - Design tokens (Idea Garden hi-fi palette)

extension Color {
    static let moss           = Color(hex: "1F5C46")
    static let mossDark       = Color(hex: "143B2D")
    static let mossSoft       = Color(hex: "D7E6DC")
    static let sprout         = Color(hex: "67B27E")
    static let amber          = Color(hex: "E89A3C")
    static let amberDeep      = Color(hex: "B86F18")
    static let gardenInk      = Color(hex: "1B2A22")
    static let gardenInk2     = Color(hex: "4A5851")
    static let gardenInk3     = Color(hex: "8A938E")
    static let gardenBg       = Color(hex: "F4ECDB")
    static let gardenSurface2 = Color(hex: "FAF3E2")
    static let gardenBgDeep   = Color(hex: "E9DFC8")

    // Legacy aliases (AssistanceResultsView uses these)
    static let midnightGreen  = Color(hex: "1F5C46")
    static let cloud          = Color(hex: "F4ECDB")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        self.init(
            red:   Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8)  & 0xFF) / 255,
            blue:  Double( int        & 0xFF) / 255
        )
    }
}

// MARK: - Typography

extension Font {
    static func display(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Shared modifiers

struct CardContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardContainer()) }
}

// MARK: - Garden primary button style

enum GardenButtonKind { case primary, soft, amber }

struct GardenButtonStyle: ButtonStyle {
    var kind: GardenButtonKind = .primary
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(foreground)
            .background(bg.opacity(isDisabled ? 0.5 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: shadowColor.opacity(isDisabled ? 0 : 1), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return .white
        case .soft:    return .mossDark
        case .amber:   return .amberDeep
        }
    }

    private var bg: Color {
        switch kind {
        case .primary: return .moss
        case .soft:    return .mossSoft
        case .amber:   return Color(hex: "F4B65E")
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .primary: return Color.moss.opacity(0.30)
        case .soft:    return .clear
        case .amber:   return Color.amber.opacity(0.35)
        }
    }
}

// MARK: - Reusable small components

struct StreakPillView: View {
    let days: Int
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
            Text("\(days)")
                .font(.system(size: 13, weight: .heavy))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(colors: [Color(hex: "FFC678"), Color.amber],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(Capsule())
        .shadow(color: Color.amber.opacity(0.45), radius: 4, y: 2)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.60).delay(0.3)) {
                scale   = 1
                opacity = 1
            }
        }
    }
}

struct LevelBarView: View {
    let level: Int
    let xp: Int
    let xpMax: Int

    @State private var displayedProgress: CGFloat = 0

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.mossSoft, lineWidth: 3)
                    .frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: displayedProgress)
                    .stroke(Color.sprout, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 32, height: 32)
                Circle()
                    .fill(Color.moss)
                    .frame(width: 24, height: 24)
                Text("\(level)")
                    .font(.display(12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.35)) {
                displayedProgress = CGFloat(xp) / CGFloat(max(xpMax, 1))
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(active ? .white : Color.gardenInk)
                .background(active ? Color.moss : Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.black.opacity(active ? 0 : 0.10), lineWidth: 1.2)
                )
                .shadow(color: active ? Color.moss.opacity(0.20) : .clear, radius: 4, y: 1)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: active)
    }
}

struct CategoryPickerView: View {
    @Binding var value: IdeaCategory

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(IdeaCategory.allCases) { cat in
                let selected = value == cat
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { value = cat }
                } label: {
                    HStack(spacing: 10) {
                        Text(cat.emoji)
                            .font(.system(size: 20))
                        Text(cat.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(selected ? .white : Color.gardenInk)
                    .background(selected ? Color.moss : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(
                        color: selected ? Color.moss.opacity(0.25) : Color.black.opacity(0.06),
                        radius: selected ? 5 : 2, y: 2
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct HuePickerView: View {
    @Binding var value: IdeaVisualStyle

    var body: some View {
        HStack(spacing: 8) {
            ForEach(IdeaVisualStyle.allCases) { style in
                let selected = value == style
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { value = style }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 0) {
                            Circle()
                                .fill(style.ringColor)
                                .frame(width: 22, height: 22)
                                .overlay(Circle().stroke(style.backgroundColor, lineWidth: 2))
                                .padding(.bottom, 6)
                            Spacer()
                            Text(style.rawValue)
                                .font(.display(13, weight: .semibold))
                                .foregroundStyle(style.foregroundColor)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .frame(height: 88)
                        .background(style.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selected ? Color.moss : Color.clear, lineWidth: selected ? 2.5 : 0)
                        )
                        .shadow(color: .black.opacity(selected ? 0.12 : 0.05), radius: selected ? 8 : 3, y: 2)

                        if selected {
                            Circle()
                                .fill(Color.moss)
                                .frame(width: 22, height: 22)
                                .overlay(Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white))
                                .offset(x: -8, y: 8)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct StepDotsView: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<total, id: \.self) { i in
                let done = i + 1 < step
                let cur  = i + 1 == step
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(done || cur ? Color.moss : Color.black.opacity(0.13))
                    .frame(width: cur ? 26 : 7, height: 7)
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }
}

struct SuggestionBadgeView: View {
    let kind: IdeaSuggestionKind

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .heavy))
            .textCase(.uppercase)
            .tracking(0.4)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(fg)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    private var label: String {
        switch kind {
        case .question:   return "Question"
        case .pathway:    return "Pathway"
        case .assumption: return "Assumption"
        }
    }

    private var bg: Color {
        switch kind {
        case .question:   return Color(hex: "E7F0F6")
        case .pathway:    return Color.mossSoft
        case .assumption: return Color(hex: "F6E4C5")
        }
    }

    private var fg: Color {
        switch kind {
        case .question:   return Color(hex: "214F86")
        case .pathway:    return Color.mossDark
        case .assumption: return Color(hex: "7A4F12")
        }
    }
}
