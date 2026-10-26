import Foundation

/// 글자 대신 벽시계로 시각을 보인다. 13칸보다 작으면 시침과 분침이 한두 칸 차이라 구분되지 않는다.
enum ClockPainter {
    static func draw(_ g: inout DotGrid, _ L: RoomLayout, _ s: DotScene) {
        let (cx, cy) = L.clock
        let rim = LofiPalette.color("clock-rim"), hand = LofiPalette.color("clock-hand")
        g.disc(Double(cx) + 0.5, Double(cy) + 0.5, 6.5, rim)
        let face = s.looks.clock.lazy.compactMap(\.face).first ?? "clock-face"
        g.disc(Double(cx) + 0.5, Double(cy) + 0.5, 5.5, LofiPalette.color(face))
        for (dx, dy) in [(0, -5), (5, 0), (0, 5), (-5, 0)] { g.set(cx + dx, cy + dy, rim) }
        // 시침은 두 칸 두께로 그린다.
        func drawHand(_ turns: Double, _ length: Double, _ width: Int) {
            let a = turns * 2 * Double.pi, dx = sin(a), dy = -cos(a)
            for t in stride(from: 0.0, through: length, by: 0.5) {
                for k in 0..<width {
                    let k = Double(k)
                    g.set(cx + jsRound(dx * t - dy * k * 0.7), cy + jsRound(dy * t + dx * k * 0.7), hand)
                }
            }
        }
        drawHand(Double(s.minute) / 60, 5, 1)
        drawHand((Double(s.hour % 12) + Double(s.minute) / 60) / 12, 3, 2)
        for look in s.looks.clock { look.draw(&g, cx, cy, s) }
    }
}
