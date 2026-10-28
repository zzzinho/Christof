import Foundation

/// 창밖 먼 풍경. 지역마다 다르다(RegionLooks). city 는 도시 난수라, 먼 풍경이 쓰고 남은 차례를 가까운 건물이 이어 쓴다.
protocol FarView: Sendable {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ city: inout SeededRandom, lit: Double, farBottom: Int)
}

/// 뒷산 능선과 아파트 단지
struct ApartmentView: FarView {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ city: inout SeededRandom, lit: Double, farBottom: Int) {
        drawMountains(&g, w, h, s, farBottom)
        drawApartments(&g, w, h, s, &city, lit: lit, farBottom: farBottom)
    }
}

/// 서울: 남산 봉우리 위 N서울타워(외국인이 꼽는 서울 랜드마크 1위)
struct SeoulView: FarView {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ city: inout SeededRandom, lit: Double, farBottom: Int) {
        let px = jsRound(Double(w) * 0.7), peak = drawMountains(&g, w, h, s, farBottom, peakX: px)
        // N서울타워: 가는 몸통, 전망대, 긴 안테나. 밤에는 경관 조명으로 몸통이 밝고, 전망대 창과 안테나 끝 빨간 항공등이 켜진다.
        // 밤 하늘과 산이 어두워서 실루엣만으로는 보이지 않는다.
        let night = s.phase == .night || s.phase == .dusk, far = "\(s.phase.rawValue)-city-far"
        g.sprite(px, peak, [".r.", ".a.", ".a.", ".a.", "ddd", "lll", ".s.", ".s.", ".s.", ".s.", ".s."], [
            "a": far, "r": night ? "bulb-1" : far, "d": night ? "lamp-light" : far, "s": night ? "lamp-light" : far,
            "l": night ? "window-lit" : "\(s.phase.rawValue)-city",
        ])
        drawApartments(&g, w, h, s, &city, lit: lit, farBottom: farBottom)
    }
}

/// 부산: 아파트 자리가 바다다. 수평선 위 해운대 고층 빌딩(마린시티, 엘시티 세 동)과 그 앞을 가로지르는 광안대교.
struct BusanView: FarView {
    /// [가로 위치, 높이 pt, 폭]. 마린시티 둘, 엘시티 세 동(411m 랜드마크 타워와 339m·333m 두 동)
    static let haeundaeTowers: [(x: Double, height: Double, width: Int)] = [(0.7, 30, 3), (0.75, 36, 3), (0.82, 54, 3), (0.88, 45, 3), (0.93, 44, 3)]

    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ city: inout SeededRandom, lit: Double, farBottom: Int) {
        let horizon = farBottom - jsRound(36 / DotGrid.dot)
        // 바다: 수평선 아래 바다색과 성긴 물결 반짝임
        g.rect(0, horizon, w, h - horizon, s.color("sea"))
        var waves = SeededRandom(seed: 31)
        var i = 0
        while Double(i) < Double(w) * 0.25 {
            let x = Int(waves(0...Double(w)).rounded(.down)), y = Int(waves(Double(horizon + 1)...Double(h)).rounded(.down))
            g.rect(x, y, 2, 1, s.color("sky-4"))
            i += 1
        }
        // 해운대 빌딩은 하늘에 묻히지 않게 먼 건물색(city-far) 대신 가까운 건물색이다.
        var windows = SeededRandom(seed: 37)
        for tower in Self.haeundaeTowers {
            let x = jsRound(Double(w) * tower.x) - 1, top = horizon - jsRound(tower.height / DotGrid.dot)
            g.rect(x, top + 1, tower.width, horizon - top - 1, s.color("city"))
            g.set(x + 1, top, s.color("city"))
            for y in stride(from: top + 2, to: horizon, by: 2) {
                for k in 0..<tower.width where windows(0...1) < 0.3 * lit { g.set(x + k, y, LofiPalette.color("window-lit")) }
            }
        }
        drawGwanganBridge(&g, w, s, deck: horizon + 3)
    }

    /// 광안대교: 두 주탑 사이 현수 케이블과 복층 상판. 밤에는 케이블에 파란 경관 조명, 상판에 불빛이 켜지고 바다에 비친다.
    private func drawGwanganBridge(_ g: inout DotGrid, _ w: Int, _ s: DotScene, deck: Int) {
        let night = s.phase == .night || s.phase == .dusk, tall = jsRound(18 / DotGrid.dot)
        let p1 = jsRound(Double(w) * 0.3), p2 = jsRound(Double(w) * 0.6), mid = Double(p1 + p2) / 2
        func cable(_ x: Int) -> Int {
            let t = x < p1 ? Double(x) / Double(p1) : x > p2 ? Double(w - 1 - x) / Double(w - 1 - p2) : (Double(x) - mid) / (mid - Double(p1))
            return deck - 1 - jsRound(Double(tall - 1) * (t * t))
        }
        for px in [p1, p2] { g.rect(px, deck - tall, 1, tall + 3, s.color("city")) }
        g.rect(0, deck, w, 2, s.color("city"))
        for x in 0..<w {
            g.set(x, cable(x), night ? LofiPalette.color("bulb-4") : s.color("city"))
            if night, x % 3 == 1 {
                g.set(x, deck, LofiPalette.color("lamp-light"))
                g.set(x, deck + 3, LofiPalette.color("lamp"))
            }
        }
    }
}

/// 뒷산 능선. 한국 도시는 산을 등지고 있다. peakX 를 주면 그 자리에 봉우리(남산)를 올리고 봉우리 꼭대기 y 를 돌려준다.
/// ponytail: 봄 진달래를 능선에 점으로 찍어 봤더니 하늘에 뜬 꽃잎(벚꽃)처럼 보여서 뺐다.
@discardableResult
private func drawMountains(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ farBottom: Int, peakX: Int? = nil) -> Int {
    let base = Double(farBottom) - 52 / DotGrid.dot - Double(h) * 0.08
    var peak = farBottom
    for x in 0..<w {
        let d = peakX.map { Double(x - $0) / (30 / DotGrid.dot) }
        let hill = d.map { 9 / DotGrid.dot * max(0, 1 - $0 * $0) } ?? 0
        let top = jsRound(base - 8 / DotGrid.dot * (0.6 * sin(Double(x) * 0.07 + 1) + 0.4 * sin(Double(x) * 0.19 + 2)) - hill)
        g.rect(x, top, 1, farBottom - top, s.color("mountain"))
        if x == peakX { peak = top }
    }
    return peak
}

/// 아파트: 폭 넓은 판상형 동과 옥탑. 층은 두 칸, 집마다 창 두 칸이라 불 꺼진 창도 격자로 보인다.
private func drawApartments(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene, _ city: inout SeededRandom, lit: Double, farBottom: Int) {
    var x = jsRound(city(-3...0))
    while x < w {
        let bw = city.int(jsRound(30 / DotGrid.dot), jsRound(48 / DotGrid.dot))
        let top = farBottom - jsRound(city(26...40) / DotGrid.dot + Double(h) * 0.08)
        g.rect(x, top, bw, h - top, s.color("city-far"))
        g.rect(x + city.int(2, bw - 6), top - 2, 4, 2, s.color("city-far"))
        for fy in stride(from: top + 2, to: h, by: 2) {
            for ux in stride(from: x + 1, through: x + bw - 3, by: 3) {
                g.rect(ux, fy, 2, 1, city(0...1) < 0.3 * lit ? LofiPalette.color("window-lit") : s.color("city"))
            }
        }
        x += bw + city.int(1, 3)
    }
}
