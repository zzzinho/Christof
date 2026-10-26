import Foundation
import Testing
@testable import ChristofKit

private let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
private let seoul = Region(id: "test.seoul", name: "서울", countryCode: "KR", latitude: 37.566, longitude: 126.9784, timeZone: seoulTimeZone)

private func kst(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = seoulTimeZone
    return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

@Test("양력 규칙은 지역 시간대의 하루 단위로, 앞뒤 날짜는 연도를 넘어서도 판정한다", arguments: [
    ("크리스마스 0시부터 진행 중", GregorianDateRule(month: 12, day: 25), kst(2026, 12, 25, 0, 0), true),
    ("크리스마스 23:59 까지 진행 중", GregorianDateRule(month: 12, day: 25), kst(2026, 12, 25, 23, 59), true),
    ("전날 23:59 는 아니다", GregorianDateRule(month: 12, day: 25), kst(2026, 12, 24, 23, 59), false),
    ("다음 날 0시는 아니다", GregorianDateRule(month: 12, day: 25), kst(2026, 12, 26, 0, 0), false),
    ("1/1 의 전날은 지난해 12/31", GregorianDateRule(month: 1, day: 1, daysBefore: 1, daysAfter: 1), kst(2025, 12, 31), true),
    ("1/1 의 다음 날 1/2", GregorianDateRule(month: 1, day: 1, daysBefore: 1, daysAfter: 1), kst(2026, 1, 2), true),
    ("전날보다 하루 앞은 아니다", GregorianDateRule(month: 1, day: 1, daysBefore: 1, daysAfter: 1), kst(2025, 12, 30), false),
    ("다음 날보다 하루 뒤는 아니다", GregorianDateRule(month: 1, day: 1, daysBefore: 1, daysAfter: 1), kst(2026, 1, 3), false),
])
func gregorianDateRule(_ label: String, _ rule: GregorianDateRule, _ date: Date, _ expected: Bool) {
    #expect(rule.isActive(at: date, in: seoul) == expected, "\(label)")
}

// 2025년은 윤6월이 있다(dangi: 6/15 = 7/9, 윤6/15 = 8/8).
@Test("음력 규칙은 평달만 맞고 윤달은 맞지 않는다", arguments: [
    (kst(2025, 7, 9), true),
    (kst(2025, 8, 8), false),
])
func lunarDateRuleIgnoresLeapMonth(_ date: Date, _ expected: Bool) {
    #expect(LunarDateRule(calendar: .dangi, month: 6, day: 15).isActive(at: date, in: seoul) == expected)
}

// Foundation 기준 2027년 음력 설: .dangi 2/7, .chinese 2/6. 초하루 삭이 두 나라 표준시 자정 사이에 든 해다.
@Test("음력 규칙은 국가 프로필이 고른 달력으로 판정한다", arguments: [
    (Calendar.Identifier.dangi, kst(2027, 2, 7), true),
    (.dangi, kst(2027, 2, 6), false),
    (.chinese, kst(2027, 2, 6), true),
])
func lunarDateRuleUsesTheGivenCalendar(_ calendar: Calendar.Identifier, _ date: Date, _ expected: Bool) {
    #expect(LunarDateRule(calendar: calendar, month: 1, day: 1).isActive(at: date, in: seoul) == expected)
}

@Test("일출·일몰 규칙은 계산된 시각 앞뒤 30분 안에서만 진행 중", arguments: [SunEventRule.Event.sunrise, .sunset], [
    (-31.0, false), (-29.0, true), (29.0, true), (31.0, false),
])
func sunEventRuleWindow(_ event: SunEventRule.Event, _ offset: (minutes: Double, expected: Bool)) throws {
    let day = kst(2026, 6, 21)
    let sun = SolarCalculator.state(at: day, latitude: seoul.latitude, longitude: seoul.longitude, timeZone: seoul.timeZone)
    let time = try #require(event == .sunrise ? sun.sunrise : sun.sunset, "서울 하지에는 해가 뜨고 진다")
    let rule = SunEventRule(event, window: 30 * 60)
    #expect(rule.isActive(at: time.addingTimeInterval(offset.minutes * 60), in: seoul) == offset.expected)
}

// Open-Meteo archive: 레이캬비크 2026-06-20 일몰은 6/21 00:01:51 UTC(자정을 넘는다).
@Test("자정을 넘는 일몰도 자정 전 창에서 진행 중", arguments: [
    ("레이캬비크 하지 무렵 23:45, 일몰 17분 전", Date(timeIntervalSince1970: 1782000111 - 17 * 60), true),
])
func sunEventRuleAcrossMidnight(_ label: String, _ date: Date, _ expected: Bool) {
    let reykjavik = Region(id: "test.reykjavik", name: "레이캬비크", countryCode: "IS", latitude: 64.1355, longitude: -21.8954, timeZone: TimeZone(identifier: "Atlantic/Reykjavik")!)
    #expect(SunEventRule(.sunset, window: 30 * 60).isActive(at: date, in: reykjavik) == expected, "\(label)")
}

@Test("극야로 해가 뜨지 않는 날은 일출 이벤트가 없다")
func sunEventRuleWithoutSunrise() {
    let longyearbyen = Region(id: "test.svalbard", name: "롱위에아르뷔엔", countryCode: "NO", latitude: 78.2232, longitude: 15.6267, timeZone: TimeZone(identifier: "Arctic/Longyearbyen")!)
    #expect(!SunEventRule(.sunrise, window: 30 * 60).isActive(at: kst(2026, 12, 21), in: longyearbyen))
}

// 보름: 2025-10-07 03:47 UTC (12:47 KST).
// USNO rstt: 2026-03-04 서울 일몰 18:28, 월출 19:23 (보름 다음 날, 밝은 면 0.99).
@Test("보름달 규칙은 달이 거의 차서 해가 진 하늘에 떠 있을 때만 진행 중", arguments: [
    ("보름 당일 밤", kst(2025, 10, 7, 21, 0), true),
    ("보름이어도 해가 떠 있는 낮은 아니다", kst(2025, 10, 7, 12, 0), false),
    ("보름 이틀 뒤 밤은 아니다", kst(2025, 10, 9, 21, 0), false),
    ("보름 사흘 뒤 밤은 아니다", kst(2025, 10, 10, 21, 0), false),
    ("해가 졌어도 보름달이 뜨기 전은 아니다", kst(2026, 3, 4, 19, 0), false),
    ("같은 날 보름달이 뜬 뒤는 진행 중", kst(2026, 3, 4, 20, 0), true),
])
func fullMoonRule(_ label: String, _ date: Date, _ expected: Bool) {
    #expect(FullMoonRule().isActive(at: date, in: seoul) == expected, "\(label)")
}

@Test("하늘 이벤트는 일출·일몰·보름달이다")
func celestialOccasions() {
    #expect(CelestialOccasions.all.map(\.id) == ["sky.sunrise", "sky.sunset", "sky.fullMoon"])
}
