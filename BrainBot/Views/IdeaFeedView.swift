//
//  IdeaFeedView.swift
//  BrainBot

internal import SwiftUI

struct IdeaFeedView: View {
    @EnvironmentObject private var store: IdeaStore
    let onPlant: () -> Void
    let onSprint: () -> Void

    @State private var activeChip: IdeaCategory? = nil
    @State private var searchText = ""
    @State private var isSearchOpen = false
    @State private var selectedIdea: Idea? = nil

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    private var filteredIdeas: [Idea] {
        var list = store.ideas
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { ($0.title + " " + $0.body).lowercased().contains(q) }
        }
        if let chip = activeChip {
            list = list.filter { $0.category == chip }
        }
        return list
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            scrollContent
        }
        .background(Color.gardenBg)
        .sheet(isPresented: $isSearchOpen) {
            SearchSheetView(query: $searchText)
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedIdea) { idea in
            IdeaDetailView(idea: idea)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 0) {
            greetingRow
                .padding(.horizontal, 18)
                .padding(.top, 56)
                .padding(.bottom, 12)

            statsRow
                .padding(.horizontal, 18)
                .padding(.bottom, 14)

            searchRow
                .padding(.horizontal, 18)
                .padding(.bottom, 10)

            filterChips
                .padding(.bottom, 8)
        }
        .background(Color.gardenBg)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var greetingRow: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 12, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundStyle(Color.gardenInk3)
                Text("Your garden")
                    .font(.display(30))
                    .foregroundStyle(Color.gardenInk)
            }
            Spacer()
            StreakPillView(days: store.streak)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            sprintCard
            todayWidget
        }
        .frame(height: 130)
    }

    private var sprintCard: some View {
        Button(action: onSprint) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color(hex: "A6E5C9"))
                        Text("Daily Sprint")
                            .font(.system(size: 10.5, weight: .heavy))
                            .textCase(.uppercase)
                            .tracking(0.6)
                            .foregroundStyle(Color(hex: "A6E5C9"))
                    }
                    Text("Paperclip")
                        .font(.display(19))
                        .foregroundStyle(.white)
                    Text("Tap to play · 10 min")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Image(systemName: "paperclip")
                    .font(.system(size: 72))
                    .foregroundStyle(Color(hex: "A6E5C9").opacity(0.18))
                    .rotationEffect(.degrees(-12))
                    .padding(.trailing, -10)
                    .padding(.bottom, -16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.moss, Color.mossDark],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .clipped()
            .shadow(color: Color.moss.opacity(0.30), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var todayWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today")
                .font(.system(size: 10.5, weight: .heavy))
                .textCase(.uppercase)
                .tracking(0.6)
                .foregroundStyle(Color.gardenInk3)

            Spacer()

            HStack(alignment: .bottom, spacing: 5) {
                Text("+\(store.sproutsToday)")
                    .font(.display(30))
                    .foregroundStyle(Color.moss)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sprout)
                    .padding(.bottom, 3)
            }
            Text("sprouts planted")
                .font(.system(size: 11))
                .foregroundStyle(Color.gardenInk2)
                .padding(.bottom, 8)

            LevelBarView(level: store.level, xp: store.xp, xpMax: 100)
        }
        .padding(14)
        .frame(width: 128)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private var searchRow: some View {
        HStack(spacing: 8) {
            Button { isSearchOpen = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gardenInk3)
                    Text(searchText.isEmpty ? "Search seeds…" : searchText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(searchText.isEmpty ? Color.gardenInk3 : Color.gardenInk)
                    Spacer()
                }
                .frame(height: 42)
                .padding(.horizontal, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
            }
            .buttonStyle(.plain)

            Button { searchText = "" } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gardenInk)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                FilterChip(label: "All",          active: activeChip == nil)        { activeChip = nil }
                FilterChip(label: "⚡ Quick",      active: activeChip == .quickWin)  { activeChip = activeChip == .quickWin    ? nil : .quickWin }
                FilterChip(label: "🧪 Experiment", active: activeChip == .experiment) { activeChip = activeChip == .experiment  ? nil : .experiment }
                FilterChip(label: "🎨 Creator",    active: activeChip == .creatorMode) { activeChip = activeChip == .creatorMode ? nil : .creatorMode }
                FilterChip(label: "🌳 Long term",  active: activeChip == .longTerm)   { activeChip = activeChip == .longTerm    ? nil : .longTerm }
            }
            .padding(.horizontal, 18)
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            if filteredIdeas.isEmpty {
                emptyState
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(filteredIdeas.enumerated()), id: \.element.id) { idx, idea in
                        SeedCardView(idea: idea, index: idx)
                            .onTapGesture { selectedIdea = idea }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            BreathingLeafBadge()
                .shadow(color: Color.moss.opacity(0.15), radius: 14, y: 6)

            Text(searchText.isEmpty ? "Your garden is empty" : "No seeds match")
                .font(.display(22))
                .foregroundStyle(Color.gardenInk)

            Text(
                searchText.isEmpty
                    ? "Plant your first seed — even a half-formed thought counts."
                    : "Try different words, or plant a new seed."
            )
            .font(.system(size: 14))
            .foregroundStyle(Color.gardenInk2)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .frame(maxWidth: 240)

            if searchText.isEmpty {
                Button(action: onPlant) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Plant your first seed")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 13)
                    .foregroundStyle(.white)
                    .background(Color.moss)
                    .clipShape(Capsule())
                    .shadow(color: Color.moss.opacity(0.30), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Breathing empty-state badge

private struct BreathingLeafBadge: View {
    @State private var scale: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.mossSoft)
            .frame(width: 96, height: 96)
            .overlay(
                Image(systemName: "leaf.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.moss)
            )
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    scale = 1.06
                }
            }
    }
}

// MARK: - Seed card

struct SeedCardView: View {
    let idea: Idea
    var index: Int = 0

    @State private var appeared = false

    var body: some View {
        let dark = idea.visualStyle.isNight
        let fg2  = dark ? Color(hex: "E6F0E5").opacity(0.7) : Color.black.opacity(0.62)

        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 4) {
                Image(systemName: idea.category.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(idea.category.rawValue)
                    .font(.system(size: 10.5, weight: .heavy))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .lineLimit(1)
            }
            .foregroundStyle(dark ? idea.visualStyle.foregroundColor : Color.moss)

            Text(idea.title)
                .font(.display(17))
                .foregroundStyle(idea.visualStyle.foregroundColor)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(idea.body)
                .font(.system(size: 12))
                .foregroundStyle(fg2)
                .lineLimit(3)
                .lineSpacing(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            HStack(spacing: 0) {
                // Growth pips
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(
                                i < idea.growthLevel
                                    ? (dark ? Color(hex: "9DD3B0") : Color.sprout)
                                    : (dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08))
                            )
                            .frame(width: 14, height: 14)
                            .overlay(
                                Group {
                                    if i < idea.growthLevel {
                                        Image(systemName: "leaf.fill")
                                            .font(.system(size: 7))
                                            .foregroundStyle(dark ? Color(hex: "143B2D") : Color(hex: "0E3D24"))
                                    }
                                }
                            )
                    }
                }
                Spacer()
                if idea.audioRecordingURL != nil {
                    Image(systemName: "waveform")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(dark ? Color(hex: "9DD3B0") : Color.moss)
                }
            }
        }
        .padding(14)
        .frame(minHeight: 168, alignment: .topLeading)
        .background(idea.visualStyle.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            ZStack(alignment: .topTrailing) {
                Color.clear
                Text(idea.category.emoji)
                    .font(.system(size: 30))
                    .opacity(0.18)
                    .padding(8)
            }
        )
        .shadow(
            color: dark ? .black.opacity(0.22) : .black.opacity(0.06),
            radius: dark ? 7 : 6, y: dark ? 3 : 4
        )
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.88)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            let delay = Double(min(index, 7)) * 0.055
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Search sheet

struct SearchSheetView: View {
    @Binding var query: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Search seeds")
                    .font(.display(22))
                    .foregroundStyle(Color.gardenInk)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.gardenInk2)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.moss)
                    .font(.system(size: 16))
                TextField("Title or body…", text: $query)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gardenInk)
                    .onSubmit { dismiss() }
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gardenInk3)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.moss, lineWidth: 1.5)
            )
            .shadow(color: Color.moss.opacity(0.10), radius: 8, y: 3)
            .padding(.horizontal, 20)

            Spacer()

            Button { dismiss() } label: {
                Text("Search")
            }
            .buttonStyle(GardenButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.gardenSurface2.ignoresSafeArea())
    }
}
