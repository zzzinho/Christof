import Foundation

/// 앱에서 고르고 위젯 익스텐션이 읽으므로 둘이 함께 여는 설정 도메인에 둔다.
public struct OccasionSelectionStore: Sendable {
    #if os(macOS)
    // macOS 는 개발 팀 서명 없이 App Group 을 쓸 수 없어, 샌드박스 예외 권한
    // (Config/Christof-macOS.entitlements)으로 여는 공용 설정 도메인을 쓴다. 앱스토어 배포 전에는 App Group 으로 바꾼다.
    public static let sharedSuite = "com.christof.shared"
    #else
    public static let sharedSuite = "group.com.christof.Christof"
    #endif
    private static let key = "occasionSelection"

    private let suiteName: String

    public init(suiteName: String = OccasionSelectionStore.sharedSuite) {
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
