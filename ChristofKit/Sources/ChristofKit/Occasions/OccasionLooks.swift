/// 이벤트 하나가 구성 요소마다 고른 모양과 옷. 시안 OCCASIONS 의 looks 와 OUTFIT_BY_OCCASION 이다.
public struct OccasionLooks: Sendable {
    var window: [any WindowLook] = []
    var person: [any PersonLook] = []
    var outfit: Outfit?
    var cat: [any CatLook] = []
    var room: [any RoomLook] = []
    var clock: [any ClockLook] = []

    public static let none = OccasionLooks()

    /// 진행 중인 이벤트들의 모양을 모두 함께 그린다. 옷은 우선순위가 높은 이벤트 하나를 따른다.
    static func merged(_ list: [OccasionLooks]) -> OccasionLooks {
        OccasionLooks(
            window: list.flatMap(\.window), person: list.flatMap(\.person), outfit: list.lazy.compactMap(\.outfit).first,
            cat: list.flatMap(\.cat), room: list.flatMap(\.room), clock: list.flatMap(\.clock))
    }
}
