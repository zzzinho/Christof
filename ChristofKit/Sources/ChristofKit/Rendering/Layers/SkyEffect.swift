import SwiftUI

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
