import Foundation

/// 양력 기념일. 지역 시간대의 하루 단위로 판정한다.
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
