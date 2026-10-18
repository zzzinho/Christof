import Foundation

public struct Region: Hashable, Sendable, Identifiable {
    /// 위젯 설정에 저장되는 키라 바꾸지 않는다.
    public let id: String
    public let name: String
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
