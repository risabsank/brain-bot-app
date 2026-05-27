//
//  AppEntryView.swift
//  BrainBot

internal import SwiftUI

struct AppEntryView: View {
    @State private var isSignedIn = false

    var body: some View {
        if isSignedIn {
            RootTabView()
        } else {
            EntryGateView(isSignedIn: $isSignedIn)
        }
    }
}

// MARK: - Entry gate

private struct EntryGateView: View {
    @Binding var isSignedIn: Bool

    var body: some View {
        ZStack {
            Color(hex: "E2EFE3").ignoresSafeArea()
            OrganicBackdrop()
            FloatingLeaves()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                logoLockup
                Spacer()
                statsTeaser
                    .padding(.bottom, 16)
                ctaSection
            }
            .padding(.horizontal, 28)
        }
    }

    // MARK: Sub-views

    private var logoLockup: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.moss)
                .frame(width: 76, height: 76)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                        .foregroundStyle(Color(hex: "E2EFE3"))
                )
                .shadow(color: Color.mossDark.opacity(0.32), radius: 14, y: 6)

            Text("Idea\nGarden.")
                .font(.display(52))
                .foregroundStyle(Color.mossDark)
                .tracking(-1.5)
                .lineSpacing(-4)

            Text("Capture sparks. Tend them daily.\nWatch ideas grow into action.")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.mossDark.opacity(0.7))
                .lineSpacing(2)
        }
    }

    private var statsTeaser: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.amber)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                )
                .shadow(color: Color.amber.opacity(0.4), radius: 5, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Today")
                    .font(.system(size: 12, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.4)
                    .foregroundStyle(Color.amberDeep)
                Text("Paperclip · Daily Sprint awaits")
                    .font(.display(16, weight: .medium))
                    .foregroundStyle(Color.gardenInk)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private var ctaSection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { isSignedIn = true }
            } label: {
                HStack(spacing: 8) {
                    Text("Step into the garden")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(GardenButtonStyle())
            .padding(.bottom, 14)

            Text("Demo sign-in · real auth attaches later")
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(Color.mossDark.opacity(0.55))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 28)
        }
    }
}

// MARK: - Organic backdrop blobs

private struct OrganicBackdrop: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "B7DAB8"), .clear],
                            center: .center, startRadius: 0, endRadius: 200
                        )
                    )
                    .frame(width: 380, height: 380)
                    .blur(radius: 8)
                    .offset(x: -80, y: -120)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "F4B65E").opacity(0.6), .clear],
                            center: .center, startRadius: 0, endRadius: 190
                        )
                    )
                    .frame(width: 360, height: 360)
                    .blur(radius: 12)
                    .offset(x: geo.size.width - 260, y: geo.size.height - 250)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Floating animated leaves

private struct FloatingLeaves: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                FloatingLeaf(x: 60,                  y: 130, size: 28, delay: 0)
                FloatingLeaf(x: geo.size.width - 73, y: 180, size: 22, delay: 1.6)
                FloatingLeaf(x: 50,                  y: 350, size: 18, delay: 3.0)
                FloatingLeaf(x: geo.size.width - 43, y: 430, size: 26, delay: 1.0)
                FloatingLeaf(x: 80,                  y: 560, size: 22, delay: 2.4)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct FloatingLeaf: View {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double

    @State private var offset: CGFloat = 0

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: size))
            .foregroundStyle(Color.moss.opacity(0.5))
            .position(x: x, y: y + offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true).delay(delay)) {
                    offset = -8
                }
            }
    }
}
