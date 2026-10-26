// 날씨 종류별 그리기 성질을 한 곳에 모은다. 새 종류를 넣으면 여기서 컴파일 오류가 난다.
extension WeatherCondition {
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
