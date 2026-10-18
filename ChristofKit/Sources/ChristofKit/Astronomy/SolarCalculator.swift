import Foundation

/// NOAA 태양 위치 알고리즘.
public enum SolarCalculator {
    public static func state(at date: Date, latitude: Double, longitude: Double, timeZone: TimeZone) -> SunState {
        let sun = SolarPosition(date: date)
        // ponytail: 대기 굴절 보정이 없는 기하학적 고도라 지평선 근처에서 최대 0.6° 낮다. 정밀한 고도가 필요하면 NOAA 굴절 보정식을 더한다.
        let position = horizontalCoordinates(
            hourAngle: radians(sun.hourAngle(at: date, longitude: longitude)), declination: sun.declination, latitude: radians(latitude))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        // 일광 절약 시간 전환일에 한 시간 어긋나도 첫 추정값이라 결과에는 영향이 없다.
        let localNoon = calendar.startOfDay(for: date).addingTimeInterval(12 * 3600)
        return SunState(
            altitude: position.altitude,
            azimuth: position.azimuth,
            sunrise: horizonCrossing(near: localNoon, latitude: latitude, longitude: longitude, rising: true),
            sunset: horizonCrossing(near: localNoon, latitude: latitude, longitude: longitude, rising: false)
        )
    }

    // ponytail: 현지 12:00 기준 ±12시간 안의 사건을 고른다. 자정을 넘는 일몰은 그날 0시 이후 시각, 곧 전날 저녁에 진 시각으로 나와
    // sunset < sunrise 가 될 수 있다. 그날 저녁의 일몰이 필요하면 다음 날로 한 번 더 구한다.
    // -0.833° 는 해 윗가장자리가 지평선에 닿는 고도다.
    private static func horizonCrossing(near start: Date, latitude: Double, longitude: Double, rising: Bool) -> Date? {
        let lat = radians(latitude)
        var time = start
        // 적위와 균시차를 사건 시각에서 다시 구하려고 되풀이한다. 세 번으로 Open-Meteo 대비 최대 17초.
        for _ in 0..<3 {
            let sun = SolarPosition(date: time)
            let cosHalfDay = (sin(radians(-0.833)) - sin(lat) * sin(sun.declination)) / (cos(lat) * cos(sun.declination))
            guard abs(cosHalfDay) <= 1 else { return nil }
            let halfDay = degrees(acos(cosHalfDay))
            let target = rising ? -halfDay : halfDay
            time += wrapped(target - sun.hourAngle(at: time, longitude: longitude)) / 15 * 3600
        }
        return time
    }
}

private func radians(_ degrees: Double) -> Double { degrees * .pi / 180 }
private func degrees(_ radians: Double) -> Double { radians * 180 / .pi }

private func wrapped(_ degrees: Double) -> Double {
    let turns = (degrees + 180) / 360
    return (turns - turns.rounded(.down)) * 360 - 180
}

private struct SolarPosition {
    let declination: Double
    let equationOfTime: Double

    init(date: Date) {
        let t = (date.timeIntervalSince1970 / 86400 + 2440587.5 - 2451545) / 36525
        let meanLongitude = radians((280.46646 + t * (36000.76983 + t * 0.0003032)).truncatingRemainder(dividingBy: 360))
        let meanAnomaly = radians(357.52911 + t * (35999.05029 - 0.0001537 * t))
        let eccentricity = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
        let center = sin(meanAnomaly) * (1.914602 - t * (0.004817 + 0.000014 * t))
            + sin(2 * meanAnomaly) * (0.019993 - 0.000101 * t)
            + sin(3 * meanAnomaly) * 0.000289
        let omega = radians(125.04 - 1934.136 * t)
        let apparentLongitude = radians(degrees(meanLongitude) + center - 0.00569 - 0.00478 * sin(omega))
        let meanObliquity = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60
        let obliquity = radians(meanObliquity + 0.00256 * cos(omega))
        declination = asin(sin(obliquity) * sin(apparentLongitude))

        let y = pow(tan(obliquity / 2), 2)
        let e = eccentricity, l = meanLongitude, m = meanAnomaly
        equationOfTime = 4 * degrees(
            y * sin(2 * l) - 2 * e * sin(m) + 4 * e * y * sin(m) * cos(2 * l)
                - 0.5 * y * y * sin(4 * l) - 1.25 * e * e * sin(2 * m)
        )
    }

    func hourAngle(at date: Date, longitude: Double) -> Double {
        let utcMinutes = date.timeIntervalSince1970.truncatingRemainder(dividingBy: 86400) / 60
        let trueSolarMinutes = utcMinutes + equationOfTime + 4 * longitude
        return wrapped(trueSolarMinutes / 4 - 180)
    }
}
