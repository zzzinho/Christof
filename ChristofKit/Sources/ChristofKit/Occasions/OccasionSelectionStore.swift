import Foundation

/// 앱에서 고르고 위젯 익스텐션이 읽으므로 App Group 저장소에 둔다.
public struct OccasionSelectionStore: Sendable {
    public static let appGroup = "group.com.christof.Christof"
    private static let key = "occasionSelection"

    private let suiteName: String

    public init(suiteName: String = OccasionSelectionStore.appGroup) {
        self.suiteName = suiteName
    }

    // UserDefaults 는 Sendable 이 아니라 이름만 들고 매번 연다.
    private var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func load() -> OccasionSelection {
        guard let data = defaults.data(forKey: Self.key),
              let selection = try? JSONDecoder().decode(OccasionSelection.self, from: data)
        else { return .automatic }
        return selection
    }

    public func save(_ selection: OccasionSelection) {
        defaults.set(try? JSONEncoder().encode(selection), forKey: Self.key)
    }
}
