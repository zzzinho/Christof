import Foundation

/// 한국 도시: 뒤에 산 능선, 그 앞에 아파트 단지, 가까이 낮은 상가·빌라. 해가 진 뒤와 흐린 날은 창에 호박색 불이 켜진다.
/// 불을 켜지 않는 낮에도 난수를 같은 만큼 써서 건물 모양이 때와 관계없이 같다.
struct CityEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        var city = SeededRandom(seed: 7)
        let lit = s.phase == .day ? 0 : s.phase == .grey ? 0.4 : 1
        let windowLit = LofiPalette.color("window-lit")
        let farBottom = jsRound(Double(h) * 0.86)
        drawMountains(&g, w, h, s, farBottom)
        // 아파트: 폭 넓은 판상형 동과 옥탑. 층은 두 칸, 집마다 창 두 칸이라 불 꺼진 창도 격자로 보인다.
        var x = jsRound(city(-3...0))
        while x < w {
            let bw = city.int(jsRound(30 / DotGrid.dot), jsRound(48 / DotGrid.dot))
            let top = farBottom - jsRound(city(26...40) / DotGrid.dot + Double(h) * 0.08)
            g.rect(x, top, bw, h - top, s.color("city-far"))
            g.rect(x + city.int(2, bw - 6), top - 2, 4, 2, s.color("city-far"))
            for fy in stride(from: top + 2, to: h, by: 2) {
                for ux in stride(from: x + 1, through: x + bw - 3, by: 3) {
                    g.rect(ux, fy, 2, 1, city(0...1) < 0.3 * lit ? windowLit : s.color("city"))
                }
            }
            x += bw + city.int(1, 3)
        }
        // 가까운 낮은 건물. 밤에는 그중 하나의 옥상에 교회 빨간 네온 십자가가 켜진다.
        let crossAt = city.int(1, 3), night = s.phase == .night || s.phase == .dusk
        var bx = city(-3...0), i = 0
        while bx < Double(w) {
            let bw = city.int(jsRound(14 / DotGrid.dot), jsRound(30 / DotGrid.dot))
            let top = jsRound(Double(h) * 0.95) - jsRound(city(8...20) / DotGrid.dot + Double(h) * 0.08)
            g.rect(bx, Double(top), Double(bw), Double(h - top), s.color("city"))
            if s.snowCovered { g.rect(bx, Double(top), Double(bw), 1, s.color("snow")) }
            for wy in stride(from: top + 2, to: h, by: 2) {
                var wx = jsRound(bx) + 1
                while Double(wx) < bx + Double(bw) - 1 {
                    if city(0...1) < 0.25 * lit { g.set(wx, wy, windowLit) }
                    wx += 2
                }
            }
            if i == crossAt, night { g.sprite(jsRound(bx + Double(bw) / 2), top, [".X.", "XXX", ".X.", ".X."], ["X": "bulb-1"]) }
            bx += Double(bw + city.int(0, 2))
            i += 1
        }
    }

    /// 뒷산 능선. 한국 도시는 산을 등지고 있다.
    private func drawMountains(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ farBottom: Int) {
        let base = Double(farBottom) - 52 / DotGrid.dot - Double(h) * 0.08
        for x in 0..<w {
            let top = jsRound(base - 8 / DotGrid.dot * (0.6 * sin(Double(x) * 0.07 + 1) + 0.4 * sin(Double(x) * 0.19 + 2)))
            g.rect(x, top, 1, farBottom - top, s.color("mountain"))
        }
    }
}
