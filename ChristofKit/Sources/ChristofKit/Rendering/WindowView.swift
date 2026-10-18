import SwiftUI

public struct WindowView: View {
    private let context: SceneContext
    private let style: WindowSize
    private let composer: WindowSceneComposer

    public init(context: SceneContext, style: WindowSize = .regular, composer: WindowSceneComposer = WindowSceneComposer()) {
        self.context = context
        self.style = style
        self.composer = composer
    }

    public var body: some View {
        let layers = composer.layers(for: context)
        // 창틀·유리·창턱 자리가 모두 위젯 크기에서 나오므로 크기를 한 번 읽는다.
        GeometryReader { proxy in
            let geometry = WindowGeometry(size: proxy.size)
            ZStack(alignment: .topLeading) {
                ZStack {
                    ForEach(layers.filter { $0.placement == .outside }) { $0.view }
                }
                .frame(width: geometry.glass.width, height: geometry.glass.height)
                .clipShape(.rect(cornerRadius: geometry.glassCornerRadius))
                .offset(x: geometry.glass.minX, y: geometry.glass.minY)
                // 그림은 장식이다. VoiceOver 는 캡션만 읽는다.
                .accessibilityHidden(true)

                WindowFrame()
                    .accessibilityHidden(true)

                ZStack {
                    ForEach(layers.filter { $0.placement == .onFrame }) { $0.view }
                }
                .accessibilityHidden(true)

                WindowCaption(context: context, style: style)
                    .padding(.horizontal, geometry.frame * 1.2)
                    .frame(width: geometry.sillFace.width, height: geometry.sillFace.height)
                    .offset(x: geometry.sillFace.minX, y: geometry.sillFace.minY)
            }
        }
    }
}
