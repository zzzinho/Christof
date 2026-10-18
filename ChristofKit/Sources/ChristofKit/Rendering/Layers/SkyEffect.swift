import SwiftUI

/// 해 고도·날씨에 따른 하늘 그라데이션.
struct SkyEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        let palette = SkyPalette(context)
        return [
            WindowLayer(id: "sky", depth: .sky) {
                LinearGradient(
                    colors: [palette.zenith.color, palette.zenith.mixed(with: palette.horizon, 0.45).color, palette.horizon.color],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: CelestialPosition.horizon))
            }
        ]
    }
}
