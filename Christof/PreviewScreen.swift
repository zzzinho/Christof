import ChristofKit
import SwiftUI

struct PreviewScreen: View {
    @State private var settings = PreviewSettings()
    /// nil 이면 불러오는 중.
    @State private var realForecast: Result<WeatherForecast, any Error>?
    private let weather = OpenMeteoWeatherProvider()
    private let factory = SceneContextFactory()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsPanel(settings: $settings, forecastStatus: forecastStatus)
                TimelineView(.everyMinute) { timeline in
                    // 실패는 위 상태 문구로 보여주고, 장면은 날씨 없이 그린다.
                    let context = settings.sceneContext(now: timeline.date, realForecast: try? realForecast?.get(), factory: factory)
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

    private var forecastStatus: String {
        switch realForecast {
        case nil: "실제 예보 불러오는 중…"
        case .success(let forecast): "실제 예보 \(forecast.samples.count)시간분 받음"
        case .failure(let error): "실제 예보를 가져오지 못했습니다: \(error.localizedDescription)"
        }
    }
}

private struct SettingsPanel: View {
    @Binding var settings: PreviewSettings
    let forecastStatus: String

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
            preview("작게", style: .compact)
            preview("중간", style: .regular)
            preview("크게", style: .expanded)
        }
    }

    private var summary: String {
        let time = context.date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: context.region.timeZone))
        let weather = context.weather?.condition.koreanName ?? "없음"
        let occasions = context.occasions.isEmpty ? "없음" : context.occasions.map(\.name).joined(separator: ", ")
        return "\(context.region.name) \(time) · 날씨 \(weather) · 이벤트 \(occasions)"
    }

    // macOS SwiftUI 에도 WindowStyle 이 있어 모듈로 한정한다.
    private func preview(_ title: String, style: ChristofKit.WindowStyle) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            WindowView(context: context, style: style)
                .frame(width: style.referenceSize.width, height: style.referenceSize.height)
                .clipShape(.rect(cornerRadius: 22))
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
            #else
            Text("홈 화면을 길게 누르기 → 편집 → 위젯 추가 → Christof 를 고릅니다.")
            Text("지역은 위젯을 길게 눌러 위젯 편집에서 고릅니다.")
            #endif
        }
        .font(.callout)
    }
}
