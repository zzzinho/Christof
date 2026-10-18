import SwiftUI

struct LandscapeEffect: SceneLayerProvider {
    private struct Colors {
        let ground: RGB
        let hill: RGB
        let crowns: [RGB]
        let blossoms: Bool
    }

    private static func colors(for season: Season, snowCovered: Bool) -> Colors {
        if snowCovered {
            return Colors(ground: RGB(hex: 0xEEF2F7), hill: RGB(hex: 0xD5DEE9), crowns: [], blossoms: false)
        }
        return switch season {
        case .spring: Colors(ground: RGB(hex: 0x8CC56B), hill: RGB(hex: 0x7FAE6A), crowns: [RGB(hex: 0xF6B9CC), RGB(hex: 0xF2A3BC)], blossoms: true)
        case .summer: Colors(ground: RGB(hex: 0x5DA548), hill: RGB(hex: 0x4E8F4A), crowns: [RGB(hex: 0x3E8E41), RGB(hex: 0x2F7D3A), RGB(hex: 0x4C9A3C)], blossoms: false)
        case .autumn: Colors(ground: RGB(hex: 0xB9A04C), hill: RGB(hex: 0x9E7B45), crowns: [RGB(hex: 0xE0662C), RGB(hex: 0xC8402A), RGB(hex: 0xE8A33A)], blossoms: false)
        case .winter: Colors(ground: RGB(hex: 0xA79E7E), hill: RGB(hex: 0x8C8670), crowns: [], blossoms: false)
        }
    }

    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        let palette = SkyPalette(context)
        // 따뜻한 겨울(부산·제주, 다른 나라 남쪽)은 마른 땅으로 두고, 눈이 오거나 영하일 때만 눈밭으로 그린다.
        let snowCovered = context.weather.map { $0.condition == .snow || (context.season == .winter && $0.temperatureCelsius <= 0) } ?? false
        let colors = Self.colors(for: context.season, snowCovered: snowCovered)
        let lights = max(0, 1 - palette.daylight / 0.45)
        return [
            WindowLayer(id: "landscape", depth: .landscape) {
                Canvas { ctx, size in
                    let u = min(size.width, size.height)
                    let horizon = size.height * CelestialPosition.horizon
                    Self.drawCity(&ctx, size: size, u: u, horizon: horizon, palette: palette, lights: lights)
                    Self.drawHill(&ctx, size: size, top: horizon, height: size.height * 0.022, wave: 1.3, color: palette.shade(colors.hill.mixed(with: palette.horizon, 0.25)))
                    let ground = { (x: CGFloat) in size.height * 0.83 + size.height * 0.025 * sin(x / size.width * 2 * .pi * 0.8 + 2) }
                    var field = Path()
                    field.move(to: CGPoint(x: 0, y: size.height))
                    for i in 0...24 {
                        let x = size.width * Double(i) / 24
                        field.addLine(to: CGPoint(x: x, y: ground(x)))
                    }
                    field.addLine(to: CGPoint(x: size.width, y: size.height))
                    field.closeSubpath()
                    ctx.fill(field, with: .color(palette.shade(colors.ground).color))
                    Self.drawTrees(&ctx, size: size, u: u, ground: ground, colors: colors, palette: palette)
                }
            }
        ]
    }

    private static func drawCity(_ ctx: inout GraphicsContext, size: CGSize, u: CGFloat, horizon: CGFloat, palette: SkyPalette, lights: Double) {
        var random = SeededRandom(seed: 11)
        let wall = palette.shade(RGB(hex: 0x7D8BA3).mixed(with: palette.horizon, 0.3))
        let lamp = RGB(hex: 0xFFD27A)
        var x = size.width * 0.34
        while x < size.width * 0.68 {
            let width = u * random(0.05...0.09)
            let height = u * random(0.07...0.2)
            let building = CGRect(x: x, y: horizon - height, width: width, height: height + size.height * 0.05)
            ctx.fill(Path(building), with: .color(wall.color))
            if lights > 0 {
                let cell = u * 0.024
                for row in 0..<Int(height / cell) {
                    for col in 0..<Int(width / cell) where random(0...1) < 0.45 {
                        let window = CGRect(x: building.minX + cell * (Double(col) + 0.3), y: building.minY + cell * (Double(row) + 0.35), width: cell * 0.45, height: cell * 0.45)
                        ctx.fill(Path(window), with: .color(lamp.color(lights)))
                    }
                }
            }
            x += width + u * random(0...0.012)
        }
    }

    private static func drawHill(_ ctx: inout GraphicsContext, size: CGSize, top: CGFloat, height: CGFloat, wave: Double, color: RGB) {
        var hill = Path()
        hill.move(to: CGPoint(x: 0, y: size.height))
        for i in 0...32 {
            let t = Double(i) / 32
            let lift = 0.7 + 0.5 * sin(t * 2 * .pi * wave + 0.8) + 0.3 * sin(t * 2 * .pi * 3.1)
            hill.addLine(to: CGPoint(x: size.width * t, y: top - height * lift))
        }
        hill.addLine(to: CGPoint(x: size.width, y: size.height))
        hill.closeSubpath()
        ctx.fill(hill, with: .color(color.color))
    }

    private static func drawTrees(_ ctx: inout GraphicsContext, size: CGSize, u: CGFloat, ground: (CGFloat) -> CGFloat, colors: Colors, palette: SkyPalette) {
        var random = SeededRandom(seed: 13)
        let count = max(4, Int(size.width / u * 4))
        let bark = palette.shade(RGB(hex: 0x6B4A34))
        for i in 0..<count {
            let x = (Double(i) + 0.5 + random(-0.25...0.25)) / Double(count) * size.width
            let base = CGPoint(x: x, y: ground(x) + u * 0.02)
            let height = u * random(0.12...0.18)
            let trunk = CGRect(x: base.x - height * 0.045, y: base.y - height * 0.55, width: height * 0.09, height: height * 0.55)
            ctx.fill(Path(trunk), with: .color(bark.color))
            let crownCenter = CGPoint(x: base.x, y: base.y - height * 0.66)
            guard !colors.crowns.isEmpty else {
                var branches = Path()
                for (angle, length) in [(-0.7, 0.4), (0.6, 0.38), (-0.25, 0.45), (0.2, 0.42), (-1.0, 0.25), (0.95, 0.27)] {
                    let start = CGPoint(x: base.x, y: base.y - height * (0.35 + 0.15 * abs(angle)))
                    branches.move(to: start)
                    branches.addLine(to: CGPoint(x: start.x + sin(angle) * height * length, y: start.y - cos(angle) * height * length))
                }
                ctx.stroke(branches, with: .color(bark.color), style: StrokeStyle(lineWidth: height * 0.035, lineCap: .round))
                continue
            }
            let crown = palette.shade(colors.crowns[i % colors.crowns.count])
            let r = height * 0.33
            var leaves = Path()
            leaves.addEllipse(in: CGRect(center: CGPoint(x: crownCenter.x - r * 0.55, y: crownCenter.y + r * 0.15), radius: r * 0.75))
            leaves.addEllipse(in: CGRect(center: CGPoint(x: crownCenter.x + r * 0.55, y: crownCenter.y + r * 0.15), radius: r * 0.75))
            leaves.addEllipse(in: CGRect(center: CGPoint(x: crownCenter.x, y: crownCenter.y - r * 0.25), radius: r))
            ctx.fill(leaves, with: .color(crown.color))
            if colors.blossoms {
                for _ in 0..<7 {
                    let dot = CGPoint(x: crownCenter.x + r * random(-1.0...1.0), y: crownCenter.y + r * random(-0.9...0.6))
                    ctx.fill(Path(ellipseIn: CGRect(center: dot, radius: r * 0.12)), with: .color(palette.shade(RGB(hex: 0xFFF3F7)).color))
                }
            }
        }
    }
}
