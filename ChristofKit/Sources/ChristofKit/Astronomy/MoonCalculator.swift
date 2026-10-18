import Foundation

/// 달의 위상, 밝은 면의 비율, 관측지에서 본 고도·방위각을 구한다.
public enum MoonCalculator {
    public static func state(at date: Date, latitude: Double, longitude: Double) -> MoonState {
        let days = date.timeIntervalSince1970 / 86400 + 2440587.5 - 2451545
        let t = days / 36525
        // Meeus, Astronomical Algorithms 47장의 평균 요소(도). D 는 평균 이각이라 평균 삭망월과 같은 속도로 돈다.
        let d = 297.8501921 + 445267.1114034 * t
        let m = 357.5291092 + 35999.0502909 * t
        let mp = 134.9633964 + 477198.8675055 * t
        let f = 93.2720950 + 483202.0175233 * t
        // ponytail: 평균 삭망월만 쓰면 USNO 위상 시각과 최대 22시간 어긋나서, 달 황경 주요항 6개와 해 중심차를 더한 황경 이각을 쓴다.
        // 2025~2026 USNO 50개 위상 대비 최대 0.4시간. 더 필요하면 Meeus 표 47.A 의 나머지 항을 더한다.
        let moonTerms = 6.288774 * sin(radians(mp))
            + 1.274027 * sin(radians(2 * d - mp))
            + 0.658314 * sin(radians(2 * d))
            + 0.213618 * sin(radians(2 * mp))
            - 0.185116 * sin(radians(m))
            - 0.114332 * sin(radians(2 * f))
        let sunCenter = 1.914602 * sin(radians(m)) + 0.019993 * sin(radians(2 * m))
        let turns = (d + moonTerms - sunCenter) / 360
        let fraction = turns - turns.rounded(.down)
        // 음수 쪽 아주 작은 값은 1 로 반올림될 수 있어 0..<1 을 지킨다.
        let phase = fraction < 1 ? fraction : 0

        // 황경은 평균 황경 L' 에 위 주요항을, 황위는 표 47.B 주요항 4개를 쓴다.
        let eclipticLongitude = radians(218.3164477 + 481267.88123421 * t + moonTerms)
        let eclipticLatitude = radians(
            5.128122 * sin(radians(f))
                + 0.280602 * sin(radians(mp + f))
                + 0.277693 * sin(radians(mp - f))
                + 0.173237 * sin(radians(2 * d - f)))
        let obliquity = radians(23.439291 - 0.0130042 * t)
        let rightAscension = atan2(
            sin(eclipticLongitude) * cos(obliquity) - tan(eclipticLatitude) * sin(obliquity), cos(eclipticLongitude))
        let declination = asin(
            sin(eclipticLatitude) * cos(obliquity) + cos(eclipticLatitude) * sin(obliquity) * sin(eclipticLongitude))
        let greenwichSiderealTime = radians(280.46061837 + 360.98564736629 * days)
        // ponytail: 지구 중심에서 본 고도라 시차(최대 약 0.95°)만큼 실제보다 높다. USNO Hc 대비 7곳 최대 0.28°로 그림·이벤트 판정에는 충분하다.
        // 지평선 근처 정밀도가 필요하면 고도에서 0.95°·cos(고도)를 뺀다.
        let position = horizontalCoordinates(
            hourAngle: greenwichSiderealTime + radians(longitude) - rightAscension, declination: declination, latitude: radians(latitude))

        // ponytail: 황경 차이만 쓰고 달의 황위는 무시한다. 밝은 면 비율 오차는 1% 안팎이라 그림에는 충분하다.
        return MoonState(
            phase: phase, illumination: (1 - cos(2 * .pi * phase)) / 2, altitude: position.altitude, azimuth: position.azimuth)
    }

    private static func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}
