import Foundation

public struct GregorianDateRule: OccasionRule {
    public let month: Int
    public let day: Int
    public let daysBefore: Int
    public let daysAfter: Int

    public init(month: Int, day: Int, daysBefore: Int = 0, daysAfter: Int = 0) {
        self.month = month
        self.day = day
        self.daysBefore = daysBefore
        self.daysAfter = daysAfter
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = region.timeZone
        return calendar.isWithinDays(of: month, day, daysBefore: daysBefore, daysAfter: daysAfter, at: date)
    }
}
