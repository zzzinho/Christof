import ChristofKit
import Foundation
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

// 실제 지역·날짜를 SceneContextFactory 에 넣어 해·달 계산과 이벤트 판정을 그대로 거치고, 날씨만 가짜 예보를 준다.

struct Scenario {
    let name: String
    let region: Region
    let date: Date
    let weather: (condition: WeatherCondition, intensity: Double, cloudCover: Double, temperature: Double)?

    init(_ name: String, _ region: Region, _ date: Date, _ weather: (WeatherCondition, Double, Double, Double)?) {
        self.name = name
        self.region = region
        self.date = date
        self.weather = weather.map { (condition: $0.0, intensity: $0.1, cloudCover: $0.2, temperature: $0.3) }
    }

    var forecast: WeatherForecast? {
        weather.map {
            WeatherForecast(samples: [
                WeatherSample(time: date, condition: $0.condition, intensity: $0.intensity, cloudCover: $0.cloudCover, temperatureCelsius: $0.temperature),
            ])
        }
    }
}

func region(_ key: String) -> Region {
    guard let region = CountryRegistry.standard.region(id: "KR.\(key)") else { fatalError("등록되지 않은 지역: KR.\(key)") }
    return region
}

func localTime(_ region: Region, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = region.timeZone
    guard let date = calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute)) else {
        fatalError("잘못된 날짜: \(month)/\(day) \(hour):\(minute)")
    }
    return date
}

func sunTime(_ region: Region, _ month: Int, _ day: Int, _ event: KeyPath<SunState, Date?>) -> Date {
    let noon = localTime(region, month, day, 12)
    guard let time = SolarCalculator.state(at: noon, latitude: region.latitude, longitude: region.longitude, timeZone: region.timeZone)[keyPath: event] else {
        fatalError("\(region.name) \(month)/\(day) 에는 일출·일몰이 없다")
    }
    return time
}

let seoul = region("seoul")
let scenarios: [Scenario] = [
    Scenario("01-summer-clear-day", seoul, localTime(seoul, 7, 15, 13), (.clear, 0, 0.1, 31)),
    Scenario("02-spring-blossom-day", region("daegu"), localTime(region("daegu"), 4, 5, 11), (.partlyCloudy, 0, 0.3, 17)),
    Scenario("03-sunrise", seoul, sunTime(seoul, 10, 18, \.sunrise), (.clear, 0, 0.2, 9)),
    Scenario("04-sunset", region("busan"), sunTime(region("busan"), 6, 21, \.sunset), (.partlyCloudy, 0, 0.35, 24)),
    Scenario("05-crescent-night", seoul, localTime(seoul, 3, 22, 20), (.clear, 0, 0, 5)),
    Scenario("06-chuseok-full-moon", seoul, localTime(seoul, 9, 25, 21), (.clear, 0, 0.05, 19)),
    Scenario("07-rainy-afternoon", region("gwangju"), localTime(region("gwangju"), 7, 10, 15), (.rain, 0.6, 0.95, 24)),
    Scenario("08-thunderstorm", region("daejeon"), localTime(region("daejeon"), 8, 5, 17), (.thunderstorm, 0.8, 1, 27)),
    Scenario("09-foggy-morning", region("chuncheon"), localTime(region("chuncheon"), 11, 5, 7, 30), (.fog, 0.7, 0.6, 6)),
    Scenario("10-snowy-christmas-day", seoul, localTime(seoul, 12, 25, 10), (.snow, 0.6, 0.9, -2)),
    Scenario("11-christmas-eve-night", seoul, localTime(seoul, 12, 24, 21), (.clear, 0, 0.1, -5)),
    Scenario("12-halloween-night", seoul, localTime(seoul, 10, 31, 20), (.partlyCloudy, 0, 0.4, 12)),
    Scenario("13-seollal-morning", seoul, localTime(seoul, 2, 17, 8), (.clear, 0, 0.1, -3)),
    Scenario("14-buddha-birthday-sunset", seoul, sunTime(seoul, 5, 24, \.sunset), (.clear, 0, 0.1, 20)),
    Scenario("15-autumn-foliage-day", region("jeonju"), localTime(region("jeonju"), 10, 25, 14), (.clear, 0, 0.15, 16)),
    Scenario("16-offline-night", region("jeju"), localTime(region("jeju"), 1, 10, 23), nil),
    Scenario("17-jeongwol-daeboreum-night", seoul, localTime(seoul, 3, 3, 21), (.clear, 0, 0.05, 2)),
    Scenario("18-new-year-sunrise", region("gangneung"), sunTime(region("gangneung"), 1, 1, \.sunrise), (.clear, 0, 0.1, -6)),
]

let output = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "snapshots", isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let factory = SceneContextFactory()
let sizeNames: [ChristofKit.WindowStyle: String] = [.compact: "small", .regular: "medium", .expanded: "large"]
for scenario in scenarios {
    let context = factory.context(at: scenario.date, region: scenario.region, forecast: scenario.forecast)
    let time = context.date.formatted(Date.FormatStyle(date: .numeric, time: .shortened, timeZone: context.region.timeZone))
    print(
        "\(scenario.name): \(context.region.name) \(time)",
        "해 \(Int(context.sun.altitude.rounded()))°/\(Int(context.sun.azimuth.rounded()))°",
        "달 위상 \((context.moon.phase * 100).rounded() / 100) \(Int(context.moon.altitude.rounded()))°/\(Int(context.moon.azimuth.rounded()))°",
        "이벤트 \(context.occasions.map(\.id))")
    for style in ChristofKit.WindowStyle.allCases {
        let size = style.referenceSize
        // 위젯은 시스템이 둥근 모서리로 자른다. 비슷하게 보이도록 같은 반지름으로 자른다.
        let view = WindowView(context: context, style: style)
            .frame(width: size.width, height: size.height)
            .clipShape(.rect(cornerRadius: 22, style: .continuous))
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let url = output.appending(path: "\(scenario.name)-\(sizeNames[style]!).png")
        guard let image = renderer.cgImage,
              let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
        else {
            fatalError("렌더링 실패: \(url.lastPathComponent)")
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { fatalError("저장 실패: \(url.path)") }
    }
}
print("\(scenarios.count * ChristofKit.WindowStyle.allCases.count) PNG → \(output.path)")
