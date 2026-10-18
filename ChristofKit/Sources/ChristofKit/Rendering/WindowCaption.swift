import SwiftUI

struct WindowCaption: View {
    let time: String
    let temperature: String
    let details: String?
    let style: WindowStyle

    init(context: SceneContext, style: WindowStyle) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = context.region.timeZone
        let clock = calendar.dateComponents([.hour, .minute], from: context.date)
        time = String(format: "%02d:%02d", clock.hour ?? 0, clock.minute ?? 0)
        temperature = context.weather.map { "\(Int($0.temperatureCelsius.rounded()))°" } ?? "--°"
        details = style.showsDetails
            ? ([context.region.name] + context.occasions.prefix(1).map(\.name)).joined(separator: " · ")
            : nil
        self.style = style
    }

    var body: some View {
        // ponytail: 창턱 높이가 위젯 크기에 묶여 있어 큰 Dynamic Type 은 minimumScaleFactor 로 줄여 맞춘다.
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(time).font(style == .expanded ? .title2.weight(.semibold) : .footnote.weight(.semibold))
            if details == nil { Spacer(minLength: 4) }
            Text(temperature).font(style == .expanded ? .title3 : .footnote)
            if let details {
                Spacer(minLength: 4)
                Text(details).font(style == .expanded ? .subheadline : .caption)
            }
        }
        .monospacedDigit()
        .foregroundStyle(RGB(hex: 0x4A4036).color)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .accessibilityElement(children: .combine)
    }
}
