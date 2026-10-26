import Foundation

/// 앞에 있을수록 우선순위가 높다. 모양은 구성 요소(창문, 사람·옷, 고양이, 방 안, 시계)마다 고른다.
public enum KoreaOccasions {
    public static let all: [Occasion] = [
        Occasion(id: "KR.seollal", name: "설날", rule: LunarDateRule(calendar: .dangi, month: 1, day: 1, daysBefore: 1, daysAfter: 1), looks: OccasionLooks(
            window: [Kite()], person: [Daenggi()], outfit: .seollal, cat: [CatItem.pouch], room: [DeskItem.tteokguk], clock: [Norigae()])),
        Occasion(id: "KR.jeongwolDaeboreum", name: "정월대보름", rule: LunarDateRule(calendar: .dangi, month: 1, day: 15), looks: OccasionLooks(
            window: [MoonHalo(), Daljip()], person: [PersonSprite.moonPin], outfit: .daeboreum, cat: [CatItem.walnut], room: [DeskItem.bureom],
            clock: [ClockFace(face: "moon")])),
        Occasion(id: "KR.buddhasBirthday", name: "부처님오신날", rule: LunarDateRule(calendar: .dangi, month: 4, day: 8), looks: OccasionLooks(
            window: [LanternString()], person: [PersonSprite.lotusPin], outfit: .buddha, cat: [CatHeadItem.lotus], room: [SillItem.lotusBowl],
            clock: [ClockLantern()])),
        // 추석 무렵엔 머리가 짧아 댕기가 옷깃에 묻히므로 옆머리에 리본 핀을 꽂는다.
        Occasion(id: "KR.chuseok", name: "추석", rule: LunarDateRule(calendar: .dangi, month: 8, day: 15, daysBefore: 1, daysAfter: 1), looks: OccasionLooks(
            window: [MoonHalo(), PersimmonBranch()], person: [PersonSprite.ribbonPin], outfit: .chuseok, cat: [CatItem.persimmon],
            room: [DeskItem.songpyeon], clock: [RabbitEars()])),
        Occasion(id: "KR.newYearsDay", name: "새해 첫날", rule: GregorianDateRule(month: 1, day: 1), looks: OccasionLooks(
            window: [SunGlow()], person: [PersonSprite.beanie, PersonSprite.scarf], outfit: .newYear, cat: [CatHeadItem.beanie],
            room: [DeskItem.greetingCards], clock: [Sparkles()])),
        Occasion(id: "KR.halloween", name: "할로윈", rule: GregorianDateRule(month: 10, day: 31), looks: OccasionLooks(
            window: [Bats()], person: [PersonSprite.witchHat], outfit: .halloween, cat: [BatWings()], room: [SillItem.pumpkin, Cobweb()],
            clock: [Spider()])),
        Occasion(id: "KR.christmasEve", name: "크리스마스 이브", rule: GregorianDateRule(month: 12, day: 24), looks: christmas),
        Occasion(id: "KR.christmas", name: "크리스마스", rule: GregorianDateRule(month: 12, day: 25), looks: christmas),
    ]

    private static let christmas = OccasionLooks(
        window: [Frost()], person: [PersonSprite.santaHat], outfit: .christmas, cat: [CatScarf()], room: [ChristmasTree()], clock: [Holly()])
}
