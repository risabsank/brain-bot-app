//
//  AlternateUsesChallenge.swift
//  BrainBot
//
//  Created by Risab Sankar on 4/15/26.
//

import Foundation

struct AlternateUsesChallenge {
    let object: String
    let prompt: String

    static let objects = [
        "Paperclip", "Coffee Mug", "Umbrella", "Rubber Band", "Towel",
        "Cardboard Box", "Pencil", "Shoebox", "Old T-Shirt", "Plastic Bottle"
    ]

    static func today() -> AlternateUsesChallenge {
        let daySeed = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let item = objects[(daySeed - 1) % objects.count]
        return AlternateUsesChallenge(
            object: item,
            prompt: "List as many alternate uses as you can in 10 minutes."
        )
    }
}
