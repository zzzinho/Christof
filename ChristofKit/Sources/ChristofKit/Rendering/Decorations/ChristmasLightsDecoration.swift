import SwiftUI

/// 크리스마스 전구 줄. 창틀 위쪽과 양옆을 따라 늘어져 창틀 위에 그린다.
public struct ChristmasLightsDecoration: SceneLayerProvider {
    public init() {}

    private static let colors: [RGB] = [RGB(hex: 0xFF4D4D), RGB(hex: 0xFFD24D), RGB(hex: 0x4DD07A), RGB(hex: 0x4DA6FF), RGB(hex: 0xFF8AD8)]

    @MainActor public func layers(for context: SceneContext) -> [WindowLayer] {
        let glow = 0.35 + 0.4 * max(0, 1 - SkyPalette(context).daylight / 0.5)
        return [
            WindowLayer(id: "decoration.christmasLights", placement: .onFrame, depth: .decoration) {
                Canvas { ctx, size in
                    let g = WindowGeometry(size: size)
                    let u = min(size.width, size.height)
                    let inset = g.frame * 0.5
                    let spacing = u * 0.17
                    // 위: 왼쪽 위 → 오른쪽 위, 아래로 처짐. 옆: 위 → 창턱, 유리 쪽으로 처짐.
                    var runs: [(CGPoint, CGPoint, CGVector)] = []
                    let across = max(3, Int((size.width - inset * 2) / spacing))
                    for i in 0..<across {
                        let x0 = inset + (size.width - inset * 2) * Double(i) / Double(across)
                        let x1 = inset + (size.width - inset * 2) * Double(i + 1) / Double(across)
                        runs.append((CGPoint(x: x0, y: inset), CGPoint(x: x1, y: inset), CGVector(dx: 0, dy: g.frame * 1.6)))
                    }
                    let down = max(2, Int((g.sillTop.minY - inset) / spacing))
                    for side in [inset, size.width - inset] {
                        let bulge = side < size.width / 2 ? g.frame * 1.2 : -g.frame * 1.2
                        for i in 0..<down {
                            let y0 = inset + (g.sillTop.minY - inset) * Double(i) / Double(down)
                            let y1 = inset + (g.sillTop.minY - inset) * Double(i + 1) / Double(down)
                            runs.append((CGPoint(x: side, y: y0), CGPoint(x: side, y: y1), CGVector(dx: bulge, dy: 0)))
                        }
                    }
                    var wire = Path()
                    var bulbs: [CGPoint] = []
                    for (a, b, sag) in runs {
                        let control = CGPoint(x: (a.x + b.x) / 2 + sag.dx, y: (a.y + b.y) / 2 + sag.dy)
                        wire.move(to: a)
                        wire.addQuadCurve(to: b, control: control)
                        for t in [0.33, 0.67] {
                            bulbs.append(CGPoint(
                                x: (1 - t) * (1 - t) * a.x + 2 * (1 - t) * t * control.x + t * t * b.x,
                                y: (1 - t) * (1 - t) * a.y + 2 * (1 - t) * t * control.y + t * t * b.y))
                        }
                    }
                    ctx.stroke(wire, with: .color(RGB(hex: 0x2E4A2E).color), lineWidth: max(1, g.frame * 0.12))
                    let r = g.frame * 0.3
                    for (i, point) in bulbs.enumerated() {
                        let color = Self.colors[i % Self.colors.count]
                        let bulb = CGPoint(x: point.x, y: point.y + r * 1.1)
                        ctx.fill(
                            Path(ellipseIn: CGRect(center: bulb, radius: r * 3.2)),
                            with: .radialGradient(Gradient(colors: [color.color(glow), color.color(0)]), center: bulb, startRadius: r * 0.5, endRadius: r * 3.2))
                        ctx.fill(Path(CGRect(x: point.x - r * 0.4, y: point.y - r * 0.1, width: r * 0.8, height: r * 0.6)), with: .color(RGB(hex: 0x2E4A2E).color))
                        ctx.fill(Path(ellipseIn: CGRect(x: bulb.x - r * 0.75, y: bulb.y - r * 0.6, width: r * 1.5, height: r * 2)), with: .color(color.mixed(with: RGB(hex: 0xFFFFFF), 0.25).color))
                    }
                }
            }
        ]
    }
}
