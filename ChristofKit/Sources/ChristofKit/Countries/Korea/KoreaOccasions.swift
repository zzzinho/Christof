import Foundation

/// 한국 명절·기념일. 앞에 있을수록 우선순위가 높다. 이벤트 추가·제거·수정은 이 목록의 값 하나만 다룬다.
public enum KoreaOccasions {
    public static let all: [Occasion] = [
        Occasion(id: "KR.seollal", name: "설날", rule: LunarDateRule(calendar: .dangi, month: 1, day: 1, daysBefore: 1, daysAfter: 1), decorations: [LuckyPouchDecoration()]),
        Occasion(id: "KR.jeongwolDaeboreum", name: "정월대보름", rule: LunarDateRule(calendar: .dangi, month: 1, day: 15), decorations: [FullMoonDecoration()]),
        Occasion(id: "KR.buddhasBirthday", name: "부처님오신날", rule: LunarDateRule(calendar: .dangi, month: 4, day: 8), decorations: [LotusLanternDecoration()]),
        Occasion(id: "KR.chuseok", name: "추석", rule: LunarDateRule(calendar: .dangi, month: 8, day: 15, daysBefore: 1, daysAfter: 1), decorations: [FullMoonDecoration()]),
        Occasion(id: "KR.newYearsDay", name: "새해 첫날", rule: GregorianDateRule(month: 1, day: 1), decorations: [LuckyPouchDecoration()]),
        Occasion(id: "KR.halloween", name: "할로윈", rule: GregorianDateRule(month: 10, day: 31), decorations: [JackOLanternDecoration()]),
        Occasion(id: "KR.christmasEve", name: "크리스마스 이브", rule: GregorianDateRule(month: 12, day: 24), decorations: [ChristmasLightsDecoration()]),
        Occasion(id: "KR.christmas", name: "크리스마스", rule: GregorianDateRule(month: 12, day: 25), decorations: [ChristmasLightsDecoration()]),
    ]
}
