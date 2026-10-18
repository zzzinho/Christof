import ChristofKit
import SwiftUI
import WidgetKit

struct WindowEntryView: View {
    let entry: WindowEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        WindowView(context: entry.context, style: style)
            .containerBackground(.background, for: .widget)
            .widgetURL(AppLink.occasionPicker)
    }

    private var style: WindowSize {
        switch family {
        case .systemSmall: .compact
        case .systemLarge, .systemExtraLarge: .expanded
        default: .regular
        }
    }
}
