import SwiftUI

public struct LotusLanternDecoration: SceneLayerProvider {
    public init() {}

    private static let colors: [RGB] = [
        RGB(hex: 0xF06292), RGB(hex: 0xFFD54F), RGB(hex: 0xE53935), RGB(hex: 0x81C784), RGB(hex: 0xFF8A65), RGB(hex: 0x64B5F6),
    ]

    @MainActor public func layers(for context: SceneContext) -> [WindowLayer] {
        let lights = max(0, 1 - SkyPalette(context).daylight / 0.5)
        return [
            WindowLayer(id: "decoration.lotusLantern", depth: .decoration) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    let end = size.height * 0.05, sag = size.height * 0.2
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: end))
                    line.addQuadCurve(to: CGPoint(x: size.width, y: end), control: CGPoint(x: size.width / 2, y: sag))
                    ctx.stroke(line, with: .color(RGB(hex: 0x3B2F2A).color(0.8)), lineWidth: max(0.8, u * 0.008))
                    let count = max(3, Int(size.width / (u * 0.34)))
                    for i in 0..<count {
                        let t = (Double(i) + 0.5) / Double(count)
                        let hook = CGPoint(x: size.width * t, y: (1 - t) * (1 - t) * end + 2 * (1 - t) * t * sag + t * t * end)
                        Self.drawLantern(&ctx, hook: hook, radius: u * 0.065, color: Self.colors[i % Self.colors.count], lights: lights)
                    }
                }
            }
        ]
    }

    private static func drawLantern(_ ctx: inout GraphicsContext, hook: CGPoint, radius r: CGFloat, color: RGB, lights: Double) {
        let center = CGPoint(x: hook.x, y: hook.y + r * 1.6)
        var string = Path()
        string.move(to: hook)
        string.addLine(to: CGPoint(x: hook.x, y: center.y))
        ctx.stroke(string, with: .color(RGB(hex: 0x3B2F2A).color), lineWidth: max(0.6, r * 0.08))
        if lights > 0 {
            ctx.fill(
                Path(ellipseIn: CGRect(center: center, radius: r * 3)),
                with: .radialGradient(
                    Gradient(colors: [color.mixed(with: RGB(hex: 0xFFE9A8), 0.5).color(0.6 * lights), color.color(0)]),
                    center: center, startRadius: r * 0.5, endRadius: r * 3))
        }
        let glow = color.mixed(with: RGB(hex: 0xFFF3C4), 0.45 * lights)
        var tassel = Path()
        for dx in [-0.35, 0, 0.35] {
            tassel.move(to: CGPoint(x: center.x + r * dx, y: center.y + r * 0.7))
            tassel.addLine(to: CGPoint(x: center.x + r * dx * 1.2, y: center.y + r * 1.7))
        }
        ctx.stroke(tassel, with: .color(color.color), lineWidth: max(0.6, r * 0.12))
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r * 0.6, y: center.y + r * 0.5, width: r * 1.2, height: r * 0.4)), with: .color(RGB(hex: 0x4F9A55).color))
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r * 0.85, width: r * 2, height: r * 1.7)), with: .color(glow.scaled(0.88).color))
        let petal = glow.mixed(with: RGB(hex: 0xFFFFFF), 0.25)
        let edge = glow.scaled(0.7)
        for (row, (y, count, length)) in [(0.45, 5, 0.75), (0.0, 4, 0.7), (-0.45, 3, 0.6)].enumerated() {
            let span = r * (1.5 - 0.3 * Double(row))
            for k in 0..<count {
                let x = center.x - span / 2 + span * (Double(k) + 0.5) / Double(count)
                let base = CGPoint(x: x, y: center.y + r * y)
                let tilt = (x - center.x) / r * 0.35
                let tip = CGPoint(x: base.x + sin(tilt) * r * length, y: base.y - cos(tilt) * r * length)
                let width = r * 0.24
                var leaf = Path()
                leaf.move(to: CGPoint(x: base.x - width, y: base.y))
                leaf.addQuadCurve(to: tip, control: CGPoint(x: base.x - width, y: (base.y + tip.y) / 2))
                leaf.addQuadCurve(to: CGPoint(x: base.x + width, y: base.y), control: CGPoint(x: base.x + width, y: (base.y + tip.y) / 2))
                leaf.closeSubpath()
                ctx.fill(leaf, with: .color(petal.color))
                ctx.stroke(leaf, with: .color(edge.color), lineWidth: max(0.4, r * 0.05))
            }
        }
    }
}
