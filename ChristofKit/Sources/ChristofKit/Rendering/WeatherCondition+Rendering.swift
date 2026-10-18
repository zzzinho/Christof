// 날씨 종류별 그리기 성질을 한 곳에 모은다. 새 종류를 넣으면 여기서 컴파일 오류가 난다.
extension WeatherCondition {
    var gloom: Double {
        switch self {
        case .clear: 0
        case .partlyCloudy: 0.1
        case .overcast: 0.5
        case .fog: 0.45
        case .drizzle: 0.45
        case .rain: 0.6
        case .snow: 0.4
        case .thunderstorm: 0.8
        }
    }

    var hasCloudDeck: Bool {
        switch self {
        case .overcast, .drizzle, .rain, .snow, .thunderstorm: true
        case .clear, .partlyCloudy, .fog: false
        }
    }

    var isRain: Bool {
        switch self {
        case .drizzle, .rain, .thunderstorm: true
        case .clear, .partlyCloudy, .overcast, .fog, .snow: false
        }
    }

    var showsStars: Bool {
        switch self {
        case .clear, .partlyCloudy: true
        case .overcast, .fog, .drizzle, .rain, .snow, .thunderstorm: false
        }
    }
}
