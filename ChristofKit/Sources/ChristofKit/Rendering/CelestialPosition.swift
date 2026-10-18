import SwiftUI

/// 창은 적도 쪽(북반구는 남쪽)을 바라본다고 본다.
enum CelestialPosition {
    static let horizon = 0.72

    static func sun(_ sun: SunState, latitude: Double) -> UnitPoint? {
        point(altitude: sun.altitude, relativeAzimuth: relativeAzimuth(sun.azimuth, latitude: latitude))
    }

    static func moon(_ moon: MoonState, latitude: Double) -> UnitPoint? {
        point(altitude: moon.altitude, relativeAzimuth: relativeAzimuth(moon.azimuth, latitude: latitude))
    }

    private static func relativeAzimuth(_ azimuth: Double, latitude: Double) -> Double {
        normalized(azimuth - (latitude >= 0 ? 180 : 0))
    }

    private static func normalized(_ degrees: Double) -> Double {
        let d = (degrees + 180).truncatingRemainder(dividingBy: 360)
        return (d < 0 ? d + 360 : d) - 180
    }

    private static func point(altitude: Double, relativeAzimuth: Double) -> UnitPoint? {
        // 지평선에 걸친 해(일출·일몰)는 반쯤 보이게 조금 아래까지 허용한다.
        guard altitude > -2 else { return nil }
        // 고도 0 을 먼 언덕 꼭대기 높이에 둬서 일출·일몰 해가 언덕 위로 반쯤 보이게 한다.
        // 낮은 고도에서 빨리 올라가게 해(지수 0.75) 밤에 흔한 20~40도 달이 가로 창살에 덜 걸린다.
        let base = horizon - 0.035
        let x = min(0.95, max(0.05, 0.5 + relativeAzimuth / 135 * 0.45))
        let y = base - pow(min(max(altitude, 0), 75) / 75, 0.75) * (base - 0.1)
        return UnitPoint(x: x, y: y)
    }
}
