import Foundation

/// 사용자가 고르는 지역. 날씨 좌표, 시간대, 소속 국가를 묶는다.
public struct Region: Hashable, Sendable, Identifiable {
    /// 위젯 설정에 저장되는 안정적인 키. 예: "KR.seoul"
    public let id: String
    /// 화면에 보이는 이름. 예: "서울"
    public let name: String
    /// ISO 3166-1 alpha-2. `CountryRegistry` 에서 국가 프로필을 찾는 키.
    public let countryCode: String
    public let latitude: Double
    public let longitude: Double
    public let timeZone: TimeZone

    public init(id: String, name: String, countryCode: String, latitude: Double, longitude: Double, timeZone: TimeZone) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
    }
}
