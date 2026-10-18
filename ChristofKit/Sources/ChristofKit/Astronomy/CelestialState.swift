import Foundation

public struct SunState: Sendable, Hashable {
    /// 지평선 위 고도(도). 음수면 지평선 아래.
    public let altitude: Double
    /// 방위각(도). 북 0, 동 90, 시계 방향.
    public let azimuth: Double
    /// 그날(지역 시간대 기준)의 일출·일몰. 백야·극야면 nil.
    public let sunrise: Date?
    public let sunset: Date?

    public init(altitude: Double, azimuth: Double, sunrise: Date?, sunset: Date?) {
        self.altitude = altitude
        self.azimuth = azimuth
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

public struct MoonState: Sendable, Hashable {
    /// 위상, 0..<1. 0 삭, 0.25 상현, 0.5 망(보름), 0.75 하현.
    public let phase: Double
    /// 밝게 보이는 면의 비율, 0...1.
    public let illumination: Double
    /// 지평선 위 고도(도). 음수면 지평선 아래.
    public let altitude: Double
    /// 방위각(도). 북 0, 동 90, 시계 방향.
    public let azimuth: Double

    public init(phase: Double, illumination: Double, altitude: Double, azimuth: Double) {
        self.phase = phase
        self.illumination = illumination
        self.altitude = altitude
        self.azimuth = azimuth
    }
}
