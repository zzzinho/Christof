import Foundation

public struct Region: Hashable, Sendable, Identifiable {
    /// 위젯 설정에 저장되는 키라 바꾸지 않는다.
    public let id: String
    public let name: String
    public let countryCode: String
    public let latitude: Double
    public let longitude: Double
    public let timeZone: TimeZone
    public let looks: RegionLooks

    public init(id: String, name: String, countryCode: String, latitude: Double, longitude: Double, timeZone: TimeZone, looks: RegionLooks = .none) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
        self.looks = looks
    }

    // 지역은 id 로 구분한다. 모양은 비교하지 않는다.
    public static func == (a: Region, b: Region) -> Bool { a.id == b.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// 지역마다 다른 창밖 모양. 표에 없는 지역은 뒷산과 아파트 단지다.
public struct RegionLooks: Sendable {
    var far: any FarView = ApartmentView()

    public static let none = RegionLooks()
}
