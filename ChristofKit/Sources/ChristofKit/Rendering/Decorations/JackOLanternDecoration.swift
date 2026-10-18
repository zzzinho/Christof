import SwiftUI

/// 할로윈 호박 등불. 창턱 위에 놓여 창틀 위에 그린다. 밤엔 얼굴이 빛난다.
public struct JackOLanternDecoration: SceneLayerProvider {
    public init() {}

    @MainActor public func layers(for context: SceneContext) -> [WindowLayer] {
        let daylight = SkyPalette(context).daylight
        let lights = max(0, 1 - daylight / 0.5)
        return [
            WindowLayer(id: "decoration.jackOLantern", placement: .onFrame, depth: .decoration) {
                Canvas { ctx, size in
                    let g = WindowGeometry(size: size)
                    let w = min(size.width, size.height) * 0.22
                    let h = w * 0.78
                    let bottom = g.sillTop.minY + g.sillTop.height * 0.7
                    let center = CGPoint(x: g.glass.maxX - w * 0.8, y: bottom - h / 2)
                    let candle = RGB(hex: 0xFFC93C)
                    if lights > 0 {
                        // 후광이 창턱 앞면(캡션)까지 번지지 않게 자른다.
                        ctx.drawLayer { glow in
                            glow.clip(to: Path(CGRect(x: 0, y: 0, width: size.width, height: g.sillFace.minY)))
                            glow.fill(
                                Path(ellipseIn: CGRect(center: center, radius: w * 1.3)),
                                with: .radialGradient(
                                    Gradient(colors: [candle.color(0.5 * lights), candle.color(0)]),
                                    center: center, startRadius: w * 0.3, endRadius: w * 1.3))
                        }
                    }
                    let skin = RGB(hex: 0xF28C28).scaled(0.8 + 0.2 * daylight)
                    var stem = Path()
                    stem.move(to: CGPoint(x: center.x - w * 0.05, y: center.y - h * 0.42))
                    stem.addQuadCurve(to: CGPoint(x: center.x + w * 0.08, y: center.y - h * 0.68), control: CGPoint(x: center.x - w * 0.04, y: center.y - h * 0.62))
                    stem.addLine(to: CGPoint(x: center.x + w * 0.12, y: center.y - h * 0.6))
                    stem.addQuadCurve(to: CGPoint(x: center.x + w * 0.06, y: center.y - h * 0.42), control: CGPoint(x: center.x + w * 0.05, y: center.y - h * 0.55))
                    stem.closeSubpath()
                    ctx.fill(stem, with: .color(RGB(hex: 0x5B6B2F).color))
                    for (dx, scale, shade) in [(-0.24, 0.62, 0.82), (0.24, 0.62, 0.82), (0, 0.6, 1.0)] {
                        let rib = CGRect(x: center.x + w * dx - w * scale / 2, y: center.y - h / 2, width: w * scale, height: h)
                        ctx.fill(Path(ellipseIn: rib), with: .color(skin.scaled(shade).color))
                    }
                    var face = Path()
                    for side in [-1.0, 1.0] {
                        face.move(to: CGPoint(x: center.x + side * w * 0.26, y: center.y - h * 0.02))
                        face.addLine(to: CGPoint(x: center.x + side * w * 0.08, y: center.y - h * 0.02))
                        face.addLine(to: CGPoint(x: center.x + side * w * 0.17, y: center.y - h * 0.24))
                        face.closeSubpath()
                    }
                    face.move(to: CGPoint(x: center.x - w * 0.3, y: center.y + h * 0.1))
                    let teeth = [(-0.2, 0.2), (-0.12, 0.13), (-0.04, 0.22), (0.04, 0.13), (0.12, 0.22), (0.2, 0.13), (0.3, 0.1)]
                    for (x, y) in teeth { face.addLine(to: CGPoint(x: center.x + w * x, y: center.y + h * y)) }
                    face.addQuadCurve(to: CGPoint(x: center.x - w * 0.3, y: center.y + h * 0.1), control: CGPoint(x: center.x, y: center.y + h * 0.55))
                    face.closeSubpath()
                    let carved = RGB(hex: 0x4A2208).mixed(with: RGB(hex: 0xFFE27A), 0.3 + 0.7 * lights)
                    ctx.fill(face, with: .color(carved.color))
                }
            }
        ]
    }
}
