import Foundation

public enum Season: Sendable, Hashable, CaseIterable {
    case spring, summer, autumn, winter

    public static func meteorological(at date: Date, in region: Region) -> Season {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = region.timeZone
        var month = calendar.component(.month, from: date)
        if region.latitude < 0 {
            month = (month + 5) % 12 + 1
        }
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .autumn
        default: return .winter
        }
    }
}
