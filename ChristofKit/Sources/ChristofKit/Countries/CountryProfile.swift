import Foundation

/// 한 국가의 데이터: 고를 수 있는 지역, 그 나라의 이벤트, 계절 구분.
/// 새 국가는 이 프로토콜을 따르는 타입을 만들고 `CountryRegistry.standard` 에 등록한다.
public protocol CountryProfile: Sendable {
    var countryCode: String { get }
    var regions: [Region] { get }
    /// 이 나라의 이벤트. 앞에 있을수록 우선순위가 높다.
    var occasions: [Occasion] { get }
    func season(at date: Date, in region: Region) -> Season
}
