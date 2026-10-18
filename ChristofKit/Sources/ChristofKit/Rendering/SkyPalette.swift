import SwiftUI

/// 0...1 sRGB. 보간·명암 계산을 하려고 SwiftUI `Color` 대신 쓴다.
struct RGB: Equatable {
    var r: Double
    var g: Double
    var b: Double

    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    init(hex: UInt32) {
        self.init(r: Double((hex >> 16) & 0xFF) / 255, g: Double((hex >> 8) & 0xFF) / 255, b: Double(hex & 0xFF) / 255)
    }

    var luminance: Double { 0.2126 * r + 0.7152 * g + 0.0722 * b }

    func mixed(with other: RGB, _ t: Double) -> RGB {
        RGB(r: r + (other.r - r) * t, g: g + (other.g - g) * t, b: b + (other.b - b) * t)
    }

    func scaled(_ k: Double) -> RGB {
        RGB(r: r * k, g: g * k, b: b * k)
    }

    /// 채널 차이의 최댓값. 연속성 검사용.
    func distance(to other: RGB) -> Double {
        max(abs(r - other.r), abs(g - other.g), abs(b - other.b))
    }

    var color: Color { Color(red: r, green: g, blue: b) }

    func color(_ opacity: Double) -> Color {
        Color(red: r, green: g, blue: b, opacity: opacity)
    }
}

/// 해 고도와 날씨에서 장면 색을 정한다. 하늘·구름·풍경·천체 레이어가 함께 쓴다.
struct SkyPalette {
    let zenith: RGB
    let horizon: RGB
    /// 0 밤 ... 1 낮.
    let daylight: Double
    /// 0 맑음 ... 1 짙은 뇌우. 클수록 채도·밝기를 낮춘다.
    let gloom: Double
    let sun: RGB
    let cloud: RGB

    /// 고도(도)별 천정·지평선 색. 사이는 선형 보간하고 양 끝 밖은 끝 값을 쓴다.
    static let keyframes: [(altitude: Double, zenith: RGB, horizon: RGB)] = [
        (-18, RGB(hex: 0x0A0F24), RGB(hex: 0x18203D)),  // 천문 박명 끝: 밤
        (-10, RGB(hex: 0x111A3D), RGB(hex: 0x2B3463)),
        (-5, RGB(hex: 0x1F2C63), RGB(hex: 0x6A4C7E)),   // 시민 박명: 보랏빛
        (-1, RGB(hex: 0x34508F), RGB(hex: 0xE0785A)),   // 노을
        (3, RGB(hex: 0x4C74B3), RGB(hex: 0xF2A65E)),
        (10, RGB(hex: 0x5A93D6), RGB(hex: 0xF3D9AE)),
        (25, RGB(hex: 0x3D86DB), RGB(hex: 0xA8D3F2)),   // 낮
        (60, RGB(hex: 0x2E7AD9), RGB(hex: 0xC0E2F8)),
    ]

    init(sunAltitude: Double, weather: WeatherSample?) {
        let gloom = weather.map(Self.gloom(of:)) ?? 0
        let (zenith, horizon) = Self.clearSky(at: sunAltitude)
        let daylight = Self.smoothstep(-9, 6, sunAltitude)
        self.gloom = gloom
        self.daylight = daylight
        self.zenith = Self.dull(zenith, gloom)
        self.horizon = Self.dull(horizon, gloom)
        sun = RGB(hex: 0xFF7A3D).mixed(with: RGB(hex: 0xFFF4D6), Self.smoothstep(0, 20, sunAltitude))
        let dayCloud = RGB(hex: 0xF7F8FA).mixed(with: horizon, 0.3)
        let nightCloud = RGB(hex: 0x2A3047).mixed(with: horizon, 0.3)
        cloud = nightCloud.mixed(with: dayCloud, daylight).scaled(1 - gloom * 0.55)
    }

    init(_ context: SceneContext) {
        self.init(sunAltitude: context.sun.altitude, weather: context.weather)
    }

    /// 풍경 색을 지금 빛에 맞춘다. 밤엔 남색으로 어둡게, 궂은 날엔 바랜다.
    func shade(_ base: RGB) -> RGB {
        Self.dull(base.mixed(with: RGB(hex: 0x0B1022), (1 - daylight) * 0.82), gloom * 0.6)
    }

    static func clearSky(at altitude: Double) -> (zenith: RGB, horizon: RGB) {
        guard let upper = keyframes.firstIndex(where: { $0.altitude > altitude }) else {
            return (keyframes[keyframes.count - 1].zenith, keyframes[keyframes.count - 1].horizon)
        }
        guard upper > 0 else { return (keyframes[0].zenith, keyframes[0].horizon) }
        let a = keyframes[upper - 1], b = keyframes[upper]
        let t = (altitude - a.altitude) / (b.altitude - a.altitude)
        return (a.zenith.mixed(with: b.zenith, t), a.horizon.mixed(with: b.horizon, t))
    }

    static func gloom(of weather: WeatherSample) -> Double {
        let base: Double = switch weather.condition {
        case .clear: 0
        case .partlyCloudy: 0.1
        case .overcast: 0.5
        case .fog: 0.45
        case .drizzle: 0.45
        case .rain: 0.6
        case .snow: 0.4
        case .thunderstorm: 0.8
        }
        return min(1, max(base, weather.cloudCover * 0.35))
    }

    private static func dull(_ color: RGB, _ gloom: Double) -> RGB {
        let gray = RGB(r: color.luminance, g: color.luminance, b: color.luminance)
        return color.mixed(with: gray, gloom * 0.8).scaled(1 - gloom * 0.45)
    }

    static func smoothstep(_ lower: Double, _ upper: Double, _ x: Double) -> Double {
        let t = min(1, max(0, (x - lower) / (upper - lower)))
        return t * t * (3 - 2 * t)
    }
}
