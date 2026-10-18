import Foundation
import Testing
@testable import ChristofKit

// 근거: Open-Meteo archive API (daily=sunrise,sunset, timeformat=unixtime, 2026-10-18 조회).
// 2026-12-21 은 조회 시점에 아직 오지 않아 2025-12-21 을 쓴다.
// 세 도시 2025-12-21~2026-06-21 183일 전체에서 측정한 최대 오차는 17초(부산, Open-Meteo 격자 좌표 차이 포함)라 허용 오차 2분은 넉넉하다.
private let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
private let osloTimeZone = TimeZone(identifier: "Europe/Oslo")!

struct SunTimesCase: Sendable, CustomTestStringConvertible {
    let label: String
    let latitude: Double
    let longitude: Double
    let localMidnight: TimeInterval
    let sunrise: TimeInterval
    let sunset: TimeInterval
    var testDescription: String { label }
}

private let koreanCities: [SunTimesCase] = [
    SunTimesCase(label: "서울 동지", latitude: 37.5665, longitude: 126.9780, localMidnight: 1766242800, sunrise: 1766270584, sunset: 1766305031),
    SunTimesCase(label: "서울 춘분", latitude: 37.5665, longitude: 126.9780, localMidnight: 1773932400, sunrise: 1773956182, sunset: 1773999814),
    SunTimesCase(label: "서울 하지", latitude: 37.5665, longitude: 126.9780, localMidnight: 1781967600, sunrise: 1781986263, sunset: 1782039404),
    SunTimesCase(label: "부산 동지", latitude: 35.1796, longitude: 129.0756, localMidnight: 1766242800, sunrise: 1766269693, sunset: 1766304927),
    SunTimesCase(label: "부산 춘분", latitude: 35.1796, longitude: 129.0756, localMidnight: 1773932400, sunrise: 1773955689, sunset: 1773999310),
    SunTimesCase(label: "부산 하지", latitude: 35.1796, longitude: 129.0756, localMidnight: 1781967600, sunrise: 1781986182, sunset: 1782038490),
    SunTimesCase(label: "제주 동지", latitude: 33.4996, longitude: 126.5312, localMidnight: 1766242800, sunrise: 1766270030, sunset: 1766305789),
    SunTimesCase(label: "제주 춘분", latitude: 33.4996, longitude: 126.5312, localMidnight: 1773932400, sunrise: 1773956290, sunset: 1773999905),
    SunTimesCase(label: "제주 하지", latitude: 33.4996, longitude: 126.5312, localMidnight: 1781967600, sunrise: 1781987058, sunset: 1782038812),
]

@Test("일출·일몰은 Open-Meteo 와 2분 안에서 맞는다", arguments: koreanCities)
func sunTimesMatchOpenMeteo(_ row: SunTimesCase) throws {
    let sun = SolarCalculator.state(at: Date(timeIntervalSince1970: row.localMidnight + 12 * 3600), latitude: row.latitude, longitude: row.longitude, timeZone: seoulTimeZone)
    let sunrise = try #require(sun.sunrise)
    let sunset = try #require(sun.sunset)
    #expect(abs(sunrise.timeIntervalSince1970 - row.sunrise) < 120)
    #expect(abs(sunset.timeIntervalSince1970 - row.sunset) < 120)
}

// UTC 기준 날짜를 쓰면 두 시각(UTC 6월 20일 14:59, 15:00)이 같은 날로 묶여 틀린다.
private let aroundSeoulMidnight: [(query: TimeInterval, sunrise: TimeInterval, sunset: TimeInterval)] = [
    (query: 1781967600 - 30, sunrise: 1781899851, sunset: 1781952989),
    (query: 1781967600 + 30, sunrise: 1781986263, sunset: 1782039404),
]

@Test("지역 시간대 자정 직전·직후는 각자 그날의 일출·일몰을 돌려준다", arguments: aroundSeoulMidnight)
func sunTimesFollowLocalDay(_ row: (query: TimeInterval, sunrise: TimeInterval, sunset: TimeInterval)) throws {
    let sun = SolarCalculator.state(at: Date(timeIntervalSince1970: row.query), latitude: 37.5665, longitude: 126.9780, timeZone: seoulTimeZone)
    #expect(abs(try #require(sun.sunrise).timeIntervalSince1970 - row.sunrise) < 120)
    #expect(abs(try #require(sun.sunset).timeIntervalSince1970 - row.sunset) < 120)
}

// 근거: Open-Meteo archive (78.0°N 15.6°E, Europe/Oslo). 백야는 일출=0시·일몰=다음 0시, 극야는 셋 다 0시로 온다.
@Test("위도 78°의 백야·극야에는 일출·일몰이 없다", arguments: [
    1782000000.0, // 2026-06-21 02:00 CEST, 백야
    1766300000.0, // 2025-12-21 07:53 CET, 극야
])
func polarDayAndNightHaveNoSunTimes(_ query: TimeInterval) {
    let sun = SolarCalculator.state(at: Date(timeIntervalSince1970: query), latitude: 78.0, longitude: 15.6, timeZone: osloTimeZone)
    #expect(sun.sunrise == nil)
    #expect(sun.sunset == nil)
}

@Test("위도 78°라도 춘분에는 일출·일몰이 있다")
func polarLatitudeHasSunTimesAtEquinox() throws {
    // Open-Meteo 2026-03-20: 일출 1773982329, 일몰 1774027344. 조회 시각은 2026-03-20 12:00 CET.
    let sun = SolarCalculator.state(at: Date(timeIntervalSince1970: 1774004400), latitude: 78.0, longitude: 15.6, timeZone: osloTimeZone)
    #expect(abs(try #require(sun.sunrise).timeIntervalSince1970 - 1773982329) < 120)
    #expect(abs(try #require(sun.sunset).timeIntervalSince1970 - 1774027344) < 120)
}

// 근거: USNO celnav API 의 해 Hc(보정 전 계산 고도)·Zn(방위각). 측정 최대 오차 0.014°.
private let usnoSunPositions: [(utc: TimeInterval, latitude: Double, longitude: Double, altitude: Double, azimuth: Double)] = [
    (utc: 1773977400, latitude: 37.5665, longitude: 126.9780, altitude: 52.182586, azimuth: 176.072058), // 서울 2026-03-20 03:30Z 남중 무렵
    (utc: 1782000000, latitude: 37.5665, longitude: 126.9780, altitude: 42.501004, azimuth: 91.387858), // 서울 2026-06-21 00:00Z 오전
    (utc: 1766296800, latitude: 35.1796, longitude: 129.0756, altitude: 20.42527, azimuth: 218.575826), // 부산 2025-12-21 06:00Z 오후
    (utc: 1782032400, latitude: 33.4996, longitude: 126.5312, altitude: 19.762192, azimuth: 285.607275), // 제주 2026-06-21 09:00Z 저녁
    (utc: 1768442400, latitude: -33.8688, longitude: 151.2093, altitude: 77.239322, azimuth: 4.658756), // 시드니 2026-01-15 02:00Z, 남반구라 해가 북쪽
    (utc: 1782079200, latitude: 78.0, longitude: 15.6, altitude: 11.810859, azimuth: 346.074456), // 78°N 2026-06-21 22:00Z 한밤의 해
]

@Test("해의 고도·방위각은 USNO 와 0.05° 안에서 맞는다", arguments: usnoSunPositions)
func sunPositionMatchesUSNO(_ row: (utc: TimeInterval, latitude: Double, longitude: Double, altitude: Double, azimuth: Double)) {
    let sun = SolarCalculator.state(at: Date(timeIntervalSince1970: row.utc), latitude: row.latitude, longitude: row.longitude, timeZone: .gmt)
    #expect(abs(sun.altitude - row.altitude) < 0.05)
    #expect(abs(sun.azimuth - row.azimuth) < 0.05)
}

// 근거: USNO moon/phases API (UTC, 분 단위). 2025-01~2026-01 50개 위상에서 측정한 최대 위상 오차 0.0006(약 0.4시간).
// 허용 오차 0.002(약 1.4시간)는 그 세 배 여유이고, 평균 삭망월만 쓴 방식의 실제 오차(최대 0.032, 22시간)는 걸러낸다.
private let usnoMoonPhases: [(label: String, utc: TimeInterval, phase: Double)] = [
    (label: "삭 1999-12-07 22:32, 기준 삭 이전", utc: 944605920, phase: 0),
    (label: "망 1999-12-22 17:31, 기준 삭 이전", utc: 945883860, phase: 0.5),
    (label: "망 2025-01-13 22:27", utc: 1736807220, phase: 0.5),
    (label: "삭 2025-01-29 12:36", utc: 1738154160, phase: 0),
    (label: "상현 2025-07-02 19:30", utc: 1751484600, phase: 0.25),
    (label: "망 2025-10-07 03:47", utc: 1759808820, phase: 0.5),
    (label: "하현 2025-11-12 05:28", utc: 1762925280, phase: 0.75),
]

@Test("달 위상은 USNO 삭·상현·망·하현 시각에 0·0.25·0.5·0.75 와 맞는다", arguments: usnoMoonPhases)
func moonPhaseMatchesUSNO(_ row: (label: String, utc: TimeInterval, phase: Double)) {
    // 위상은 관측지와 무관하다.
    let moon = MoonCalculator.state(at: Date(timeIntervalSince1970: row.utc), latitude: 0, longitude: 0)
    #expect((0..<1).contains(moon.phase))
    let difference = moon.phase - row.phase
    #expect(abs(difference - difference.rounded()) < 0.002, "\(row.label): \(moon.phase)")
    #expect(abs(moon.illumination - (1 - cos(2 * .pi * row.phase)) / 2) < 0.001)
}

// 근거: USNO celnav API 의 달 Hc(시차·굴절 보정 전 계산 고도)·Zn(방위각). 측정 최대 오차 0.28°.
private let usnoMoonPositions: [(label: String, utc: TimeInterval, latitude: Double, longitude: Double, altitude: Double, azimuth: Double)] = [
    (label: "서울 2026-12-24 21:00 KST, 겨울 보름달은 높이 뜬다", utc: 1798113600, latitude: 37.5665, longitude: 126.9780, altitude: 38.858428, azimuth: 83.930294),
    (label: "서울 2026-09-25 21:00 KST 추석", utc: 1790337600, latitude: 37.5665, longitude: 126.9780, altitude: 36.755321, azimuth: 131.954286),
    (label: "서울 2026-03-22 20:00 KST 초승달은 서쪽", utc: 1774177200, latitude: 37.5665, longitude: 126.9780, altitude: 29.451365, azimuth: 275.698788),
    (label: "부산 2026-06-21 19:41 KST 상현 무렵", utc: 1782038460, latitude: 35.10168, longitude: 129.03004, altitude: 48.317631, azimuth: 219.00742),
    (label: "시드니 2026-01-04 03:00 AEDT, 남반구라 달이 북쪽", utc: 1767542400, latitude: -33.8688, longitude: 151.2093, altitude: 32.177303, azimuth: 347.904183),
]

@Test("달의 고도·방위각은 USNO 와 0.5° 안에서 맞는다", arguments: usnoMoonPositions)
func moonPositionMatchesUSNO(_ row: (label: String, utc: TimeInterval, latitude: Double, longitude: Double, altitude: Double, azimuth: Double)) {
    let moon = MoonCalculator.state(at: Date(timeIntervalSince1970: row.utc), latitude: row.latitude, longitude: row.longitude)
    #expect(abs(moon.altitude - row.altitude) < 0.5, "\(row.label): \(moon.altitude)")
    #expect(abs(moon.azimuth - row.azimuth) < 0.5, "\(row.label): \(moon.azimuth)")
}

@Test("USNO 목록에 없는(지평선 아래) 달은 고도가 음수다")
func moonBelowHorizonHasNegativeAltitude() {
    // 서울 2026-10-31 20:00 KST: 하현 무렵이라 아직 뜨지 않았고 USNO celnav 가 달을 내주지 않는다.
    #expect(MoonCalculator.state(at: Date(timeIntervalSince1970: 1793444400), latitude: 37.5665, longitude: 126.9780).altitude < 0)
}
