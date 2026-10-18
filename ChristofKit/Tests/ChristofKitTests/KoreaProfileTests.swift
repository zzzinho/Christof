import Foundation
import Testing
@testable import ChristofKit

private let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!

private func kst(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = seoulTimeZone
    return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

private func occasion(_ id: String) throws -> Occasion {
    try #require(KoreaProfile().occasions.first { $0.id == id })
}

private let seoul = KoreaRegions.all[0]

// 날짜는 Calendar(identifier: .dangi) 로 다시 계산해 확인했다.
@Test("명절은 연휴 첫날부터 마지막 날까지만 진행 중", arguments: [
    ("KR.seollal", kst(2025, 1, 28), kst(2025, 1, 30)), // 전날이 음력 12/29 (29일 달)
    ("KR.seollal", kst(2026, 2, 16), kst(2026, 2, 18)),
    ("KR.seollal", kst(2027, 2, 6), kst(2027, 2, 8)), // 전날이 음력 12/30 (30일 달)
    ("KR.chuseok", kst(2025, 10, 5), kst(2025, 10, 7)), // 윤6월이 있는 해
    ("KR.chuseok", kst(2026, 9, 24), kst(2026, 9, 26)),
    ("KR.chuseok", kst(2027, 9, 14), kst(2027, 9, 16)),
    ("KR.buddhasBirthday", kst(2025, 5, 5), kst(2025, 5, 5)),
    ("KR.buddhasBirthday", kst(2026, 5, 24), kst(2026, 5, 24)),
    ("KR.jeongwolDaeboreum", kst(2026, 3, 3), kst(2026, 3, 3)),
    ("KR.christmas", kst(2026, 12, 25), kst(2026, 12, 25)),
])
func holidaySpan(_ id: String, _ first: Date, _ last: Date) throws {
    let holiday = try occasion(id)
    let oneDay: TimeInterval = 24 * 3600
    #expect(!holiday.isActive(at: first - oneDay, in: seoul), "연휴 전날")
    for day in stride(from: first, through: last, by: oneDay) {
        #expect(holiday.isActive(at: day, in: seoul), "\(day)")
    }
    #expect(!holiday.isActive(at: last + oneDay, in: seoul), "연휴 다음 날")
}

@Test("추석 연휴는 마지막 날 23:59 KST 까지", arguments: [
    (kst(2026, 9, 26, 23, 59), true),
    (kst(2026, 9, 27, 0, 0), false),
])
func chuseokEndsAtMidnight(_ date: Date, _ expected: Bool) throws {
    #expect(try occasion("KR.chuseok").isActive(at: date, in: seoul) == expected)
}

@Test("같은 순간이라도 지역 시간대의 날짜로 판정한다", arguments: [
    (kst(2026, 9, 27, 0, 30), false, true), // UTC 로는 9/26 15:30, 아직 연휴
    (kst(2026, 9, 24, 0, 30), true, false), // UTC 로는 9/23 15:30, 아직 연휴 전
])
func judgesInRegionTimeZone(_ date: Date, _ inSeoul: Bool, _ inUTC: Bool) throws {
    let utcRegion = Region(id: "test.utc", name: "UTC", countryCode: "KR", latitude: seoul.latitude, longitude: seoul.longitude, timeZone: TimeZone(identifier: "UTC")!)
    let chuseok = try occasion("KR.chuseok")
    #expect(chuseok.isActive(at: date, in: seoul) == inSeoul)
    #expect(chuseok.isActive(at: date, in: utcRegion) == inUTC)
}

@Test("한국 지역은 id 가 고유하고 한국 안에 있으며 서울이 기본 지역이다")
func koreaRegions() {
    let regions = KoreaProfile().regions
    #expect(Set(regions.map(\.id)).count == regions.count)
    for region in regions {
        #expect(region.id.hasPrefix("KR.") && region.countryCode == "KR", "\(region.id)")
        #expect(region.timeZone.identifier == "Asia/Seoul", "\(region.id)")
        // 남한 범위: 마라도 33.1°N ~ 강원 북단 38.6°N, 서해 124.6°E ~ 독도 131.9°E
        #expect((33.0...38.7).contains(region.latitude) && (124.5...132.0).contains(region.longitude), "\(region.id)")
    }
    #expect(CountryRegistry.standard.defaultRegion.id == "KR.seoul")
}

@Test("한국 이벤트 id 는 고유하다")
func koreaOccasionIDs() {
    let ids = KoreaProfile().occasions.map(\.id)
    #expect(Set(ids).count == ids.count)
    #expect(ids.allSatisfy { $0.hasPrefix("KR.") })
}
