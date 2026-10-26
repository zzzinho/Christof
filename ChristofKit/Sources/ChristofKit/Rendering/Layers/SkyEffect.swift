/// 하늘은 가로 띠 네 단계로 끊고, 띠 경계는 디더링으로 섞는다.
struct SkyEffect: OutsideEffect {
    func draw(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        let bands = (1...4).map { s.color("sky-\($0)") }
        for y in 0..<h {
            let t = min(1, max(0, (Double(y) + 0.5) / (Double(h) * 0.8))) * Double(bands.count - 1)
            let i = min(bands.count - 2, Int(t.rounded(.down)))
            for x in 0..<w { g.set(x, y, blend(bands[i], bands[i + 1], t - Double(i), x, y)) }
        }
    }
}
