import Foundation

/// 앱·위젯이 아는 국가 목록. 지역 조회와 국가 프로필 조회를 맡는다.
public struct CountryRegistry: Sendable {
    public let profiles: [any CountryProfile]

    public init(profiles: [any CountryProfile]) {
        self.profiles = profiles
    }

    /// 새 국가는 여기에 프로필을 추가한다.
    public static let standard = CountryRegistry(profiles: [KoreaProfile()])

    public func profile(for countryCode: String) -> (any CountryProfile)? {
        profiles.first { $0.countryCode == countryCode }
    }

    public var regions: [Region] {
        profiles.flatMap(\.regions)
    }

    public func region(id: String) -> Region? {
        regions.first { $0.id == id }
    }

    /// 설정이 없을 때 쓰는 지역: 첫 국가의 첫 지역. 등록된 지역이 하나 이상 있어야 한다.
    public var defaultRegion: Region {
        regions[0]
    }
}
