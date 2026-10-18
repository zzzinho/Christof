import Foundation

public protocol CountryProfile: Sendable {
    var countryCode: String { get }
    var regions: [Region] { get }
    /// 앞에 있을수록 우선순위가 높다.
    var occasions: [Occasion] { get }
    func season(at date: Date, in region: Region) -> Season
}
