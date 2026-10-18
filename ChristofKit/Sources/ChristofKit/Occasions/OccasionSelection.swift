import Foundation

public enum OccasionSelection: Hashable, Sendable, Codable {
    case automatic
    case manual(occasionID: String)

    func pick(from occasions: [Occasion], at date: Date, in region: Region) -> [Occasion] {
        switch self {
        case .automatic:
            return occasions.filter { $0.isActive(at: date, in: region) }
        case .manual(let id):
            // 설정은 모든 위젯이 공유한다. 고른 이벤트가 없는 다른 나라 지역의 위젯은 자동으로 둔다.
            guard let chosen = occasions.first(where: { $0.id == id }) else {
                return OccasionSelection.automatic.pick(from: occasions, at: date, in: region)
            }
            return [chosen]
        }
    }
}
