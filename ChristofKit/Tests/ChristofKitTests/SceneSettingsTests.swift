import Foundation
import Testing
@testable import ChristofKit

private let seoul = CountryRegistry.standard.region(id: "KR.seoul")!

private func kst(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = seoul.timeZone
    return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

@Test("기본 설정은 지금 시각과 실제 날씨를 쓴다")
func liveSettingsUseNowAndRealWeather() {
    let now = kst(2026, 10, 18, 15)
    let real = WeatherForecast(samples: [.forced(.rain, at: now)])
    let context = SceneContextFactory().context(now: now, region: seoul, realForecast: real, settings: .live)
    #expect(context.date == now)
    #expect(context.weather?.condition == .rain)
}

@Test("고정 시각·강제 날씨·수동 이벤트를 한 번에 적용한다")
func savedSettingsOverrideScene() {
    let settings = SceneSettings(fixedDate: kst(2026, 12, 24, 21), forcedWeather: .snow, occasion: .manual(occasionID: "KR.halloween"))
    let real = WeatherForecast(samples: [.forced(.rain, at: kst(2026, 10, 18, 15))])
    let context = SceneContextFactory().context(now: kst(2026, 10, 18, 15), region: seoul, realForecast: real, settings: settings)
    #expect(context.date == kst(2026, 12, 24, 21))
    #expect(context.weather?.condition == .snow)
    // 2026-12-24 밤은 보름이라 해·달 이벤트인 보름달은 그대로 붙는다.
    #expect(context.occasions.map(\.id) == ["KR.halloween", "sky.fullMoon"])
}

@Test("저장한 설정을 다시 읽는다")
func storeRoundTrip() {
    let suite = "christof.tests.\(UUID().uuidString)"
    defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
    let store = SceneSettingsStore(suiteName: suite)
    #expect(store.load() == .live)
    let settings = SceneSettings(fixedDate: kst(2026, 9, 25, 21), forcedWeather: .clear, occasion: .manual(occasionID: "KR.chuseok"))
    store.save(settings)
    #expect(store.load() == settings)
}
