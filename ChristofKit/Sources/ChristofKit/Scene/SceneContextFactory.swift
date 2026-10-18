import Foundation

/// 날짜·지역·예보를 모아 `SceneContext` 를 만든다.
public struct SceneContextFactory: Sendable {
    private let countries: CountryRegistry
    /// 국가와 무관하게 늘 검사하는 이벤트 (일출·보름달 등). 국가 이벤트 뒤에 붙는다.
    private let universalOccasions: [Occasion]

    public init(countries: CountryRegistry = .standard, universalOccasions: [Occasion] = CelestialOccasions.all) {
        self.countries = countries
        self.universalOccasions = universalOccasions
    }

    public func context(at date: Date, region: Region, forecast: WeatherForecast?) -> SceneContext {
        let profile = countries.profile(for: region.countryCode)
        let candidates = (profile?.occasions ?? []) + universalOccasions
        return SceneContext(
            date: date,
            region: region,
            weather: forecast?.sample(at: date),
            sun: SolarCalculator.state(at: date, latitude: region.latitude, longitude: region.longitude, timeZone: region.timeZone),
            moon: MoonCalculator.state(at: date, latitude: region.latitude, longitude: region.longitude),
            season: profile?.season(at: date, in: region) ?? .meteorological(at: date, in: region),
            occasions: candidates.filter { $0.isActive(at: date, in: region) }
        )
    }
}
