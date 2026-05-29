//
//  SplashView.swift
//  BrainBot

internal import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void

    @State private var vine1: CGFloat = 0
    @State private var vine2: CGFloat = 0
    @State private var vine3: CGFloat = 0
    @State private var vine4: CGFloat = 0
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textSlide: CGFloat = 20
    @State private var leaf1: Double = 0
    @State private var leaf2: Double = 0
    @State private var leaf3: Double = 0
    @State private var screenOpacity: Double = 1

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "0A1F18").ignoresSafeArea()
                vines(in: geo)
                leafAccents(in: geo)
                centerContent
            }
        }
        .opacity(screenOpacity)
        .onAppear(perform: animate)
    }

    private var centerContent: some View {
        VStack(spacing: 22) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.moss)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38)
                        .foregroundStyle(Color(hex: "E2EFE3"))
                )
                .shadow(color: Color.moss.opacity(0.55), radius: 22, y: 8)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

            VStack(spacing: 6) {
                Text("Idea\nGarden.")
                    .font(.display(52))
                    .foregroundStyle(.white)
                    .tracking(-1.5)
                    .multilineTextAlignment(.center)

                Text("Capture sparks. Tend them daily.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .opacity(textOpacity)
            .offset(y: textSlide)
        }
    }

    @ViewBuilder
    private func vines(in geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height

        // Top-left vine sweeping right
        SplashVinePath(
            start: CGPoint(x: 0,        y: h * 0.16),
            c1:    CGPoint(x: w * 0.22, y: h * 0.04),
            c2:    CGPoint(x: w * 0.44, y: h * 0.20),
            end:   CGPoint(x: w * 0.60, y: h * 0.16)
        )
        .trim(from: 0, to: vine1)
        .stroke(Color(hex: "2D7A50"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

        // Branch off top-left vine going down
        SplashVinePath(
            start: CGPoint(x: w * 0.28, y: h * 0.10),
            c1:    CGPoint(x: w * 0.26, y: h * 0.26),
            c2:    CGPoint(x: w * 0.14, y: h * 0.36),
            end:   CGPoint(x: w * 0.10, y: h * 0.44)
        )
        .trim(from: 0, to: vine1 * 0.65)
        .stroke(Color(hex: "1F5C46"), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

        // Bottom-right vine sweeping left
        SplashVinePath(
            start: CGPoint(x: w,        y: h * 0.80),
            c1:    CGPoint(x: w * 0.78, y: h * 0.90),
            c2:    CGPoint(x: w * 0.55, y: h * 0.76),
            end:   CGPoint(x: w * 0.40, y: h * 0.82)
        )
        .trim(from: 0, to: vine2)
        .stroke(Color(hex: "2D7A50"), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        // Top-right vine going down
        SplashVinePath(
            start: CGPoint(x: w,        y: h * 0.10),
            c1:    CGPoint(x: w * 0.80, y: h * 0.05),
            c2:    CGPoint(x: w * 0.70, y: h * 0.20),
            end:   CGPoint(x: w * 0.66, y: h * 0.32)
        )
        .trim(from: 0, to: vine3)
        .stroke(Color(hex: "1F5C46").opacity(0.70), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

        // Bottom-left vine going up
        SplashVinePath(
            start: CGPoint(x: 0,        y: h * 0.86),
            c1:    CGPoint(x: w * 0.18, y: h * 0.93),
            c2:    CGPoint(x: w * 0.30, y: h * 0.80),
            end:   CGPoint(x: w * 0.34, y: h * 0.68)
        )
        .trim(from: 0, to: vine4)
        .stroke(Color(hex: "2D7A50").opacity(0.60), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    }

    @ViewBuilder
    private func leafAccents(in geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height

        Group {
            Image(systemName: "leaf.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "4CAF75").opacity(0.75))
                .rotationEffect(.degrees(-35))
                .position(x: w * 0.28, y: h * 0.10)
                .opacity(leaf1)

            Image(systemName: "leaf.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "4CAF75").opacity(0.65))
                .rotationEffect(.degrees(50))
                .position(x: w * 0.60, y: h * 0.16)
                .opacity(leaf2)

            Image(systemName: "leaf.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "4CAF75").opacity(0.55))
                .rotationEffect(.degrees(-20))
                .position(x: w * 0.40, y: h * 0.82)
                .opacity(leaf3)
        }
        .allowsHitTesting(false)
    }

    private func animate() {
        withAnimation(.easeInOut(duration: 1.30))              { vine1 = 1 }
        withAnimation(.easeInOut(duration: 1.10).delay(0.18)) { vine2 = 1 }
        withAnimation(.easeInOut(duration: 0.95).delay(0.30)) { vine3 = 1 }
        withAnimation(.easeInOut(duration: 0.95).delay(0.38)) { vine4 = 1 }

        withAnimation(.easeOut(duration: 0.25).delay(0.65)) { leaf1 = 1 }
        withAnimation(.easeOut(duration: 0.25).delay(0.80)) { leaf2 = 1 }
        withAnimation(.easeOut(duration: 0.25).delay(0.90)) { leaf3 = 1 }

        withAnimation(.spring(response: 0.52, dampingFraction: 0.60).delay(0.82)) {
            logoScale   = 1
            logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.55).delay(1.12)) {
            textOpacity = 1
            textSlide   = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            withAnimation(.easeIn(duration: 0.42)) { screenOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) { onFinish() }
        }
    }
}

private struct SplashVinePath: Shape {
    let start, c1, c2, end: CGPoint

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: start)
        p.addCurve(to: end, control1: c1, control2: c2)
        return p
    }
}
