import Foundation

public enum OccasionSelection: Hashable, Sendable, Codable {
    case automatic
    case manual(occasionID: String)

    func pick(from occasions: [Occasion], at date: Date, in region: Region) -> [Occasion] {
        switch self {
        case .automatic:
            // 기간이 겹치면 그날이 먼저 오는 이벤트 하나만 보이고, 그날(연휴면 연휴)이 지나면 다음 이벤트로 넘어간다.
            let upcoming = occasions.compactMap { occasion in occasion.rule.daysUntil(date, in: region).map { (occasion: occasion, days: $0) } }
            return upcoming.min { $0.days < $1.days }.map { [$0.occasion] } ?? []
        case .manual(let id):
            // 설정은 모든 위젯이 공유한다. 고른 이벤트가 없는 다른 나라 지역의 위젯은 자동으로 둔다.
            guard let chosen = occasions.first(where: { $0.id == id }) else {
                return OccasionSelection.automatic.pick(from: occasions, at: date, in: region)
            }
            return [chosen]
        }
    }
}
