/// 구름층(흐림·비·눈·뇌우)은 하늘 위쪽을 덮고 아래로 갈수록 성겨진다. 조각구름은 구름양만큼 띄운다.
struct CloudEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let weather = s.weather else { return }
        let light = s.color("cloud"), dark = s.color("cloud-dark")
        if weather.condition.hasCloudDeck {
            let depth = Double(h) * 0.55
            for y in 0..<Int(depth.rounded(.up)) {
                let t = Double(y) / depth
                for x in 0..<w where (1 - t) * 1.5 > bayer(x, y) { g.set(x, y, t < 0.5 ? light : dark) }
            }
        }
        var random = SeededRandom(seed: 5)
        for _ in 0..<jsRound(weather.cloudCover * 5) {
            let cx = random(-0.05...1.05) * Double(w), cy = random(0.1...0.4) * Double(h), size = random(3...5)
            let puffs = [(-size, 0, size * 0.7), (0, -size * 0.4, size), (size, 0, size * 0.75)]
            g.shape(cx - size * 2, cy - size * 1.5, cx + size * 2, cy + size,
                    inside: { x, y in y <= cy + size * 0.5 && puffs.contains { dx, dy, r in jsHypot(x - cx - dx, y - cy - dy) <= r } },
                    color: { _, y in Double(y) + 0.5 > cy + size * 0.1 ? dark : light })
        }
    }
}
