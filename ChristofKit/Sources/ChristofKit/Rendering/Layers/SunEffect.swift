import SwiftUI


struct SunEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let (cx, cy, r) = Self.circle(s, w, h) else { return }
        g.ring(cx, cy, r, 2, s.color("sky-4"))
        g.disc(cx, cy, r, LofiPalette.color(s.sunAltitude < 10 ? "sun-low" : "sun-high"))
    }

    static func circle(_ s: DotScene, _ w: Int, _ h: Int) -> (Double, Double, Double)? {
        s.sunPoint.map { bodyCircle($0, w, h, radius: 9) }
    }
}

/// 해·달 원. 반지름은 pt 다.
func bodyCircle(_ point: UnitPoint, _ w: Int, _ h: Int, radius: Double) -> (Double, Double, Double) {
    ((point.x * Double(w)).rounded(.down) + 0.5, (point.y * Double(h)).rounded(.down) + 0.5, radius / DotGrid.dot + 0.3)
}
