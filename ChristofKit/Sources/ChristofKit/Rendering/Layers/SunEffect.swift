import SwiftUI

struct SunEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard let position = CelestialPosition.sun(context.sun, latitude: context.region.latitude) else { return [] }
        let palette = SkyPalette(context)
        let visibility = 1 - palette.gloom * 1.25
        guard visibility > 0.05 else { return [] }
        // 지평선 가까운 해는 조금 크게 그린다(달·해 착시).
        let ratio = 0.075 * (1.3 - 0.3 * SkyPalette.smoothstep(0, 15, context.sun.altitude))
        return [
            WindowLayer(id: "sun", depth: .celestialBody) {
                Canvas { ctx, size in
                    let center = CGPoint(x: position.x * size.width, y: position.y * size.height)
                    let radius = min(size.width, size.height) * ratio
                    let glow = radius * 4.5
                    ctx.fill(
                        Path(ellipseIn: CGRect(center: center, radius: glow)),
                        with: .radialGradient(
                            Gradient(colors: [palette.sun.color(0.6 * visibility), palette.sun.color(0)]),
                            center: center, startRadius: radius * 0.6, endRadius: glow))
                    ctx.fill(Path(ellipseIn: CGRect(center: center, radius: radius)), with: .color(palette.sun.color(visibility)))
                }
            }
        ]
    }
}
