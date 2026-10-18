import SwiftUI

public struct LayerDepth: Comparable, Hashable, Sendable {
    public let value: Double

    public init(_ value: Double) {
        self.value = value
    }

    public static func < (lhs: LayerDepth, rhs: LayerDepth) -> Bool {
        lhs.value < rhs.value
    }

    public static let sky = LayerDepth(0)
    public static let stars = LayerDepth(10)
    public static let celestialBody = LayerDepth(20)
    public static let clouds = LayerDepth(30)
    public static let landscape = LayerDepth(40)
    public static let weather = LayerDepth(50)
    public static let decoration = LayerDepth(60)
}

public enum LayerPlacement: Sendable {
    case outside
    case onFrame
}

public struct WindowLayer: Identifiable {
    public let id: String
    public let placement: LayerPlacement
    public let depth: LayerDepth
    public let view: AnyView

    @MainActor
    public init<Content: View>(id: String, placement: LayerPlacement = .outside, depth: LayerDepth, @ViewBuilder content: () -> Content) {
        self.id = id
        self.placement = placement
        self.depth = depth
        self.view = AnyView(content())
    }
}

public protocol SceneLayerProvider: Sendable {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer]
}
