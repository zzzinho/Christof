import SwiftUI

public struct FullMoonDecoration: SceneLayerProvider {
    public init() {}

    @MainActor public func layers(for context: SceneContext) -> [WindowLayer] {
        guard case let (position, visibility)? = MoonEffect.visibleMoon(in: context) else { return [] }
        return [
            WindowLayer(id: "decoration.fullMoon", depth: LayerDepth(LayerDepth.celestialBody.value - 1)) {
                Canvas { ctx, size in
                    let center = CGPoint(x: position.x * size.width, y: position.y * size.height)
                    let moon = min(size.width, size.height) * MoonEffect.radiusRatio
                    let halo = moon * 5
                    let warm = RGB(hex: 0xFFD98A)
                    ctx.fill(
                        Path(ellipseIn: CGRect(center: center, radius: halo)),
                        with: .radialGradient(
                            Gradient(stops: [
                                .init(color: warm.color(0.7 * visibility), location: 0),
                                .init(color: warm.color(0.3 * visibility), location: 0.45),
                                .init(color: warm.color(0), location: 1),
                            ]),
                            center: center, startRadius: moon, endRadius: halo))
                    ctx.stroke(Path(ellipseIn: CGRect(center: center, radius: moon * 1.6)), with: .color(warm.color(0.35 * visibility)), lineWidth: moon * 0.12)
                }
            }
        ]
    }
}
