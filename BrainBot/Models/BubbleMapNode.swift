//
//  BubbleMapNode.swift
//  BrainBot

import Foundation

struct BubbleMapNode: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var kind: IdeaSuggestionKind
    var x: Double
    var y: Double
    var parentId: UUID?
    var isRoot: Bool = false
    var isSkeleton: Bool = false
}

struct BubbleMap: Hashable {
    var nodes: [BubbleMapNode] = []

    var rootNode: BubbleMapNode? { nodes.first(where: { $0.isRoot }) }

    func node(id: UUID) -> BubbleMapNode? {
        nodes.first(where: { $0.id == id })
    }

    func children(of parentId: UUID) -> [BubbleMapNode] {
        nodes.filter { $0.parentId == parentId }
    }

    mutating func deleteSubtree(id: UUID) {
        let childIds = children(of: id).map { $0.id }
        for childId in childIds { deleteSubtree(id: childId) }
        nodes.removeAll { $0.id == id }
    }

    static func childPositions(parentX: Double, parentY: Double, count: Int) -> [CGPoint] {
        guard count > 0 else { return [] }
        if count == 1 { return [CGPoint(x: parentX, y: parentY + 160)] }
        let maxWidth: Double = 340
        let spacing = maxWidth / Double(count - 1)
        return (0..<count).map { i in
            CGPoint(x: parentX - maxWidth / 2 + spacing * Double(i), y: parentY + 160)
        }
    }
}
