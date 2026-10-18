import SwiftUI

/// 해가 진 뒤의 달. 위상만큼 차고 기운 모양으로 그린다.
struct MoonEffect: SceneLayerProvider {
    /// 유리 짧은 변 대비 달 반지름. 보름달 장식이 후광 크기를 맞춘다.
    static let radiusRatio = 0.08

    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard context.sun.altitude < 0,
              let position = CelestialPosition.moon(context.moon, latitude: context.region.latitude)
        else { return [] }
        let palette = SkyPalette(context)
        let visibility = 1 - palette.gloom * 1.25
        guard visibility > 0.05 else { return [] }
        let phase = context.moon.phase
        let mirrored = context.region.latitude < 0
        return [
            WindowLayer(id: "moon", depth: .celestialBody) {
                Canvas { ctx, size in
                    let center = CGPoint(x: position.x * size.width, y: position.y * size.height)
                    let radius = min(size.width, size.height) * Self.radiusRatio
                    let disc = CGRect(center: center, radius: radius)
                    let light = RGB(hex: 0xF6F1DC)
                    ctx.fill(
                        Path(ellipseIn: CGRect(center: center, radius: radius * 2.6)),
                        with: .radialGradient(
                            Gradient(colors: [light.color(0.22 * visibility), light.color(0)]),
                            center: center, startRadius: radius, endRadius: radius * 2.6))
                    ctx.fill(Path(ellipseIn: disc), with: .color(.white.opacity(0.08 * visibility)))
                    ctx.fill(Self.litPath(phase: phase, in: disc, mirrored: mirrored), with: .color(light.color(visibility)))
                }
            }
        ]
    }

    /// 밝은 면. 차는 달(위상 < 0.5)은 오른쪽이 밝다(북반구). 경계선은 x 반지름이 cos(2π·위상)인 반타원.
    static func litPath(phase: Double, in disc: CGRect, mirrored: Bool) -> Path {
        let k = cos(phase * 2 * .pi)
        let (limb, terminator) = phase < 0.5 ? (1.0, k) : (-1.0, -k)
        let flip = mirrored ? -1.0 : 1.0
        let r = disc.width / 2
        let steps = 24
        func edge(_ side: Double, _ i: Int) -> CGPoint {
            let y = -r + 2 * r * Double(i) / Double(steps)
            return CGPoint(x: disc.midX + flip * side * max(0, r * r - y * y).squareRoot(), y: disc.midY + y)
        }
        var path = Path()
        path.move(to: edge(limb, 0))
        for i in 1...steps { path.addLine(to: edge(limb, i)) }
        for i in (0...steps).reversed() { path.addLine(to: edge(terminator, i)) }
        path.closeSubpath()
        return path
    }
}
