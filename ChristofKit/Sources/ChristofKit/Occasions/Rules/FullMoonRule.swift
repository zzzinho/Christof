import Foundation

public struct FullMoonRule: OccasionRule {
    /// 0.98 은 보름 순간 앞뒤 약 1.3일이다.
    public let minimumIllumination: Double

    public init(minimumIllumination: Double = 0.98) {
        self.minimumIllumination = minimumIllumination
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        let moon = MoonCalculator.state(at: date, latitude: region.latitude, longitude: region.longitude)
        return moon.illumination >= minimumIllumination && moon.altitude > 0
            && SolarCalculator.state(at: date, latitude: region.latitude, longitude: region.longitude, timeZone: region.timeZone).altitude < 0
    }
}
