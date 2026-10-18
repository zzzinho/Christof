import Foundation

/// 한 순간 창밖 장면을 그리는 데 필요한 모든 정보. 순수 값이라 위젯 타임라인 엔트리에 그대로 담는다.
public struct SceneContext: Sendable {
    public let date: Date
    public let region: Region
    /// 날씨를 모르면 nil (오프라인 등).
    public let weather: WeatherSample?
    public let sun: SunState
    public let moon: MoonState
    public let season: Season
    /// 지금 진행 중인 이벤트. 우선순위 순.
    public let occasions: [Occasion]

    public init(date: Date, region: Region, weather: WeatherSample?, sun: SunState, moon: MoonState, season: Season, occasions: [Occasion]) {
        self.date = date
        self.region = region
        self.weather = weather
        self.sun = sun
        self.moon = moon
        self.season = season
        self.occasions = occasions
    }
}
