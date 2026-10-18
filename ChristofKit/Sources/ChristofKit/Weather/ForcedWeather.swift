import Foundation

extension WeatherSample {
    // ponytail: 강제 날씨의 구름량·세기·기온은 고정값. 세기별 모습을 봐야 하면 설정에 세기를 추가한다.
    public static func forced(_ condition: WeatherCondition, at date: Date) -> WeatherSample {
        let (cloudCover, intensity): (Double, Double) = switch condition {
        case .clear: (0, 0)
        case .partlyCloudy: (0.4, 0)
        case .overcast: (1, 0)
        case .fog, .drizzle, .rain, .snow, .thunderstorm: (1, 0.7)
        }
        return WeatherSample(
            time: date,
            condition: condition,
            intensity: intensity,
            cloudCover: cloudCover,
            temperatureCelsius: condition == .snow ? -2 : 18
        )
    }
}
