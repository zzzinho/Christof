import Foundation

public enum WeatherCondition: Sendable, Hashable, CaseIterable {
    case clear, partlyCloudy, overcast, fog, drizzle, rain, snow, thunderstorm
}

public struct WeatherSample: Sendable, Hashable {
    public let time: Date
    public let condition: WeatherCondition
    /// 강수·안개·뇌우의 세기, 0...1.
    public let intensity: Double
    /// 구름량, 0...1.
    public let cloudCover: Double
    public let temperatureCelsius: Double

    public init(time: Date, condition: WeatherCondition, intensity: Double, cloudCover: Double, temperatureCelsius: Double) {
        self.time = time
        self.condition = condition
        self.intensity = intensity
        self.cloudCover = cloudCover
        self.temperatureCelsius = temperatureCelsius
    }
}

public struct WeatherForecast: Sendable, Hashable {
    /// 시간순으로 정렬된 샘플.
    public let samples: [WeatherSample]

    public init(samples: [WeatherSample]) {
        self.samples = samples.sorted { $0.time < $1.time }
    }

    /// `date` 시점의 날씨. 직전 샘플을 쓰고, 그 샘플이 `maxAge` 보다 오래됐으면 nil.
    public func sample(at date: Date, maxAge: TimeInterval = 2 * 3600) -> WeatherSample? {
        guard let latest = samples.last(where: { $0.time <= date }) else { return nil }
        return date.timeIntervalSince(latest.time) <= maxAge ? latest : nil
    }
}

/// 날씨 출처. 출처를 바꿀 때는 이 프로토콜을 따르는 타입을 새로 만든다.
public protocol WeatherProviding: Sendable {
    func forecast(for region: Region) async throws -> WeatherForecast
}
