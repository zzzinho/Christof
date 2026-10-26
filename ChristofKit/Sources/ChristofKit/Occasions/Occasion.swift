import Foundation

public protocol OccasionRule: Sendable {
    func isActive(at date: Date, in region: Region) -> Bool
}

public struct Occasion: Sendable, Identifiable {
    public let id: String
    public let name: String
    public let rule: any OccasionRule

    public init(id: String, name: String, rule: any OccasionRule) {
        self.id = id
        self.name = name
        self.rule = rule
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        rule.isActive(at: date, in: region)
    }
}
