import Foundation

/// 사용자가 앱에서 지정해 위젯에 저장하는 값. nil 은 실제 값(지금 시각, 실제 날씨)을 쓴다는 뜻이다.
public struct SceneSettings: Hashable, Sendable, Codable {
    public var fixedDate: Date?
    public var forcedWeather: WeatherCondition?
    public var occasion: OccasionSelection
    public var language: AppLanguage

    public init(fixedDate: Date? = nil, forcedWeather: WeatherCondition? = nil, occasion: OccasionSelection = .automatic, language: AppLanguage = .english) {
        self.fixedDate = fixedDate
        self.forcedWeather = forcedWeather
        self.occasion = occasion
        self.language = language
    }

    // 언어가 없던 버전이 저장한 값도 읽는다.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            fixedDate: try container.decodeIfPresent(Date.self, forKey: .fixedDate),
            forcedWeather: try container.decodeIfPresent(WeatherCondition.self, forKey: .forcedWeather),
            occasion: try container.decode(OccasionSelection.self, forKey: .occasion),
            language: try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .english)
    }

    public static let live = SceneSettings()
}
