import SwiftUI

public struct LuckyPouchDecoration: SceneLayerProvider {
    public init() {}

    @MainActor public func layers(for context: SceneContext) -> [WindowLayer] {
        [
            WindowLayer(id: "decoration.luckyPouch", placement: .onFrame, depth: .decoration) {
                Canvas { ctx, size in
                    let g = WindowGeometry(size: size)
                    let u = min(size.width, size.height) * 0.22
                    let cx = g.glass.minX + g.glass.width * 0.25
                    let top = g.glass.minY + u * 0.2
                    let gold = RGB(hex: 0xF2C14E)

                    var cord = Path()
                    cord.move(to: CGPoint(x: cx, y: g.frame * 0.4))
                    cord.addLine(to: CGPoint(x: cx, y: top))
                    ctx.stroke(cord, with: .color(RGB(hex: 0xB51E35).color), lineWidth: max(1, u * 0.03))
                    let knotY = (g.frame * 0.4 + top) / 2
                    var knot = Path()
                    knot.move(to: CGPoint(x: cx, y: knotY - u * 0.05))
                    knot.addLine(to: CGPoint(x: cx + u * 0.05, y: knotY))
                    knot.addLine(to: CGPoint(x: cx, y: knotY + u * 0.05))
                    knot.addLine(to: CGPoint(x: cx - u * 0.05, y: knotY))
                    knot.closeSubpath()
                    ctx.fill(knot, with: .color(RGB(hex: 0x2E5AAC).color))

                    var ruffle = Path()
                    ruffle.move(to: CGPoint(x: cx - u * 0.12, y: top + u * 0.14))
                    ruffle.addQuadCurve(to: CGPoint(x: cx - u * 0.24, y: top - u * 0.02), control: CGPoint(x: cx - u * 0.2, y: top + u * 0.1))
                    ruffle.addQuadCurve(to: CGPoint(x: cx, y: top - u * 0.04), control: CGPoint(x: cx - u * 0.12, y: top + u * 0.04))
                    ruffle.addQuadCurve(to: CGPoint(x: cx + u * 0.24, y: top - u * 0.02), control: CGPoint(x: cx + u * 0.12, y: top + u * 0.04))
                    ruffle.addQuadCurve(to: CGPoint(x: cx + u * 0.12, y: top + u * 0.14), control: CGPoint(x: cx + u * 0.2, y: top + u * 0.1))
                    ruffle.closeSubpath()
                    ctx.fill(ruffle, with: .color(RGB(hex: 0xEC5A72).color))

                    var body = Path()
                    body.move(to: CGPoint(x: cx - u * 0.13, y: top + u * 0.17))
                    body.addQuadCurve(to: CGPoint(x: cx - u * 0.4, y: top + u * 0.62), control: CGPoint(x: cx - u * 0.4, y: top + u * 0.3))
                    body.addQuadCurve(to: CGPoint(x: cx, y: top + u * 0.92), control: CGPoint(x: cx - u * 0.4, y: top + u * 0.92))
                    body.addQuadCurve(to: CGPoint(x: cx + u * 0.4, y: top + u * 0.62), control: CGPoint(x: cx + u * 0.4, y: top + u * 0.92))
                    body.addQuadCurve(to: CGPoint(x: cx + u * 0.13, y: top + u * 0.17), control: CGPoint(x: cx + u * 0.4, y: top + u * 0.3))
                    body.closeSubpath()
                    ctx.fill(body, with: .linearGradient(
                        Gradient(colors: [RGB(hex: 0xE23A52).color, RGB(hex: 0xB01C36).color]),
                        startPoint: CGPoint(x: cx - u * 0.3, y: top), endPoint: CGPoint(x: cx + u * 0.3, y: top + u * 0.9)))

                    ctx.fill(Path(roundedRect: CGRect(x: cx - u * 0.16, y: top + u * 0.12, width: u * 0.32, height: u * 0.07), cornerRadius: u * 0.03), with: .color(gold.color))
                    let emblem = CGPoint(x: cx, y: top + u * 0.58)
                    ctx.stroke(Path(ellipseIn: CGRect(center: emblem, radius: u * 0.15)), with: .color(gold.color), lineWidth: max(0.8, u * 0.025))
                    ctx.draw(Text("福").font(.system(size: u * 0.19, weight: .bold)).foregroundStyle(gold.color), at: emblem)
                }
            }
        ]
    }
}
