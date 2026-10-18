import ChristofKit
import Foundation

/// 미리보기 화면에서 고른 값. 장면은 매번 여기서 파생한다.
struct PreviewSettings {
    var region = CountryRegistry.standard.defaultRegion
    var usesCurrentTime = true
    var customDate = Date.now
    /// nil 이면 실제 예보를 쓴다.
    var forcedCondition: WeatherCondition?

    func sceneContext(now: Date, realForecast: WeatherForecast?, factory: SceneContextFactory) -> SceneContext {
        let date = usesCurrentTime ? now : customDate
        let forecast = forcedCondition.map { WeatherForecast(samples: [.forced($0, at: date)]) } ?? realForecast
        return factory.context(at: date, region: region, forecast: forecast)
    }
}

extension WeatherSample {
    // ponytail: 강제 날씨의 구름량·세기·기온은 고정값. 세기별 모습을 봐야 하면 슬라이더를 추가한다.
    static func forced(_ condition: WeatherCondition, at date: Date) -> WeatherSample {
        let cloudCover: Double = switch condition {
        case .clear: 0
        case .partlyCloudy: 0.4
        default: 1
        }
        let hasPrecipitation = ![.clear, .partlyCloudy, .overcast].contains(condition)
        return WeatherSample(
            time: date,
            condition: condition,
            intensity: hasPrecipitation ? 0.7 : 0,
            cloudCover: cloudCover,
            temperatureCelsius: condition == .snow ? -2 : 18
        )
    }
}

extension WeatherCondition {
    var koreanName: String {
        switch self {
        case .clear: "맑음"
        case .partlyCloudy: "구름 조금"
        case .overcast: "흐림"
        case .fog: "안개"
        case .drizzle: "이슬비"
        case .rain: "비"
        case .snow: "눈"
        case .thunderstorm: "뇌우"
        }
    }
}
