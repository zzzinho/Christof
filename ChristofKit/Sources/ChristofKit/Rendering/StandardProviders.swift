import SwiftUI

extension WindowSceneComposer {
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
