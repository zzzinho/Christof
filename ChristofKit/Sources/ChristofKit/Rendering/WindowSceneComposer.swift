import SwiftUI

/// 기본 효과와 진행 중인 이벤트 장식의 레이어를 모아 깊이 순으로 정렬한다.
@MainActor
public struct WindowSceneComposer {
    private let providers: [any SceneLayerProvider]

    public init(providers: [any SceneLayerProvider] = WindowSceneComposer.standardProviders) {
        self.providers = providers
    }

    public func layers(for context: SceneContext) -> [WindowLayer] {
        let sources = providers + context.occasions.flatMap(\.decorations)
        // 함께 진행 중인 이벤트 둘이 같은 장식을 넣으면 id 가 겹친다. 우선순위가 높은 쪽 하나만 남겨 ForEach id 중복을 피한다.
        var seen = Set<String>()
        let layers = sources.flatMap { $0.layers(for: context) }.filter { seen.insert($0.id).inserted }
        // sorted 는 안정 정렬이라 같은 깊이는 등록 순서를 지킨다.
        return layers.sorted { $0.depth < $1.depth }
    }
}
