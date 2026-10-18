import SwiftUI

/// 창문 자체: 유리 반사, 십자 창살, 창틀, 창턱. 장면과 무관하게 늘 같은 색이라 캡션 대비가 보장된다.
struct WindowFrame: View {
    static let paint = RGB(hex: 0xF3EEE6)

    var body: some View {
        Canvas { ctx, size in
            let g = WindowGeometry(size: size)
            let glass = Path(roundedRect: g.glass, cornerRadius: g.glassCornerRadius)
            drawGlass(&ctx, g, glass)
            drawMullions(&ctx, g, glass)
            drawFrame(&ctx, g, glass, size)
            drawSill(&ctx, g)
        }
    }

    private func drawGlass(_ ctx: inout GraphicsContext, _ g: WindowGeometry, _ glass: Path) {
        ctx.drawLayer { layer in
            layer.clip(to: glass)
            let r = g.glass
            func band(_ from: Double, _ width: Double) -> Path {
                var p = Path()
                p.move(to: CGPoint(x: r.minX + r.width * from, y: r.minY))
                p.addLine(to: CGPoint(x: r.minX + r.width * (from + width), y: r.minY))
                p.addLine(to: CGPoint(x: r.minX + r.width * (from + width - 0.4), y: r.maxY))
                p.addLine(to: CGPoint(x: r.minX + r.width * (from - 0.4), y: r.maxY))
                p.closeSubpath()
                return p
            }
            layer.fill(band(0.58, 0.14), with: .color(.white.opacity(0.10)))
            layer.fill(band(0.76, 0.04), with: .color(.white.opacity(0.08)))
            // 창틀이 유리에 드리운 그림자.
            layer.stroke(glass, with: .color(.black.opacity(0.28)), lineWidth: g.frame * 0.5)
        }
    }

    private func drawMullions(_ ctx: inout GraphicsContext, _ g: WindowGeometry, _ glass: Path) {
        let m = g.mullion
        var bars = Path()
        bars.addRect(CGRect(x: g.glass.midX - m / 2, y: g.glass.minY, width: m, height: g.glass.height))
        bars.addRect(CGRect(x: g.glass.minX, y: g.glass.midY - m / 2, width: g.glass.width, height: m))
        ctx.drawLayer { layer in
            layer.clip(to: glass)
            layer.fill(bars.offsetBy(dx: m * 0.3, dy: m * 0.4), with: .color(.black.opacity(0.22)))
        }
        ctx.fill(bars, with: .color(Self.paint.color))
    }

    private func drawFrame(_ ctx: inout GraphicsContext, _ g: WindowGeometry, _ glass: Path, _ size: CGSize) {
        var frame = Path(CGRect(x: 0, y: 0, width: size.width, height: g.sillTop.minY))
        frame.addPath(glass)
        ctx.fill(
            frame,
            with: .linearGradient(
                Gradient(colors: [RGB(hex: 0xF8F4EE).color, Self.paint.color, RGB(hex: 0xE7E0D4).color]),
                startPoint: .zero, endPoint: CGPoint(x: 0, y: g.sillTop.minY)),
            style: FillStyle(eoFill: true))
        ctx.stroke(glass, with: .color(RGB(hex: 0xC9BEAD).color), lineWidth: max(1, g.frame * 0.08))
    }

    private func drawSill(_ ctx: inout GraphicsContext, _ g: WindowGeometry) {
        ctx.fill(Path(g.sillTop), with: .color(RGB(hex: 0xFBF8F3).color))
        ctx.fill(
            Path(g.sillFace),
            with: .linearGradient(
                Gradient(colors: [RGB(hex: 0xE2D8C7).color, RGB(hex: 0xECE5D9).color]),
                startPoint: CGPoint(x: 0, y: g.sillFace.minY), endPoint: CGPoint(x: 0, y: g.sillFace.maxY)))
        // 창턱 윗면이 앞면에 드리운 그림자.
        let shadow = CGRect(x: 0, y: g.sillFace.minY, width: g.sillFace.width, height: g.sillFace.height * 0.22)
        ctx.fill(
            Path(shadow),
            with: .linearGradient(
                Gradient(colors: [.black.opacity(0.16), .black.opacity(0)]),
                startPoint: CGPoint(x: 0, y: shadow.minY), endPoint: CGPoint(x: 0, y: shadow.maxY)))
    }
}
