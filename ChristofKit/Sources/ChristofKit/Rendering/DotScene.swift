import Foundation
import SwiftUI

/// 그리기에 쓰는 장면 값. 시안의 sceneContext() 를 옮겼다.
struct DotScene {
    /// 창밖과 벽 색을 고르는 때. 색 이름은 --lofi-<때>-<이름> 이다.
    enum Phase: String {
        case night, grey, dusk, day
    }

    enum Headwear: CaseIterable {
        case headphones, neck, bare
    }

    enum CatState: CaseIterable {
        case window, sleep, walk, pet, shoulder
    }

    let phase: Phase
    let hour: Int
    let minute: Int
    let season: Season
    let weather: WeatherSample?
    let sunAltitude: Double
    let moonPhase: Double
    let sunPoint: UnitPoint?
    let moonPoint: UnitPoint?
    let snowCovered: Bool
    let headwear: Headwear
    let catState: CatState
    let hair: Double
    let outfit: Outfit

    var lightOn: Bool { phase != .day }

    init(_ context: SceneContext) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = context.region.timeZone
        let parts = calendar.dateComponents([.month, .day, .hour, .minute], from: context.date)
        let month = parts.month ?? 1, day = parts.day ?? 1
        hour = parts.hour ?? 0
        minute = parts.minute ?? 0
        season = context.season
        weather = context.weather
        sunAltitude = context.sun.altitude
        moonPhase = context.moon.phase

        let gloomy = weather.map { $0.condition.hasCloudDeck || $0.condition == .fog } ?? false
        // 흐린 날은 해 질 녘도 회색 하늘로 둔다. 비·눈·안개 색은 night 와 grey 에만 있다.
        phase = sunAltitude < -6 ? .night : gloomy ? .grey : sunAltitude < 6 ? .dusk : .day
        sunPoint = gloomy ? nil : CelestialPosition.sun(context.sun, latitude: context.region.latitude)
        moonPoint = gloomy || sunAltitude >= 0 ? nil : CelestialPosition.moon(context.moon, latitude: context.region.latitude)
        // 따뜻한 겨울(부산·제주)은 마른 풍경으로 두고, 눈이 오거나 영하일 때만 지붕에 눈을 얹는다.
        snowCovered = weather.map { $0.condition == .snow || (context.season == .winter && $0.temperatureCelsius <= 0) } ?? false

        // 같은 날 같은 시각이면 늘 같은 모습이고, 한 시간마다 바뀐다.
        var random = SeededRandom(seed: UInt64((month * 100 + day) * 100 + hour))
        headwear = Headwear.allCases[random.int(0, Headwear.allCases.count - 1)]
        catState = CatState.allCases[random.int(0, CatState.allCases.count - 1)]
        // 7월 1일에 단발로 자르고 이듬해 6월 말까지 길어진다.
        hair = (Double((month + 5) % 12) + Double(day - 1) / 31) / 12
        // ponytail: 평소 옷은 시안 후보 셋(머스터드·세이지·코럴) 중 시안이 쓰는 머스터드만 옮겼다.
        outfit = .mustard
    }

    /// 때마다 다른 색
    func color(_ name: String) -> UInt32 {
        LofiPalette.color("\(phase.rawValue)-\(name)")
    }
}
