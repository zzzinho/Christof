import SwiftUI
import WidgetKit

@main
struct ChristofWidgetBundle: WidgetBundle {
    var body: some Widget {
        ChristofWindowWidget()
    }
}

struct ChristofWindowWidget: Widget {
    static let kind = "ChristofWindow"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: SelectRegionIntent.self, provider: WindowTimelineProvider()) { entry in
            WindowEntryView(entry: entry)
        }
        .configurationDisplayName("Christof Window")
        .description("Shows the weather, time, and holidays of the chosen region as the view outside a window.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
