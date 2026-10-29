import SwiftUI

public struct WindowView: View {
    private let context: SceneContext
    @Environment(\.locale) private var locale

    public init(context: SceneContext) {
        self.context = context
    }

    public var body: some View {
        // 격자 크기가 위젯 크기에서 나오고, 위젯 크기는 기기마다 조금 다르다.
        Canvas { ctx, size in
            let dot = DotGrid.dot
            let grid = SceneComposer.grid(for: context, cols: Int((size.width / dot).rounded(.up)), rows: Int((size.height / dot).rounded(.up)))
            // 3 으로 나누어떨어지지 않는 나머지는 양쪽 가장자리에서 잘린다.
            let ox = ((Double(grid.cols) * dot - size.width) / 2).rounded(.down)
            let oy = ((Double(grid.rows) * dot - size.height) / 2).rounded(.down)
            var paths: [UInt32: Path] = [:]
            for y in 0..<grid.rows {
                var x = 0
                while x < grid.cols {
                    let c = grid.cells[y * grid.cols + x]
                    var end = x + 1
                    while end < grid.cols, grid.cells[y * grid.cols + end] == c { end += 1 }
                    if let c {
                        paths[c, default: Path()].addRect(CGRect(x: Double(x) * dot - ox, y: Double(y) * dot - oy, width: Double(end - x) * dot, height: dot))
                    }
                    x = end
                }
            }
            for (c, path) in paths {
                ctx.fill(path, with: .color(Self.color(c)), style: FillStyle(antialiased: false))
            }
        }
        .accessibilityElement()
        .accessibilityAddTraits(.isImage)
        .accessibilityLabel(Self.accessibilityLabel(context, locale: locale))
    }

    private static func color(_ hex: UInt32) -> Color {
        Color(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }

    /// 위젯에 글자를 쓰지 않는다. 시각·날씨·이벤트는 그림으로 보이고, 같은 내용을 접근성 라벨로만 둔다.
    public nonisolated static func accessibilityLabel(_ context: SceneContext, locale: Locale) -> String {
        let language = AppLanguage(locale)
        let time = context.date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, timeZone: context.region.timeZone))
        return ([context.region.name[language], time, context.weather?.condition.name[language]].compactMap { $0 } + context.occasions.map { $0.name[language] })
            .joined(separator: ", ")
    }
}
