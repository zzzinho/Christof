import ChristofKit
import SwiftUI
import WidgetKit

struct WindowEntryView: View {
    let entry: WindowEntry

    var body: some View {
        WindowView(context: entry.context)
            .containerBackground(.background, for: .widget)
    }
}
