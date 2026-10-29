import Foundation

/// 하늘이 이미 그리므로 모양은 없다. 일출·일몰엔 사람과 고양이가 곁에서 같이 본다.
public enum CelestialOccasions {
    public static let all: [Occasion] = [
        Occasion(id: "sky.sunrise", name: LocalizedName(en: "Sunrise", ko: "일출"), rule: SunEventRule(.sunrise, window: 30 * 60),
                 looks: OccasionLooks(moment: OccasionMoment(hours: 0...23, cat: .beside))),
        Occasion(id: "sky.sunset", name: LocalizedName(en: "Sunset", ko: "일몰"), rule: SunEventRule(.sunset, window: 30 * 60),
                 looks: OccasionLooks(moment: OccasionMoment(hours: 0...23, cat: .beside))),
        Occasion(id: "sky.fullMoon", name: LocalizedName(en: "Full Moon", ko: "보름달"), rule: FullMoonRule()),
    ]
}
