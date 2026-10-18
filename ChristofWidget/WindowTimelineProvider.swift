import ChristofKit
import WidgetKit

struct WindowEntry: TimelineEntry {
    let date: Date
    let context: SceneContext
}

struct WindowTimelineProvider: AppIntentTimelineProvider {
    var weather: any WeatherProviding = .standard
    var factory = SceneContextFactory()

    func placeholder(in context: Context) -> WindowEntry {
        entry(at: .now, region: CountryRegistry.standard.defaultRegion, forecast: nil)
    }

    // 위젯 갤러리·편집 화면은 바로 떠야 하므로 네트워크를 기다리지 않는다.
    func snapshot(for configuration: SelectRegionIntent, in context: Context) async -> WindowEntry {
        entry(at: .now, region: configuration.selectedRegion, forecast: nil)
    }

    func timeline(for configuration: SelectRegionIntent, in context: Context) async -> Timeline<WindowEntry> {
        let region = configuration.selectedRegion
        let now = Date.now
        // 예보 실패(오프라인 등)는 날씨 없는 장면으로 그리고, 30분 뒤 다시 시도한다(하루 48회, 리로드 예산 40~70회 안).
        let forecast = try? await weather.forecast(for: region)
        let minuteStart = Date(timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate / 60).rounded(.down) * 60)
        // 리로드는 1시간 뒤 요청하지만 시스템이 미룰 수 있어, 엔트리를 3시간치 만들어 그동안 시계가 멈추지 않게 한다.
        let entries = (0..<180).map { minute in
            entry(at: minuteStart.addingTimeInterval(Double(minute) * 60), region: region, forecast: forecast)
        }
        let policy: TimelineReloadPolicy = .after(now.addingTimeInterval((forecast == nil ? 30 : 60) * 60))
        return Timeline(entries: entries, policy: policy)
    }

    private func entry(at date: Date, region: Region, forecast: WeatherForecast?) -> WindowEntry {
        WindowEntry(date: date, context: factory.context(at: date, region: region, forecast: forecast))
    }
}
