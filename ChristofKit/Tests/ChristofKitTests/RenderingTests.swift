import CoreGraphics
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
    weather: WeatherSample? = sample(.clear, cloudCover: 0), date: Date = .now, occasions: [Occasion] = []
) -> SceneContext {
    SceneContext(
        date: date, region: seoul, weather: weather,
        sun: SunState(altitude: altitude, azimuth: azimuth, sunrise: nil, sunset: nil),
        moon: MoonState(phase: moonPhase, illumination: (1 - cos(moonPhase * 2 * .pi)) / 2, altitude: moonAltitude, azimuth: 180),
        season: .autumn, occasions: occasions)
}

private struct FixedLayer: SceneLayerProvider {
    let id: String
    let depth: Double

    @MainActor func layers(for context: SceneContext) -> [WindowLayer] {
        [WindowLayer(id: id, depth: LayerDepth(depth)) { EmptyView() }]
    }
}

@MainActor @Test func composerSortsByDepthAndKeepsRegistrationOrderForTies() {
    let occasion = Occasion(id: "o", name: "o", rule: AlwaysActive(), decorations: [FixedLayer(id: "decoration", depth: 5)])
    let composer = WindowSceneComposer(providers: [
        FixedLayer(id: "front", depth: 50), FixedLayer(id: "tieA", depth: 5), FixedLayer(id: "back", depth: 0), FixedLayer(id: "tieB", depth: 5),
    ])
    #expect(composer.layers(for: scene(occasions: [occasion])).map(\.id) == ["back", "tieA", "tieB", "decoration", "front"])
}

@MainActor @Test func composerKeepsOnlyTheFirstLayerWhenTwoOccasionsShareADecoration() {
    let first = Occasion(id: "first", name: "first", rule: AlwaysActive(), decorations: [FixedLayer(id: "shared", depth: 5)])
    let second = Occasion(id: "second", name: "second", rule: AlwaysActive(), decorations: [FixedLayer(id: "shared", depth: 7), FixedLayer(id: "own", depth: 6)])
    let layers = WindowSceneComposer(providers: []).layers(for: scene(occasions: [first, second]))
    #expect(layers.map(\.id) == ["shared", "own"])
    #expect(layers.first?.depth == LayerDepth(5))
}

@Test(arguments: SkyPalette.keyframes.map(\.altitude))
func skyPaletteIsContinuousAtKeyframe(altitude: Double) {
    let below = SkyPalette(sunAltitude: altitude - 1e-6, weather: nil)
    let above = SkyPalette(sunAltitude: altitude + 1e-6, weather: nil)
    #expect(below.zenith.distance(to: above.zenith) < 1e-4)
    #expect(below.horizon.distance(to: above.horizon) < 1e-4)
    #expect(abs(below.daylight - above.daylight) < 1e-4)
}

@Test func badWeatherDullsAndDarkensTheSky() {
    func saturation(_ c: RGB) -> Double { max(c.r, c.g, c.b) - min(c.r, c.g, c.b) }
    let clear = SkyPalette(sunAltitude: 40, weather: sample(.clear, cloudCover: 0))
    for condition in [WeatherCondition.overcast, .rain, .thunderstorm] {
        let gloomy = SkyPalette(sunAltitude: 40, weather: sample(condition, cloudCover: 1))
        #expect(gloomy.zenith.luminance < clear.zenith.luminance, "\(condition)")
        #expect(saturation(gloomy.zenith) < saturation(clear.zenith), "\(condition)")
    }
    #expect(SkyPalette(sunAltitude: -30, weather: nil).zenith.luminance < clear.zenith.luminance)
}

struct LayerRule: Sendable, CustomTestStringConvertible {
    let rule: String
    let providers: [any SceneLayerProvider]
    let context: SceneContext
    let expected: [String: LayerPlacement]
    var testDescription: String { rule }
}

private let night = (altitude: -40.0, azimuth: 0.0)

@MainActor @Test(arguments: [
    LayerRule(rule: "맑으면 비 레이어가 없다", providers: [RainEffect()], context: scene(), expected: [:]),
    LayerRule(rule: "비가 오면 빗줄기를 그린다", providers: [RainEffect()], context: scene(weather: sample(.rain)), expected: ["rain": .outside]),
    LayerRule(rule: "이슬비도 빗줄기로 그린다", providers: [RainEffect()], context: scene(weather: sample(.drizzle)), expected: ["rain": .outside]),
    LayerRule(rule: "뇌우면 번개가 친다", providers: [LightningEffect()], context: scene(weather: sample(.thunderstorm)), expected: ["lightning": .outside]),
    LayerRule(rule: "비만 오면 번개가 없다", providers: [LightningEffect()], context: scene(weather: sample(.rain)), expected: [:]),
    LayerRule(rule: "밤이면 달과 별이 있고 해는 없다", providers: [SunEffect(), MoonEffect(), StarEffect()],
              context: scene(sun: night.altitude, azimuth: night.azimuth), expected: ["moon": .outside, "stars": .outside]),
    LayerRule(rule: "낮이면 해만 있고 달과 별은 없다", providers: [SunEffect(), MoonEffect(), StarEffect()], context: scene(), expected: ["sun": .outside]),
    LayerRule(rule: "달이 지평선 아래면 밤이라도 달과 보름달 장식을 그리지 않는다", providers: [MoonEffect(), FullMoonDecoration()],
              context: scene(sun: night.altitude, azimuth: night.azimuth, moonAltitude: -10), expected: [:]),
    LayerRule(rule: "뇌우로 달이 가려지면 보름달 장식도 그리지 않는다", providers: [MoonEffect(), FullMoonDecoration()],
              context: scene(sun: night.altitude, azimuth: night.azimuth, weather: sample(.thunderstorm, cloudCover: 1)), expected: [:]),
    LayerRule(rule: "흐린 밤엔 별이 없다", providers: [StarEffect()],
              context: scene(sun: night.altitude, azimuth: night.azimuth, weather: sample(.overcast, cloudCover: 1)), expected: [:]),
    LayerRule(rule: "눈이 오면 창턱에 쌓인 눈은 창틀 위에 그린다", providers: [SnowEffect()], context: scene(weather: sample(.snow)),
              expected: ["snow": .outside, "snow.sill": .onFrame]),
    LayerRule(rule: "날씨를 모르면 구름·비·눈·안개·번개를 그리지 않는다", providers: [CloudEffect(), RainEffect(), SnowEffect(), FogEffect(), LightningEffect()],
              context: scene(weather: nil), expected: [:]),
    LayerRule(rule: "보름달 장식은 밤에 달 자리에 후광을 그린다", providers: [FullMoonDecoration()],
              context: scene(sun: night.altitude, azimuth: night.azimuth), expected: ["decoration.fullMoon": .outside]),
    LayerRule(rule: "보름달 장식은 낮엔 그리지 않는다", providers: [FullMoonDecoration()], context: scene(), expected: [:]),
    LayerRule(rule: "연등은 창밖, 복주머니·호박·전구는 창틀 위에 둔다",
              providers: [LotusLanternDecoration(), LuckyPouchDecoration(), JackOLanternDecoration(), ChristmasLightsDecoration()], context: scene(),
              expected: ["decoration.lotusLantern": .outside, "decoration.luckyPouch": .onFrame, "decoration.jackOLantern": .onFrame, "decoration.christmasLights": .onFrame]),
])
func layersAppearOnlyWhenTheirConditionHolds(_ rule: LayerRule) {
    let layers = WindowSceneComposer(providers: rule.providers).layers(for: rule.context)
    #expect(Dictionary(uniqueKeysWithValues: layers.map { ($0.id, $0.placement) }) == rule.expected)
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

@Test(arguments: [(0.25, 0.5, 1.0), (0.5, 0.0, 1.0), (0.75, 0.0, 0.5)])
func moonLitSideFollowsPhase(phase: Double, minX: Double, maxX: Double) {
    // 상현(0.25)은 오른쪽 반, 보름(0.5)은 전체, 하현(0.75)은 왼쪽 반이 밝다(북반구).
    let disc = CGRect(x: 0, y: 0, width: 100, height: 100)
    let lit = MoonEffect.litPath(phase: phase, in: disc, mirrored: false).boundingRect
    #expect(abs(lit.minX - minX * 100) < 0.5)
    #expect(abs(lit.maxX - maxX * 100) < 0.5)
}

struct CaptionRule: Sendable, CustomTestStringConvertible {
    let rule: String
    let style: WindowSize
    let locale: String
    let date: String
    let temperature: Double?
    let time: String
    let degrees: String
    let details: String?
    var testDescription: String { rule }
}

@MainActor @Test(arguments: [
    // 서울은 1988년 이후 일광 절약 시간이 없어 UTC+9 고정이다.
    CaptionRule(rule: "시각은 지역 시간대로, 24시간제 로캘이면 24시간제", style: .compact, locale: "en_GB", date: "2026-10-18T14:05:00Z", temperature: 11.6, time: "23:05", degrees: "12°", details: "추석"),
    CaptionRule(rule: "12시간제 로캘이면 오전·오후를 붙인다", style: .compact, locale: "ko_KR", date: "2026-10-18T14:05:00Z", temperature: 11.6, time: "오후 11:05", degrees: "12°", details: "추석"),
    CaptionRule(rule: "영하 기온은 반올림해 부호를 붙인다", style: .compact, locale: "en_GB", date: "2026-10-18T00:00:00Z", temperature: -2.6, time: "9:00", degrees: "-3°", details: "추석"),
    CaptionRule(rule: "0도 근처 음수는 -0° 가 아니라 0°", style: .compact, locale: "en_GB", date: "2026-10-18T00:00:00Z", temperature: -0.4, time: "9:00", degrees: "0°", details: "추석"),
    CaptionRule(rule: "날씨를 모르면 기온은 --°", style: .compact, locale: "en_GB", date: "2026-10-18T00:00:00Z", temperature: nil, time: "9:00", degrees: "--°", details: "추석"),
    CaptionRule(rule: "regular 는 첫 이벤트 앞에 지역을 더한다", style: .regular, locale: "en_GB", date: "2026-09-25T12:00:00Z", temperature: 19, time: "21:00", degrees: "19°", details: "서울 · 추석"),
])
func captionShowsLocalTimeTemperatureAndDetails(_ rule: CaptionRule) throws {
    let occasions = [Occasion(id: "chuseok", name: "추석", rule: AlwaysActive()), Occasion(id: "fullMoon", name: "보름달", rule: AlwaysActive())]
    let date = try Date(rule.date, strategy: .iso8601)
    let context = scene(weather: rule.temperature.map { sample(.clear, temperature: $0) }, date: date, occasions: occasions)
    let caption = WindowCaption(context: context, style: rule.style, locale: Locale(identifier: rule.locale))
    #expect(caption.time == rule.time)
    #expect(caption.temperature == rule.degrees)
    #expect(caption.details == rule.details)
}

@MainActor @Test(arguments: WindowSize.allCases)
func captionReadsRegionTimeWeatherTemperatureAndOccasionsAtEverySize(_ style: WindowSize) throws {
    let occasions = [Occasion(id: "chuseok", name: "추석", rule: AlwaysActive()), Occasion(id: "fullMoon", name: "보름달", rule: AlwaysActive())]
    let context = scene(weather: sample(.rain, temperature: 19), date: try Date("2026-09-25T12:00:00Z", strategy: .iso8601), occasions: occasions)
    let caption = WindowCaption(context: context, style: style, locale: Locale(identifier: "en_GB"))
    #expect(caption.accessibilityText == "서울, 21:00, 비, 19°, 추석, 보름달")
}

@MainActor @Test func sameSceneRendersIdenticalPixels() throws {
    let occasion = Occasion(id: "christmas", name: "크리스마스", rule: AlwaysActive(), decorations: [ChristmasLightsDecoration()])
    let context = scene(weather: sample(.snow, cloudCover: 0.9), occasions: [occasion])
    func render() throws -> Data {
        let renderer = ImageRenderer(content: WindowView(context: context, style: .regular).frame(width: 364, height: 170))
        let image = try #require(renderer.cgImage)
        return try #require(image.dataProvider?.data as Data?)
    }
    #expect(try render() == render())
}
