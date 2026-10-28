import Foundation
import SwiftUI
import Testing
@testable import ChristofKit

private let seoul = Region(id: "KR.seoul", name: "서울", countryCode: "KR", latitude: 37.5665, longitude: 126.9780, timeZone: TimeZone(identifier: "Asia/Seoul")!)

private struct AlwaysActive: OccasionRule {
    func isActive(at date: Date, in region: Region) -> Bool { true }
}

private func sample(_ condition: WeatherCondition, cloudCover: Double = 0.5, temperature: Double = 12) -> WeatherSample {
    WeatherSample(time: .distantPast, condition: condition, intensity: 0.6, cloudCover: cloudCover, temperatureCelsius: temperature)
}

private func scene(
    sun altitude: Double = 40, azimuth: Double = 180, moonPhase: Double = 0.5, moonAltitude: Double = 40,
    weather: WeatherSample? = sample(.clear, cloudCover: 0), date: Date = .now, season: Season = .autumn, occasions: [Occasion] = []
) -> SceneContext {
    SceneContext(
        date: date, region: seoul, weather: weather,
        sun: SunState(altitude: altitude, azimuth: azimuth, sunrise: nil, sunset: nil),
        moon: MoonState(phase: moonPhase, illumination: (1 - cos(moonPhase * 2 * .pi)) / 2, altitude: moonAltitude, azimuth: 180),
        season: season, occasions: occasions)
}

@Test func paletteMatchesDesignTokens() throws {
    let css = try String(contentsOf: URL(fileURLWithPath: #filePath).appending(path: "../../../../design.css").standardizedFileURL, encoding: .utf8)
    var tokens: [String: UInt32] = [:]
    for match in css.matches(of: /--lofi-([a-z0-9-]+):\s*#([0-9A-Fa-f]{6})/) {
        tokens[String(match.1)] = UInt32(match.2, radix: 16)
    }
    #expect(!tokens.isEmpty)
    #expect(LofiPalette.colors == tokens)
}

/// 때·날씨·계절·기온마다 쓰는 색 이름이 다르다. 팔레트에 없는 이름을 쓰면 여기서 멈춘다.
@Test(arguments: [nil] + WeatherCondition.allCases)
func everyPhaseAndWeatherHasItsColors(_ condition: WeatherCondition?) {
    let large = WindowSize.expanded.referenceSize
    for altitude in [-30.0, -3, 3, 40] {
        for season in Season.allCases {
            for temperature in [-3.0, 10] {
                let context = scene(sun: altitude, moonAltitude: 30, weather: condition.map { sample($0, temperature: temperature) }, season: season)
                let grid = SceneComposer.grid(for: context, cols: Int(large.width / 3) + 1, rows: Int(large.height / 3) + 1)
                #expect(grid.cells.allSatisfy { $0 != nil })
            }
        }
    }
}

/// 이벤트 모양이 쓰는 색 이름도 팔레트에 있어야 한다. 시각마다 고양이 상태·헤드폰이 바뀌고, 낮에는 불을 끈다.
@Test(arguments: KoreaOccasions.all.map(\.id))
func everyOccasionLookHasItsColors(_ id: String) throws {
    let occasion = try #require(KoreaOccasions.all.first { $0.id == id })
    for hour in 0..<24 {
        let date = try Date("2026-01-15T\(String(format: "%02d", hour)):00:00+09:00", strategy: .iso8601)
        let context = scene(sun: hour < 7 || hour > 18 ? -30 : 40, date: date, occasions: [occasion])
        #expect(SceneComposer.grid(for: context, cols: 122, rows: 57).cells.allSatisfy { $0 != nil })
    }
}

@Test func winterCatWearsWeekdayScarfExceptRedOnChristmas() throws {
    // 2026-01-04 은 일요일이다. 요일마다 다른 색으로 끝까지 그려진다.
    for day in 4...10 {
        let context = scene(date: try Date("2026-01-\(String(format: "%02d", day))T10:00:00+09:00", strategy: .iso8601), season: .winter)
        #expect(DotScene(context).weekday == day - 4)
        #expect(SceneComposer.grid(for: context, cols: 122, rows: 57).cells.allSatisfy { $0 != nil })
    }
    let christmas = try #require(KoreaOccasions.all.first { $0.id == "KR.christmas" })
    let scarves = DotScene(scene(date: try Date("2026-12-25T10:00:00+09:00", strategy: .iso8601), season: .winter, occasions: [christmas]))
        .looks.cat.compactMap { $0 as? CatScarf }
    #expect(scarves.map(\.color) == ["santa"])
}

@Test func seedPicksHeadwearAndCatStateLikeTheDesign() throws {
    // 시안 06-lofi.html 장면 설명줄과 같은 값. 오후 1시는 시각표로 "따로"다.
    let afternoon = DotScene(scene(date: try Date("2026-07-15T13:00:00+09:00", strategy: .iso8601)))
    #expect(afternoon.headwear == .neck && afternoon.catState == .sleep)
    // 추석 밤 9시는 시각표("같이")를 이벤트 순간(보름달 같이 보기)이 덮는다.
    let chuseok = try #require(KoreaOccasions.all.first { $0.id == "KR.chuseok" })
    let night = DotScene(scene(date: try Date("2026-09-25T21:00:00+09:00", strategy: .iso8601), occasions: [chuseok]))
    #expect(night.headwear == .headphones && night.catState == .beside)
}

@Test func accessibilityLabelReadsRegionTimeWeatherAndOccasions() throws {
    let occasions = [Occasion(id: "chuseok", name: "추석", rule: AlwaysActive()), Occasion(id: "fullMoon", name: "보름달", rule: AlwaysActive())]
    let context = scene(weather: sample(.rain, temperature: 19), date: try Date("2026-09-25T12:00:00Z", strategy: .iso8601), occasions: occasions)
    // 서울은 1988년 이후 일광 절약 시간이 없어 UTC+9 고정이다.
    #expect(WindowView.accessibilityLabel(context, locale: Locale(identifier: "en_GB")) == "서울, 21:00, 비, 추석, 보름달")
    #expect(WindowView.accessibilityLabel(scene(weather: nil, date: try Date("2026-09-25T12:00:00Z", strategy: .iso8601)), locale: Locale(identifier: "ko_KR")) == "서울, 오후 9:00")
}

@MainActor @Test func sameSceneRendersIdenticalPixels() throws {
    let context = scene(weather: sample(.snow, cloudCover: 0.9))
    func render() throws -> Data {
        let renderer = ImageRenderer(content: WindowView(context: context).frame(width: 364, height: 170))
        let image = try #require(renderer.cgImage)
        return try #require(image.dataProvider?.data as Data?)
    }
    #expect(try render() == render())
}

@Test func moonIsPlacedByItsOwnAltitudeAndAzimuth() throws {
    func moon(altitude: Double, azimuth: Double) -> MoonState { MoonState(phase: 0.5, illumination: 1, altitude: altitude, azimuth: azimuth) }
    #expect(try #require(CelestialPosition.moon(moon(altitude: 39, azimuth: 84), latitude: seoul.latitude)).x < 0.5)
    let south = try #require(CelestialPosition.moon(moon(altitude: 50, azimuth: 180), latitude: seoul.latitude))
    #expect(abs(south.x - 0.5) < 1e-9)
    #expect(south.y < CelestialPosition.horizon)
    #expect(CelestialPosition.moon(moon(altitude: -5, azimuth: 270), latitude: seoul.latitude) == nil)
}

@Test func sunRisesOnTheLeftInTheNorthAndOnTheRightInTheSouth() throws {
    let morning = SunState(altitude: 10, azimuth: 90, sunrise: nil, sunset: nil)
    #expect(try #require(CelestialPosition.sun(morning, latitude: 37.5)).x < 0.5)
    #expect(try #require(CelestialPosition.sun(morning, latitude: -33.9)).x > 0.5)
    #expect(CelestialPosition.sun(SunState(altitude: -10, azimuth: 270, sunrise: nil, sunset: nil), latitude: 37.5) == nil)
}

@Test(arguments: [(0.6, 1), (-0.6, -1), (2.5, 3), (-2.5, -2), (0.49999999999999994, 0)])
func jsRoundRoundsHalvesUpLikeJavaScript(_ x: Double, _ expected: Int) {
    #expect(jsRound(x) == expected)
}
