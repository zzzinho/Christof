import Foundation

public struct SceneContextFactory: Sendable {
    private let countries: CountryRegistry
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
