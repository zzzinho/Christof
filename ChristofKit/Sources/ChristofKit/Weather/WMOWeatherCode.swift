import Foundation

enum WMOWeatherCode {
    private static let light = 1.0 / 3
    private static let moderate = 2.0 / 3
    private static let heavy = 1.0

    static func interpret(_ code: Int) -> (condition: WeatherCondition, intensity: Double) {
        switch code {
        case 0: (.clear, 0)
        case 1, 2: (.partlyCloudy, 0)
        case 3: (.overcast, 0)
        // ponytail: WMO 코드는 안개 짙기를 나누지 않아 중간 세기로 둔다. 짙기가 필요하면 visibility 변수를 받아 정한다.
        case 45, 48: (.fog, moderate)
        // 56·57, 66·67 은 어는 이슬비·비. 따로 그리지 않고 이슬비·비의 약/강으로 본다.
        case 51, 56: (.drizzle, light)
        case 53: (.drizzle, moderate)
        case 55, 57: (.drizzle, heavy)
        case 61, 66, 80: (.rain, light)
        case 63, 81: (.rain, moderate)
        case 65, 67, 82: (.rain, heavy)
        case 71, 77, 85: (.snow, light)
        case 73: (.snow, moderate)
        case 75, 86: (.snow, heavy)
        // 95 는 "약하거나 보통인 뇌우", 96·99 는 우박을 동반한 뇌우.
        case 95: (.thunderstorm, moderate)
        case 96, 99: (.thunderstorm, heavy)
        default: (.overcast, 0)
        }
    }
}
