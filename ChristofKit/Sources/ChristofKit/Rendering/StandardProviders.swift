import SwiftUI

extension WindowSceneComposer {
    /// 모든 장면에 늘 검사하는 기본 효과. 각 효과가 그릴지 스스로 판단한다.
    public static let standardProviders: [any SceneLayerProvider] = [
        SkyEffect(),
        StarEffect(),
        SunEffect(),
        MoonEffect(),
        CloudEffect(),
        LightningEffect(),
        LandscapeEffect(),
        RainEffect(),
        SnowEffect(),
        FogEffect(),
    ]
}
