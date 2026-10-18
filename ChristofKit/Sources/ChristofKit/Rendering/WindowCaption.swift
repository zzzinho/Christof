import SwiftUI

struct WindowCaption: View {
    let time: String
    let temperature: String
    let details: String?
    let accessibilityText: String
    let style: WindowSize

    init(context: SceneContext, style: WindowSize, locale: Locale = .autoupdatingCurrent) {
        time = context.date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, timeZone: context.region.timeZone))
        temperature = context.weather.map { "\(Int($0.temperatureCelsius.rounded()))°" } ?? "--°"
        let occasion = context.occasions.prefix(1).map(\.name)
        details = style.showsRegion ? ([context.region.name] + occasion).joined(separator: " · ") : occasion.first
        accessibilityText = ([context.region.name, time, context.weather?.condition.koreanName, temperature].compactMap { $0 } + context.occasions.map(\.name))
            .joined(separator: ", ")
        self.style = style
    }

    var body: some View {
        let fonts = Self.fonts(for: style)
        // ponytail: 창턱 높이가 위젯 크기에 묶여 있어 큰 Dynamic Type 은 minimumScaleFactor 로 줄여 맞춘다.
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(time).font(fonts.time)
            if details == nil { Spacer(minLength: 4) }
            Text(temperature).font(fonts.temperature)
            if let details {
                Spacer(minLength: 4)
                Text(details).font(fonts.details)
            }
        }
        .monospacedDigit()
        .foregroundStyle(RGB(hex: 0x4A4036).color)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private static func fonts(for size: WindowSize) -> (time: Font, temperature: Font, details: Font) {
        switch size {
        case .compact, .regular: (.footnote.weight(.semibold), .footnote, .caption)
        case .expanded: (.title2.weight(.semibold), .title3, .subheadline)
        }
    }
}
