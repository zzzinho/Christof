import Foundation

/// 사용자가 앱에서 지정해 위젯에 저장하는 값. nil 은 실제 값(지금 시각, 실제 날씨)을 쓴다는 뜻이다.
public struct SceneSettings: Hashable, Sendable, Codable {
    public var fixedDate: Date?
    public var forcedWeather: WeatherCondition?
    public var occasion: OccasionSelection

    public init(fixedDate: Date? = nil, forcedWeather: WeatherCondition? = nil, occasion: OccasionSelection = .automatic) {
        self.fixedDate = fixedDate
        self.forcedWeather = forcedWeather
        self.occasion = occasion
    }

    public static let live = SceneSettings()
}
