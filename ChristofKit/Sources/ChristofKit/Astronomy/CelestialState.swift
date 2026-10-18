import Foundation

// 각도는 모두 도 단위. 방위각은 북 0, 시계 방향.
public struct SunState: Sendable, Hashable {
    public let altitude: Double
    public let azimuth: Double
    /// 지역 시간대 기준 그날의 값. 백야·극야면 nil.
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
    /// 0..<1. 0 삭, 0.25 상현, 0.5 보름, 0.75 하현.
    public let phase: Double
    /// 밝게 보이는 면의 비율, 0...1.
    public let illumination: Double
    public let altitude: Double
    public let azimuth: Double

    public init(phase: Double, illumination: Double, altitude: Double, azimuth: Double) {
        self.phase = phase
        self.illumination = illumination
        self.altitude = altitude
        self.azimuth = azimuth
    }
}
