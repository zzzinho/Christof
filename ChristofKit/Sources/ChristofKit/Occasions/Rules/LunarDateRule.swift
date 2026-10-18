import Foundation

/// 음력 기념일. 평달 (월,일) 기준이고, 지역 시간대의 하루 단위로 판정한다.
/// 나라마다 음력이 하루씩 다를 수 있어(한국 .dangi, 중국 .chinese, 베트남 .vietnamese) 국가 프로필이 달력을 고른다.
public struct LunarDateRule: OccasionRule {
    public let calendar: Calendar.Identifier
    public let month: Int
    public let day: Int
    public let daysBefore: Int
    public let daysAfter: Int

    public init(calendar: Calendar.Identifier, month: Int, day: Int, daysBefore: Int = 0, daysAfter: Int = 0) {
        self.calendar = calendar
        self.month = month
        self.day = day
        self.daysBefore = daysBefore
        self.daysAfter = daysAfter
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        var lunar = Calendar(identifier: calendar)
        lunar.timeZone = region.timeZone
        return lunar.isWithinDays(of: month, day, daysBefore: daysBefore, daysAfter: daysAfter, at: date)
    }
}
