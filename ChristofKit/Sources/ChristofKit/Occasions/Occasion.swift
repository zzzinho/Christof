import Foundation

public protocol OccasionRule: Sendable {
    func isActive(at date: Date, in region: Region) -> Bool
    /// 이벤트 날까지 남은 날 수. 그날이 지난 연휴는 음수, 기간 밖이면 nil. 기간이 겹치면 이 값이 작은 이벤트가 보인다.
    func daysUntil(_ date: Date, in region: Region) -> Int?
}

extension OccasionRule {
    /// 일출·보름달처럼 그 순간에만 진행 중인 규칙은 남은 날이 없다.
    public func daysUntil(_ date: Date, in region: Region) -> Int? {
        isActive(at: date, in: region) ? 0 : nil
    }
}

public struct Occasion: Sendable, Identifiable {
    public let id: String
    public let name: LocalizedName
    public let rule: any OccasionRule
    public let looks: OccasionLooks

    public init(id: String, name: LocalizedName, rule: any OccasionRule, looks: OccasionLooks = .none) {
        self.id = id
        self.name = name
        self.rule = rule
        self.looks = looks
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        rule.isActive(at: date, in: region)
    }
}
