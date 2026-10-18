import Foundation
import Testing
@testable import ChristofKit

private let seoul = CountryRegistry.standard.region(id: "KR.seoul")!

private func kst(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = seoul.timeZone
    return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

private func occasionIDs(at date: Date, _ selection: OccasionSelection) -> [String] {
    SceneContextFactory().context(at: date, region: seoul, forecast: nil, selection: selection).occasions.map(\.id)
}

@Test("자동이면 날짜에 맞는 명절만 나온다")
func automaticFollowsDate() {
    #expect(occasionIDs(at: kst(2026, 12, 25, 12), .automatic) == ["KR.christmas"])
    #expect(occasionIDs(at: kst(2026, 7, 1, 12), .automatic) == [])
}

@Test("수동이면 날짜와 상관없이 고른 명절 하나만 나온다")
func manualOverridesDate() {
    #expect(occasionIDs(at: kst(2026, 7, 1, 12), .manual(occasionID: "KR.chuseok")) == ["KR.chuseok"])
    #expect(occasionIDs(at: kst(2026, 12, 25, 12), .manual(occasionID: "KR.halloween")) == ["KR.halloween"])
}

@Test("수동이어도 해·달 이벤트는 날짜로 판정한다")
func manualKeepsCelestialOccasions() throws {
    let day = kst(2026, 7, 1, 12)
    let sunset = try #require(SolarCalculator.state(at: day, latitude: seoul.latitude, longitude: seoul.longitude, timeZone: seoul.timeZone).sunset)
    #expect(occasionIDs(at: sunset, .manual(occasionID: "KR.chuseok")) == ["KR.chuseok", "sky.sunset"])
}

@Test("고른 명절이 그 나라에 없으면 자동으로 돌아간다")
func unknownManualFallsBackToAutomatic() {
    #expect(occasionIDs(at: kst(2026, 12, 25, 12), .manual(occasionID: "JP.obon")) == ["KR.christmas"])
}
