import SwiftUI

struct StarEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        let palette = SkyPalette(context)
        if let condition = context.weather?.condition, !condition.showsStars { return [] }
        let opacity = (1 - palette.daylight / 0.4) * (1 - palette.gloom * 2)
        guard opacity > 0.05 else { return [] }
        return [
            WindowLayer(id: "stars", depth: .stars) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    var random = SeededRandom(seed: 3)
                    for _ in 0..<70 {
                        let center = CGPoint(x: random(0...1) * size.width, y: random(0...0.66) * size.height)
                        let radius = u * random(0.003...0.008)
                        ctx.fill(Path(ellipseIn: CGRect(center: center, radius: radius)), with: .color(.white.opacity(opacity * random(0.35...1))))
                    }
                }
            }
        ]
    }
}
