enum WallPainter {
    /// 불을 켰으면 불빛에서 멀어질수록 차가운 색. 거친 질감은 성긴 어두운 점.
    static func draw(_ g: inout DotGrid, _ L: RoomLayout, _ s: DotScene) {
        var grain = SeededRandom(seed: 41)
        let reach = Double(L.W > L.H ? 110 : 90) / DotGrid.dot
        let wall = s.color("wall"), dark = s.color("wall-dark")
        // 낮(불 끔)에는 따뜻한 벽 색이 팔레트에 없다.
        let warm = s.lightOn ? (s.color("wall-warm"), s.color("wall-warmer")) : nil
        for y in 0..<L.H {
            for x in 0..<L.W {
                var c = wall
                if let (warm, warmer) = warm {
                    let d = jsHypot(Double(x) + 0.5 - L.light.x, (Double(y) + 0.5 - L.light.y) * 1.2) / reach
                    if d < 0.35 {
                        c = blend(warmer, warm, d / 0.35, x, y)
                    } else if d < 0.75 {
                        c = blend(warm, c, (d - 0.35) / 0.4, x, y)
                    }
                }
                if grain(0...1) < 0.04 { c = dark }
                g.set(x, y, c)
            }
        }
    }
}
