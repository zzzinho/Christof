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
        let sun = SolarCalculator.state(at: date, latitude: region.latitude, longitude: region.longitude, timeZone: region.timeZone)
        // ponytail: 그날의 일출·일몰만 본다. 자정 가까이 해가 뜨고 지는 고위도에선 자정을 넘는 창을 놓친다. 필요하면 전날·다음날 시각도 함께 본다.
        guard let time = event == .sunrise ? sun.sunrise : sun.sunset else { return false }
        return abs(date.timeIntervalSince(time)) <= window
    }
}
