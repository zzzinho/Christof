import Foundation
import Testing
@testable import ChristofKit

private func kst(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
    return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

private let seoul = CountryRegistry.standard.region(id: "KR.seoul")!
private let unregistered = Region(id: "XX.test", name: LocalizedName(en: "Unregistered", ko: "미등록"), countryCode: "XX", latitude: seoul.latitude, longitude: seoul.longitude, timeZone: seoul.timeZone)

// 일몰 2026-05-24 19:41 KST 는 SolarCalculator 값.
@Test("장면의 이벤트는 국가 이벤트 다음에 하늘 이벤트를 붙인다", arguments: [
    ("추석 밤엔 추석 다음에 보름달", seoul, kst(2026, 9, 25, 21), ["KR.chuseok", "sky.fullMoon"]),
    ("겨울 보름달이 높이 뜬 크리스마스 이브 밤", seoul, kst(2026, 12, 24, 21), ["KR.christmasEve", "sky.fullMoon"]),
    ("부처님오신날 해 질 녘", seoul, kst(2026, 5, 24, 19, 40), ["KR.buddhasBirthday", "sky.sunset"]),
    ("명절 기간이 아닌 낮엔 이벤트가 없다", seoul, kst(2026, 7, 20, 14), []),
    ("국가 프로필이 없는 지역은 하늘 이벤트만", unregistered, kst(2026, 9, 25, 21), ["sky.fullMoon"]),
])
func contextCollectsActiveOccasionsInPriorityOrder(_ label: String, _ region: Region, _ date: Date, _ expected: [String]) {
    let context = SceneContextFactory().context(at: date, region: region, forecast: nil)
    #expect(context.occasions.map(\.id) == expected, "\(label)")
}

@Test("보름달 이벤트가 진행 중인 장면에는 달이 창 안에 보인다")
func fullMoonOccasionIsVisibleInTheWindow() {
    // 해 위치로 달 자리를 근사하던 때는 겨울 보름달이 이 시각 지평선 아래로 계산돼 이벤트만 있고 달은 없었다.
    let context = SceneContextFactory().context(at: kst(2026, 12, 24, 21), region: seoul, forecast: nil)
    #expect(context.occasions.contains { $0.id == "sky.fullMoon" })
    #expect(CelestialPosition.moon(context.moon, latitude: context.region.latitude) != nil)
}
