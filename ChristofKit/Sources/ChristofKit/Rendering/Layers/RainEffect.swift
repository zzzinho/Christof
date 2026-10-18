import SwiftUI

/// 비·이슬비. 뇌우에도 비가 내린다. 세기만큼 빗줄기가 많아진다.
struct RainEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard let weather = context.weather, [.drizzle, .rain, .thunderstorm].contains(weather.condition) else { return [] }
        let drizzle = weather.condition == .drizzle
        let count = drizzle ? 40 + Int(60 * weather.intensity) : 70 + Int(130 * weather.intensity)
        let opacity = 0.35 + 0.25 * SkyPalette(context).daylight
        return [
            WindowLayer(id: "rain", depth: .weather) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    let length = size.height * (drizzle ? 0.035 : 0.08)
                    var random = SeededRandom(seed: 17)
                    var drops = Path()
                    for _ in 0..<count {
                        let start = CGPoint(x: random(-0.05...1.05) * size.width, y: random(-0.05...1) * size.height)
                        drops.move(to: start)
                        drops.addLine(to: CGPoint(x: start.x - length * 0.25, y: start.y + length))
                    }
                    ctx.stroke(drops, with: .color(.white.opacity(opacity)), style: StrokeStyle(lineWidth: u * (drizzle ? 0.005 : 0.007), lineCap: .round))
                }
            }
        ]
    }
}
