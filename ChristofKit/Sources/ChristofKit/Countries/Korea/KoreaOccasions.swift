import Foundation

/// 앞에 있을수록 우선순위가 높다.
public enum KoreaOccasions {
    public static let all: [Occasion] = [
        Occasion(id: "KR.seollal", name: "설날", rule: LunarDateRule(calendar: .dangi, month: 1, day: 1, daysBefore: 1, daysAfter: 1)),
        Occasion(id: "KR.jeongwolDaeboreum", name: "정월대보름", rule: LunarDateRule(calendar: .dangi, month: 1, day: 15)),
        Occasion(id: "KR.buddhasBirthday", name: "부처님오신날", rule: LunarDateRule(calendar: .dangi, month: 4, day: 8)),
        Occasion(id: "KR.chuseok", name: "추석", rule: LunarDateRule(calendar: .dangi, month: 8, day: 15, daysBefore: 1, daysAfter: 1)),
        Occasion(id: "KR.newYearsDay", name: "새해 첫날", rule: GregorianDateRule(month: 1, day: 1)),
        Occasion(id: "KR.halloween", name: "할로윈", rule: GregorianDateRule(month: 10, day: 31)),
        Occasion(id: "KR.christmasEve", name: "크리스마스 이브", rule: GregorianDateRule(month: 12, day: 24)),
        Occasion(id: "KR.christmas", name: "크리스마스", rule: GregorianDateRule(month: 12, day: 25)),
    ]
}
