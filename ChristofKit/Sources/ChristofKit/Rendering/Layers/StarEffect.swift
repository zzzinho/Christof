struct StarEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard s.phase == .night, s.weather?.condition.showsStars ?? true else { return }
        var stars = SeededRandom(seed: 3)
        let count = jsRound(Double(w * h) * DotGrid.dot * DotGrid.dot * 0.001)
        let star = LofiPalette.color("star"), dim = LofiPalette.color("star-dim")
        for _ in 0..<count {
            let x = (stars(0...1) * Double(w)).rounded(.down), y = (stars(0...0.55) * Double(h)).rounded(.down)
            g.set(x, y, stars(0...1) < 0.3 ? star : dim)
        }
    }
}
