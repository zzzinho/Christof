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
        .configurationDisplayName("Christof 창문")
        .description("고른 지역의 날씨와 시간, 명절을 창밖 풍경으로 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
