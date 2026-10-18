import SwiftUI

/// 해·달이 유리 안 어디에 보이는지 정한다. 단위 좌표(0...1, 왼쪽 위 원점). 지평선 아래면 nil.
/// 창은 적도 쪽(북반구는 남쪽)을 바라본다고 본다.
enum CelestialPosition {
    /// 유리 높이 대비 지평선 높이. 풍경도 이 선에 맞춘다.
    static let horizon = 0.72

    static func sun(_ sun: SunState, latitude: Double) -> UnitPoint? {
        point(altitude: sun.altitude, relativeAzimuth: relativeAzimuth(sun.azimuth, latitude: latitude))
    }

    static func moon(_ moon: MoonState, latitude: Double) -> UnitPoint? {
        point(altitude: moon.altitude, relativeAzimuth: relativeAzimuth(moon.azimuth, latitude: latitude))
    }

    /// 창이 바라보는 방향 기준 방위각, -180..<180. 음수가 왼쪽(북반구에서 동쪽).
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
