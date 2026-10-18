import Foundation

public struct SunEventRule: OccasionRule {
    public enum Event: Sendable {
        case sunrise, sunset
    }

    public let event: Event
    public let window: TimeInterval

    public init(_ event: Event, window: TimeInterval) {
        self.event = event
        self.window = window
    }

    public func isActive(at date: Date, in region: Region) -> Bool {
        // 사건 시각은 지역 날짜마다 하나라, 창이 자정을 걸치면(자정 무렵 일몰) 창 양 끝의 날짜를 모두 봐야 한다. window < 12시간을 가정한다.
        [date.addingTimeInterval(-window), date.addingTimeInterval(window)].contains { edge in
            let sun = SolarCalculator.state(at: edge, latitude: region.latitude, longitude: region.longitude, timeZone: region.timeZone)
            guard let time = event == .sunrise ? sun.sunrise : sun.sunset else { return false }
            return abs(date.timeIntervalSince(time)) <= window
        }
    }
}
