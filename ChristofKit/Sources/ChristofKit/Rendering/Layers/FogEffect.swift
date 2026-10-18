import SwiftUI

/// 안개. 아래로 갈수록 짙고, 세기만큼 풍경을 가린다.
struct FogEffect: SceneLayerProvider {
    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        guard let weather = context.weather, weather.condition == .fog else { return [] }
        let color = SkyPalette(context).cloud.mixed(with: RGB(hex: 0xFFFFFF), 0.2)
        let density = 0.45 + 0.4 * weather.intensity
        return [
            WindowLayer(id: "fog", depth: .weather) {
                Canvas { ctx, size in
                    ctx.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .linearGradient(
                            Gradient(colors: [color.color(density * 0.35), color.color(density * 0.8), color.color(density)]),
                            startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
                    for k in 0..<3 {
                        let band = CGRect(x: -size.width * 0.1, y: size.height * (0.5 + 0.12 * Double(k)), width: size.width * 1.2, height: size.height * 0.1)
                        ctx.fill(Path(ellipseIn: band), with: .color(color.color(density * 0.5)))
                    }
                }
            }
        ]
    }
}
