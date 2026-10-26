/// 먼 도시와 가까운 지붕들. 해가 진 뒤와 흐린 날은 창에 호박색 불이 켜진다.
struct CityEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        var city = SeededRandom(seed: 7)
        let lit = s.phase == .day ? 0 : s.phase == .grey ? 0.4 : 1
        let windowLit = LofiPalette.color("window-lit")
        let layers = [("city-far", 0.86, 14.0, 30.0, 0.12), ("city", 0.95, 8.0, 20.0, 0.25)]
        for (layer, bottomF, minH, maxH, density) in layers {
            let fill = s.color(layer)
            var x = city(-3...0)
            while x < Double(w) {
                let bw = city.int(jsRound(14 / DotGrid.dot), jsRound(30 / DotGrid.dot))
                let bh = jsRound(city(minH...maxH) / DotGrid.dot + Double(h) * 0.08)
                let bottom = jsRound(Double(h) * bottomF), top = bottom - bh
                g.rect(x, Double(top), Double(bw), Double(h - top), fill)
                if layer == "city", s.snowCovered { g.rect(x, Double(top), Double(bw), 1, s.color("snow")) }
                for wy in stride(from: top + 2, to: h, by: 2) {
                    var wx = jsRound(x) + 1
                    while Double(wx) < x + Double(bw) - 1 {
                        // 불을 켜지 않는 낮에도 난수를 같은 만큼 써서 건물 모양이 때와 관계없이 같다.
                        if city(0...1) < density * lit { g.set(wx, wy, windowLit) }
                        wx += 2
                    }
                }
                x += Double(bw + city.int(0, 2))
            }
        }
    }
}
