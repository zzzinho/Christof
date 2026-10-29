import ChristofKit
import Foundation

/// 화면에서 편집 중인 값. 지역은 미리보기용이고(nil 은 위치로 고른 지역), 나머지는 저장하면 위젯에 반영된다.
struct PreviewSettings: Equatable {
    var region: Region?
    var usesCurrentTime: Bool
    var customDate: Date
    var forcedCondition: WeatherCondition?
    var occasion: OccasionSelection
    var language: AppLanguage

    init(saved: SceneSettings) {
        usesCurrentTime = saved.fixedDate == nil
        customDate = saved.fixedDate ?? .now
        forcedCondition = saved.forcedWeather
        occasion = saved.occasion
        language = saved.language
    }

    var sceneSettings: SceneSettings {
        SceneSettings(fixedDate: usesCurrentTime ? nil : customDate, forcedWeather: forcedCondition, occasion: occasion, language: language)
    }
}
