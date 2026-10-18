import SwiftUI

/// 뇌우의 번개. 뇌우면 늘 그리고, 모양은 지역 시각의 '시'로 정한다(같은 입력이면 같은 번개).
struct LightningEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard let weather = context.weather, weather.condition == .thunderstorm else { return [] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = context.region.timeZone
        let seed = UInt64(calendar.component(.hour, from: context.date))
        let flash = 0.25 + 0.25 * weather.intensity
        return [
            // 구름 앞, 먼 풍경 뒤에 친다.
            WindowLayer(id: "lightning", depth: LayerDepth(35)) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    var random = SeededRandom(seed: 101 + seed)
                    var bolt = Path()
                    var point = CGPoint(x: random(0.25...0.75) * size.width, y: size.height * 0.15)
                    // 번개가 시작하는 구름 속만 밝힌다. 화면 전체를 밝히면 뇌우가 비보다 밝아 보인다.
                    ctx.fill(
                        Path(ellipseIn: CGRect(center: point, radius: u * 0.6)),
                        with: .radialGradient(Gradient(colors: [.white.opacity(flash), .white.opacity(0)]), center: point, startRadius: 0, endRadius: u * 0.6))
                    bolt.move(to: point)
                    var fork: CGPoint?
                    while point.y < size.height * CelestialPosition.horizon {
                        point = CGPoint(x: point.x + u * random(-0.06...0.06), y: point.y + size.height * random(0.05...0.09))
                        bolt.addLine(to: point)
                        if fork == nil, point.y > size.height * 0.35 { fork = point }
                    }
                    if let fork {
                        bolt.move(to: fork)
                        bolt.addLine(to: CGPoint(x: fork.x + u * 0.08, y: fork.y + size.height * 0.08))
                        bolt.addLine(to: CGPoint(x: fork.x + u * 0.1, y: fork.y + size.height * 0.15))
                    }
                    ctx.stroke(bolt, with: .color(RGB(hex: 0xFFF6C8).color(0.35)), style: StrokeStyle(lineWidth: u * 0.03, lineCap: .round, lineJoin: .round))
                    ctx.stroke(bolt, with: .color(.white), style: StrokeStyle(lineWidth: u * 0.009, lineCap: .round, lineJoin: .round))
                }
            }
        ]
    }
}
