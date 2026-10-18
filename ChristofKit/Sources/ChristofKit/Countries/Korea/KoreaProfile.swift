import Foundation

public struct KoreaProfile: CountryProfile {
    public init() {}

    public let countryCode = "KR"
    public var regions: [Region] { KoreaRegions.all }
    public var occasions: [Occasion] { KoreaOccasions.all }

    public func season(at date: Date, in region: Region) -> Season {
        .meteorological(at: date, in: region)
    }
}
