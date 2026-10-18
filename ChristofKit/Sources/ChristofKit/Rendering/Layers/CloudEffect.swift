import SwiftUI

struct CloudEffect: SceneLayerProvider {
    private static let decked: Set<WeatherCondition> = [.overcast, .drizzle, .rain, .snow, .thunderstorm]

    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard let weather = context.weather else { return [] }
        let count = Int((weather.cloudCover * 7).rounded())
        let deck = Self.decked.contains(weather.condition)
        guard count > 0 || deck else { return [] }
        let color = SkyPalette(context).cloud
        return [
            WindowLayer(id: "clouds", depth: .clouds) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    var random = SeededRandom(seed: 5)
                    if deck {
                        ctx.fill(
                            Path(CGRect(origin: .zero, size: size)),
                            with: .linearGradient(
                                Gradient(colors: [color.color(0.95), color.color(0.7), color.color(0)]),
                                startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height * 0.6)))
                    }
                    for _ in 0..<count {
                        let center = CGPoint(x: random(-0.05...1.05) * size.width, y: random(0.1...0.42) * size.height)
                        Self.drawCloud(&ctx, center: center, scale: u * random(0.13...0.2), color: color)
                    }
                }
            }
        ]
    }

    private static func drawCloud(_ ctx: inout GraphicsContext, center: CGPoint, scale s: CGFloat, color: RGB) {
        var puff = Path()
        puff.addEllipse(in: CGRect(x: center.x - s * 1.2, y: center.y - s * 0.1, width: s * 2.4, height: s * 0.7))
        for (dx, dy, r) in [(-0.6, 0.05, 0.42), (-0.15, -0.25, 0.58), (0.4, -0.1, 0.5), (0.8, 0.1, 0.34)] {
            puff.addEllipse(in: CGRect(center: CGPoint(x: center.x + s * dx, y: center.y + s * dy), radius: s * r))
        }
        ctx.fill(
            puff,
            with: .linearGradient(
                Gradient(colors: [color.mixed(with: RGB(hex: 0xFFFFFF), 0.15).color(0.95), color.scaled(0.85).color(0.95)]),
                startPoint: CGPoint(x: center.x, y: center.y - s * 0.8), endPoint: CGPoint(x: center.x, y: center.y + s * 0.6)))
    }
}
