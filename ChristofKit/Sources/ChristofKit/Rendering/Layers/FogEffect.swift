struct FogEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let weather = s.weather, weather.condition == .fog else { return }
        let density = 0.45 + 0.4 * weather.intensity, fog = s.color("fog")
        for y in 0..<h {
            let f = density * (0.35 + 0.65 * Double(y) / Double(h))
            for x in 0..<w where f > bayer(x, y) { g.set(x, y, fog) }
        }
    }
}
