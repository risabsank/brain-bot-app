//
//  RootTabView.swift
//  BrainBot

internal import SwiftUI

enum GardenTab { case ideas, sprint }

struct RootTabView: View {
    @EnvironmentObject private var store: IdeaStore
    @State private var activeTab: GardenTab = .ideas
    @State private var plantSheetOpen = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch activeTab {
                case .ideas:
                    IdeaFeedView(onPlant: { plantSheetOpen = true },
                                 onSprint: { withAnimation { activeTab = .sprint } })
                case .sprint:
                    DailyChallengeView(onBack: { withAnimation { activeTab = .ideas } })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if activeTab == .ideas {
                FloatingTabBar(activeTab: $activeTab, onPlant: { plantSheetOpen = true })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $plantSheetOpen) {
            CaptureIdeaView()
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .animation(.easeInOut(duration: 0.22), value: activeTab)
    }
}

// MARK: - Floating pill tab bar

private struct FloatingTabBar: View {
    @Binding var activeTab: GardenTab
    let onPlant: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "leaf.fill", label: "Ideas", active: activeTab == .ideas) {
                withAnimation(.easeOut(duration: 0.18)) { activeTab = .ideas }
            }

            // Center FAB
            Button(action: onPlant) {
                Circle()
                    .fill(Color.moss)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .shadow(
                        color: Color.moss.opacity(0.40),
                        radius: 9, y: 4
                    )
            }
            .offset(y: -10)
            .padding(.horizontal, 6)

            TabBarItem(icon: "target", label: "Sprint", active: activeTab == .sprint) {
                withAnimation(.easeOut(duration: 0.18)) { activeTab = .sprint }
            }
        }
        .frame(height: 68)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.85))
                .background(
                    Material.regularMaterial,
                    in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.14), radius: 14, y: 6)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }
}

private struct TabBarItem: View {
    let icon: String
    let label: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10.5, weight: .bold))
            }
            .foregroundStyle(active ? Color.moss : Color.gardenInk3)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: active)
    }
}
