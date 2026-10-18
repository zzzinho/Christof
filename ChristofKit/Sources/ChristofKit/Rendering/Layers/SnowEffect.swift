import SwiftUI

/// 내리는 눈과 창턱에 쌓인 눈.
struct SnowEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard let weather = context.weather, weather.condition == .snow else { return [] }
        let count = 50 + Int(110 * weather.intensity)
        let snow = RGB(hex: 0xC9D3E6).mixed(with: RGB(hex: 0xFAFCFF), SkyPalette(context).daylight)
        return [
            WindowLayer(id: "snow", depth: .weather) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    var random = SeededRandom(seed: 23)
                    for _ in 0..<count {
                        let center = CGPoint(x: random(0...1) * size.width, y: random(0...1) * size.height)
                        ctx.fill(Path(ellipseIn: CGRect(center: center, radius: u * random(0.006...0.016))), with: .color(snow.color(random(0.7...1))))
                    }
                }
            },
            WindowLayer(id: "snow.sill", placement: .onFrame, depth: .weather) {
                Canvas { ctx, size in
                    let top = WindowGeometry(size: size).sillTop
                    let bump = top.height * 0.9
                    var drift = Path()
                    drift.move(to: CGPoint(x: 0, y: top.maxY))
                    drift.addLine(to: CGPoint(x: 0, y: top.minY - bump * 0.4))
                    let steps = 12
                    for i in 1...steps {
                        let x = size.width * Double(i) / Double(steps)
                        let peak = bump * (0.6 + 0.4 * sin(Double(i) * 1.7))
                        drift.addQuadCurve(to: CGPoint(x: x, y: top.minY - bump * 0.4), control: CGPoint(x: x - size.width / Double(steps) / 2, y: top.minY - peak))
                    }
                    drift.addLine(to: CGPoint(x: size.width, y: top.maxY))
                    drift.closeSubpath()
                    ctx.fill(drift, with: .linearGradient(
                        Gradient(colors: [snow.color, snow.scaled(0.9).color]),
                        startPoint: CGPoint(x: 0, y: top.minY - bump), endPoint: CGPoint(x: 0, y: top.maxY)))
                }
            },
        ]
    }
}
