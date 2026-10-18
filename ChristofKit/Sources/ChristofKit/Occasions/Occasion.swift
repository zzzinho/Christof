import Foundation

/// 이벤트가 지금 진행 중인지 판단한다. 날짜 규칙의 종류 하나가 타입 하나다.
public protocol OccasionRule: Sendable {
    func isActive(at date: Date, in region: Region) -> Bool
}

/// 명절·기념일·하늘 이벤트 하나. 언제(`rule`)와 창문에 무엇을 더할지(`decorations`)를 함께 정의한다.
/// 이벤트 추가·제거·수정은 국가 프로필의 `occasions` 목록에서 이 값 하나만 다루면 된다.
public struct Occasion: Sendable, Identifiable {
    public let id: String
    /// 창문 캡션에 보이는 이름. 예: "추석"
    public let name: String
    public let rule: any OccasionRule
    public let decorations: [any SceneLayerProvider]

    public init(id: String, name: String, rule: any OccasionRule, decorations: [any SceneLayerProvider] = []) {
        self.id = id
        self.name = name
        self.rule = rule
        self.decorations = decorations
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        rule.isActive(at: date, in: region)
    }
}
