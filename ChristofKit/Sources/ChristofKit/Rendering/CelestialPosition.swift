import SwiftUI

/// 창은 적도 쪽(북반구는 남쪽)을 바라본다고 본다. 결과는 유리 가로 0~1 과 높이 0(지평선)~1(고도 75°)이고, 높이를 칸으로 바꾸는 건 bodyCircle 이다.
enum CelestialPosition {
    typealias Point = (x: Double, rise: Double)

    static func sun(_ sun: SunState, latitude: Double) -> Point? {
        point(altitude: sun.altitude, relativeAzimuth: relativeAzimuth(sun.azimuth, latitude: latitude))
    }

    static func moon(_ moon: MoonState, latitude: Double) -> Point? {
        point(altitude: moon.altitude, relativeAzimuth: relativeAzimuth(moon.azimuth, latitude: latitude))
    }

    private static func relativeAzimuth(_ azimuth: Double, latitude: Double) -> Double {
        normalized(azimuth - (latitude >= 0 ? 180 : 0))
    }

    private static func normalized(_ degrees: Double) -> Double {
        let d = (degrees + 180).truncatingRemainder(dividingBy: 360)
        return (d < 0 ? d + 360 : d) - 180
    }

    private static func point(altitude: Double, relativeAzimuth: Double) -> Point? {
        // 지평선에 걸친 해(일출·일몰)는 반쯤 보이게 조금 아래까지 허용한다.
        guard altitude > -2 else { return nil }
        // 낮은 고도에서 빨리 올라가게 해(지수 0.75) 밤에 흔한 20~40도 달이 가로 창살에 덜 걸린다.
        let x = min(0.95, max(0.05, 0.5 + relativeAzimuth / 135 * 0.45))
        return (x, pow(min(max(altitude, 0), 75) / 75, 0.75))
    }
}
