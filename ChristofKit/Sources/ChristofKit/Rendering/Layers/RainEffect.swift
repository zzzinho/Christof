struct RainEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let weather = s.weather, weather.condition.isRain else { return }
        let drizzle = weather.condition == .drizzle
        let count = jsRound(Double(w * h) * (drizzle ? 0.012 : 0.02) * (0.5 + weather.intensity))
        let length = drizzle ? 2 : 3, rain = s.color("rain")
        var random = SeededRandom(seed: 17)
        for _ in 0..<count {
            let x = Int(random(0...Double(w + 2)).rounded(.down)), y = Int(random(-2...Double(h)).rounded(.down))
            for k in 0..<length { g.set(x - k / 2, y + k, rain) }
        }
    }
}
