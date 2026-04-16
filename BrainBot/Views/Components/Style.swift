//
//  Styles.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

internal import SwiftUI

extension Color {
    static let midnightGreen = Color(red: 0.0, green: 0.29, blue: 0.33)
    static let cloud = Color(red: 0.97, green: 0.98, blue: 0.98)
}

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
    func cardStyle() -> some View {
        modifier(CardContainer())
    }
}
