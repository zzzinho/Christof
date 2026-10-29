import SwiftUI

@main
struct ChristofApp: App {
    var body: some Scene {
        #if os(macOS)
        // 위젯을 누르면 떠 있는 앱을 앞으로 가져올 뿐 닫힌 창을 다시 열지 않는다. 창 하나짜리 Window 는 닫으면 앱이 끝나므로,
        // 다음에 누를 때 앱이 새로 뜨며 창이 열린다.
        Window("Christof", id: "main") {
            PreviewScreen()
        }
        #else
        WindowGroup {
            PreviewScreen()
        }
        #endif
    }
}
