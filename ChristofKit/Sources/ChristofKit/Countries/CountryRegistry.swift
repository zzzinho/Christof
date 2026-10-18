import Foundation

public struct CountryRegistry: Sendable {
    public let profiles: [any CountryProfile]

    public init(profiles: [any CountryProfile]) {
        self.profiles = profiles
    }

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

    public var defaultRegion: Region {
        regions[0]
    }
}
