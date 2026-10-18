/// 시드 고정 의사난수(SplitMix64). 위젯은 정지 이미지라 같은 입력이면 같은 그림이어야 한다.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func callAsFunction(_ range: ClosedRange<Double>) -> Double {
        Double.random(in: range, using: &self)
    }
}
