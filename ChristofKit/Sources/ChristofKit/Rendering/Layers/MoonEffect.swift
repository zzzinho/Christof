import Foundation

struct MoonEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let (cx, cy, r) = Self.circle(s, w, h) else { return }
        let halo = LofiPalette.color("halo"), moon = LofiPalette.color("moon")
        g.ring(cx, cy, r, 2, halo)
        // 차는 달(위상 < 0.5)은 오른쪽이 밝다. 밝은 면 경계는 x 반지름이 cos(2π·위상)인 반타원.
        let phase = s.moonPhase, k = cos(phase * 2 * Double.pi)
        g.disc(cx, cy, r) { x, y in
            let dy = Double(y) + 0.5 - cy, half = max(0, r * r - dy * dy).squareRoot()
            let u = half != 0 ? (Double(x) + 0.5 - cx) / half : 0
            return (phase < 0.5 ? u >= k : u <= -k) ? moon : halo
        }
    }

    static func circle(_ s: DotScene, _ w: Int, _ h: Int) -> (Double, Double, Double)? {
        s.moonPoint.map { bodyCircle($0, w, h, radius: 10) }
    }
}
