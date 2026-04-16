//
//  AppEntryView.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

struct AppEntryView: View {
    @State private var isSignedIn = false

    var body: some View {
        Group {
            if isSignedIn {
                RootTabView()
            } else {
                SignInView(isSignedIn: $isSignedIn)
            }
        }
    }
}

private struct SignInView: View {
    @Binding var isSignedIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            Text("Brain Bot")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Color.midnightGreen)

            Text("Capture ideas fast, then shape them into action.")
                .font(.title3)
                .foregroundStyle(.secondary)

            Button {
                isSignedIn = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(Color.midnightGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Text("MVP UI uses a demo sign-in gate. Real auth can be attached later.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cloud)
    }
}
