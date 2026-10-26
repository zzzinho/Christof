struct SnowEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let weather = s.weather, weather.condition == .snow else { return }
        let count = jsRound(Double(w * h) * 0.02 * (0.5 + weather.intensity)), snow = s.color("snow")
        var random = SeededRandom(seed: 23)
        for _ in 0..<count {
            let x = (random(0...Double(w))).rounded(.down), y = (random(0...Double(h))).rounded(.down)
            g.set(x, y, snow)
        }
    }
}
