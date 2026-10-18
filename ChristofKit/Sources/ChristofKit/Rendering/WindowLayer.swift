import SwiftUI

/// 레이어 쌓는 순서. 값이 작을수록 뒤(먼 곳)에 그린다. 새 깊이가 필요하면 상수를 추가하지 않고 `LayerDepth(값)` 을 써도 된다.
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

/// 레이어를 그릴 자리.
public enum LayerPlacement: Sendable {
    /// 유리 너머 풍경. 유리 영역에 잘리고 창살·유리 반사 아래에 놓인다.
    case outside
    /// 창틀 위. 창문 전체 영역에 그려지고 창틀보다 위에 놓인다.
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

/// 장면 정보에서 창문에 그릴 레이어를 만든다. 효과 하나가 타입 하나다.
/// 새 효과는 이 프로토콜을 따르는 타입을 추가해 `WindowSceneComposer.standardProviders` 나 `Occasion.decorations` 에 넣는다.
public protocol SceneLayerProvider: Sendable {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer]
}
