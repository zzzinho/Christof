import Foundation

extension Calendar {
    /// 날짜를 하루씩 옮겨 가며 (월,일)을 비교하므로 달 길이(29·30·31일)를 따로 다루지 않는다.
    func isWithinDays(of month: Int, _ day: Int, daysBefore: Int, daysAfter: Int, at date: Date) -> Bool {
        (-daysAfter...daysBefore).contains { offset in
            guard let shifted = self.date(byAdding: .day, value: offset, to: date) else { return false }
            let components = dateComponents([.month, .day, .isLeapMonth], from: shifted)
            return components.month == month && components.day == day && components.isLeapMonth != true
        }
    }
}
