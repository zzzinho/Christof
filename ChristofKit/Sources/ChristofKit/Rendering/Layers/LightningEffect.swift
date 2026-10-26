struct LightningEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard s.weather?.condition == .thunderstorm else { return }
        var random = SeededRandom(seed: UInt64(101 + s.hour))
        var x = jsRound(random(0.25...0.75) * Double(w)), y = jsRound(Double(h) * 0.15)
        // 번개가 시작하는 구름 속만 밝힌다. 하늘 전체를 밝히면 뇌우가 비보다 밝아 보인다.
        g.ring(Double(x) + 0.5, Double(y) + 0.5, 0, 15 / DotGrid.dot, LofiPalette.color("bolt-glow"))
        let bolt = LofiPalette.color("bolt")
        while Double(y) < Double(h) * 0.7 {
            for _ in 0..<random.int(2, 4) {
                g.set(x, y, bolt)
                y += 1
            }
            x += random.int(-1, 1)
        }
    }
}
