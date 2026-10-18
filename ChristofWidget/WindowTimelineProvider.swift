import ChristofKit
import WidgetKit

struct WindowEntry: TimelineEntry {
    let date: Date
    let context: SceneContext
}

struct WindowTimelineProvider: AppIntentTimelineProvider {
    var weather: any WeatherProviding = OpenMeteoWeatherProvider()
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
        // 예보 실패(오프라인 등)는 날씨 없는 장면으로 그리고, 정책으로 15분 뒤 다시 시도한다.
        let forecast = try? await weather.forecast(for: region)
        let minuteStart = Date(timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate / 60).rounded(.down) * 60)
        let entries = (0..<60).map { minute in
            entry(at: minuteStart.addingTimeInterval(Double(minute) * 60), region: region, forecast: forecast)
        }
        let policy: TimelineReloadPolicy = forecast == nil ? .after(now.addingTimeInterval(15 * 60)) : .atEnd
        return Timeline(entries: entries, policy: policy)
    }

    private func entry(at date: Date, region: Region, forecast: WeatherForecast?) -> WindowEntry {
        WindowEntry(date: date, context: factory.context(at: date, region: region, forecast: forecast))
    }
}
