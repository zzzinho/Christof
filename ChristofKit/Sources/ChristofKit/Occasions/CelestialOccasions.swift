import Foundation

/// 국가와 무관한 하늘 이벤트. 하늘·달 레이어가 이미 그리므로 장식은 없다.
public enum CelestialOccasions {
    public static let all: [Occasion] = [
        Occasion(id: "sky.sunrise", name: "일출", rule: SunEventRule(.sunrise, window: 30 * 60)),
        Occasion(id: "sky.sunset", name: "일몰", rule: SunEventRule(.sunset, window: 30 * 60)),
        Occasion(id: "sky.fullMoon", name: "보름달", rule: FullMoonRule()),
    ]
}
