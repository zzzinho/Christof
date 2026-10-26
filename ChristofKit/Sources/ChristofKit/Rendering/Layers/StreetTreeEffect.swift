/// 창 아래쪽 가로수로 계절을 보인다. 해가 진 뒤에는 실루엣이고, 겨울은 잎 없는 가지다.
struct StreetTreeEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        var random = SeededRandom(seed: 13)
        let dark = s.phase == .night || s.phase == .dusk
        let crowns: [String]? = switch s.season {
        case .spring: ["spring-1", "spring-2"]
        case .summer: ["summer-1", "summer-2"]
        case .autumn: ["autumn-1", "autumn-2", "autumn-3"]
        case .winter: nil
        }
        let bark = dark ? s.color("city") : LofiPalette.color("branch")
        var x = random(1...4), i = 0
        while x < Double(w + 4) {
            let r = random(3...4.6), cx = jsRound(x), top = h - random.int(7, 10)
            g.rect(cx, top, 1, h - top, bark)
            if let crowns {
                let main = dark ? bark : LofiPalette.color(crowns[i % 3 == 2 && crowns.count > 2 ? 2 : 0])
                let shade = dark ? bark : LofiPalette.color(crowns[1])
                g.shape(Double(cx) - r, Double(top) - r, Double(cx) + r + 1, Double(top) + r,
                        inside: { px, py in jsHypot(px - Double(cx) - 0.5, py - Double(top)) <= r },
                        color: { px, py in Double(px - cx + py - top) > r * 0.6 ? shade : main })
            } else {
                for k in 1...3 {
                    g.set(cx - k, top + 3 - k, bark)
                    g.set(cx + k, top + 4 - k, bark)
                }
                g.rect(cx, top - 3, 1, 3, bark)
            }
            x += r * 2 + random(1...4)
            i += 1
        }
    }
}
