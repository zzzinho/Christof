import SwiftUI

/// 보름달 강조. 밤에 달 자리에 크고 따뜻한 후광을 두른다. 낮이거나 달이 지평선 아래면 그리지 않는다.
public struct FullMoonDecoration: SceneLayerProvider {
    public init() {}

    @MainActor public func layers(for context: SceneContext) -> [WindowLayer] {
        guard context.sun.altitude < 0,
              let position = CelestialPosition.moon(context.moon, latitude: context.region.latitude)
        else { return [] }
        return [
            // 달 바로 뒤, 별 앞.
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
                                .init(color: warm.color(0.7), location: 0),
                                .init(color: warm.color(0.3), location: 0.45),
                                .init(color: warm.color(0), location: 1),
                            ]),
                            center: center, startRadius: moon, endRadius: halo))
                    ctx.stroke(Path(ellipseIn: CGRect(center: center, radius: moon * 1.6)), with: .color(warm.color(0.35)), lineWidth: moon * 0.12)
                }
            }
        ]
    }
}
