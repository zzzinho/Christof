import ChristofKit
import SwiftUI
import WidgetKit

struct WindowEntryView: View {
    let entry: WindowEntry

    var body: some View {
        WindowView(context: entry.context)
            .environment(\.locale, entry.language.locale)
            .containerBackground(.background, for: .widget)
    }
}
