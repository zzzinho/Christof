import ChristofKit
import SwiftUI
import WidgetKit

struct WindowEntryView: View {
    let entry: WindowEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        WindowView(context: entry.context, style: style)
            .containerBackground(.background, for: .widget)
    }

    // macOS SwiftUI 에도 WindowStyle 이 있어 모듈로 한정한다.
    private var style: ChristofKit.WindowStyle {
        switch family {
        case .systemSmall: .compact
        case .systemLarge, .systemExtraLarge: .expanded
        default: .regular
        }
    }
}
