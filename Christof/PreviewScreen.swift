import ChristofKit
import SwiftUI
import WidgetKit

struct PreviewScreen: View {
    private let store = SceneSettingsStore()
    @State private var saved: SceneSettings
    @State private var settings: PreviewSettings
    @State private var realForecast: Result<WeatherForecast, any Error>?
    private let weather: any WeatherProviding = .standard
    private let factory = SceneContextFactory()

    init() {
        let saved = SceneSettingsStore().load()
        _saved = State(initialValue: saved)
        _settings = State(initialValue: PreviewSettings(saved: saved))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsPanel(settings: $settings, forecastStatus: forecastStatus)
                SaveBar(hasChanges: settings.sceneSettings != saved, save: save)
                TimelineView(.everyMinute) { timeline in
                    // 실패는 위 상태 문구로 보여주고, 장면은 날씨 없이 그린다.
                    let context = factory.context(now: timeline.date, region: settings.region, realForecast: try? realForecast?.get(), settings: settings.sceneSettings)
                    WindowPreviews(context: context)
                }
                WidgetGuide()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task(id: settings.region) {
            realForecast = nil
            let result: Result<WeatherForecast, any Error>
            do {
                result = .success(try await weather.forecast(for: settings.region))
            } catch {
                result = .failure(error)
            }
            // 지역이 바뀌어 취소된 요청이 새 지역의 상태를 덮지 않게 한다.
            if !Task.isCancelled { realForecast = result }
        }
    }

    private func save() {
        saved = settings.sceneSettings
        store.save(saved)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private var forecastStatus: String {
        switch realForecast {
        case nil: "실제 예보 불러오는 중…"
        case .success(let forecast): status(of: forecast)
        case .failure(let error): "실제 예보를 가져오지 못했습니다: \(error.localizedDescription)"
        }
    }

    private func status(of forecast: WeatherForecast) -> String {
        guard let first = forecast.samples.first, let last = forecast.samples.last else { return "실제 예보가 비어 있습니다" }
        let format = Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: settings.region.timeZone)
        let range = "실제 예보 \(first.time.formatted(format)) ~ \(last.time.formatted(format))"
        guard !settings.usesCurrentTime, forecast.sample(at: settings.customDate) == nil else { return range }
        return range + "\n지정한 시각이 예보 범위 밖이라 날씨 없이 그립니다. 날씨를 직접 고르세요."
    }
}

private struct SettingsPanel: View {
    @Binding var settings: PreviewSettings
    let forecastStatus: String

    private static let occasions = CountryRegistry.standard.profiles.flatMap(\.occasions)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("지역") {
                Picker("지역", selection: $settings.region) {
                    ForEach(CountryRegistry.standard.regions) { Text($0.name).tag($0) }
                }
                .labelsHidden()
            }
            LabeledContent("시각") {
                Picker("시각", selection: $settings.usesCurrentTime) {
                    Text("지금").tag(true)
                    Text("직접 지정").tag(false)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .fixedSize()
            }
            if !settings.usesCurrentTime {
                // 지역 시간대로 보여줘야 "서울 저녁 7시" 처럼 고를 수 있다.
                DatePicker("\(settings.region.name) 시각", selection: $settings.customDate)
                    .environment(\.timeZone, settings.region.timeZone)
            }
            LabeledContent("날씨") {
                Picker("날씨", selection: $settings.forcedCondition) {
                    Text("실제").tag(WeatherCondition?.none)
                    ForEach(WeatherCondition.allCases, id: \.self) { Text($0.koreanName).tag(Optional($0)) }
                }
                .labelsHidden()
            }
            if settings.forcedCondition == nil {
                Text(forecastStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            LabeledContent("이벤트") {
                Picker("이벤트", selection: $settings.occasion) {
                    Text("자동").tag(OccasionSelection.automatic)
                    ForEach(Self.occasions) { Text($0.name).tag(OccasionSelection.manual(occasionID: $0.id)) }
                }
                .labelsHidden()
            }
            if settings.occasion != .automatic {
                Text("고른 명절을 날짜와 상관없이 보여줍니다. 일출·일몰·보름달은 계속 자동입니다.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct SaveBar: View {
    let hasChanges: Bool
    let save: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button("저장", action: save)
                .buttonStyle(.borderedProminent)
                .disabled(!hasChanges)
            Text(hasChanges ? "저장하면 시각·날씨·이벤트가 위젯에 반영됩니다. 지역은 위젯마다 위젯 편집에서 고릅니다." : "위젯에 반영된 설정입니다.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct WindowPreviews: View {
    let context: SceneContext

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
            ForEach(WindowSize.allCases, id: \.self) { preview(style: $0) }
        }
    }

    private var summary: String {
        let time = context.date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: context.region.timeZone))
        let weather = context.weather?.condition.koreanName ?? "없음"
        let occasions = context.occasions.isEmpty ? "없음" : context.occasions.map(\.name).joined(separator: ", ")
        return "\(context.region.name) \(time) · 날씨 \(weather) · 이벤트 \(occasions)"
    }

    private func preview(style: WindowSize) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Self.title(of: style))
                .font(.caption)
                .foregroundStyle(.secondary)
            WindowView(context: context)
                .frame(width: style.referenceSize.width, height: style.referenceSize.height)
                .clipShape(.rect(cornerRadius: 22))
        }
    }

    private static func title(of style: WindowSize) -> String {
        switch style {
        case .compact: "작게"
        case .regular: "중간"
        case .expanded: "크게"
        }
    }
}

private struct WidgetGuide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("위젯 추가 방법")
                .font(.headline)
            #if os(macOS)
            Text("바탕화면을 우클릭 → 위젯 편집 → Christof 를 찾아 바탕화면에 놓습니다.")
            Text("지역은 위젯을 우클릭 → 위젯 편집에서 고릅니다.")
            Text("위젯을 누르면 이 앱이 열립니다. 시각·날씨·이벤트를 바꾸고 저장하면 위젯에 반영됩니다.")
            #else
            Text("홈 화면을 길게 누르기 → 편집 → 위젯 추가 → Christof 를 고릅니다.")
            Text("지역은 위젯을 길게 눌러 위젯 편집에서 고릅니다.")
            Text("위젯을 누르면 이 앱이 열립니다. 시각·날씨·이벤트를 바꾸고 저장하면 위젯에 반영됩니다.")
            #endif
            Text("버전 \(Self.info("CFBundleShortVersionString")) (\(Self.info("CFBundleVersion")))")
                .foregroundStyle(.secondary)
        }
        .font(.callout)
    }

    private static func info(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "?"
    }
}
