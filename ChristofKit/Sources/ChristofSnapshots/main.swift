import ChristofKit
import Foundation
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

// 실제 지역·날짜를 SceneContextFactory 에 넣어 해·달 계산과 이벤트 판정을 그대로 거치고, 날씨만 가짜 예보를 준다.
// PNG 와 함께 칸 격자(.grid)와 장면 입력(scenes.json)을 써서 Scripts/compare-design.mjs 가 시안과 칸 단위로 비교한다.

struct Scenario {
    let name: String
    let region: Region
    let date: Date
    let weather: (condition: WeatherCondition, intensity: Double, cloudCover: Double, temperature: Double)?
    /// 이름이 약속한 이벤트. 규칙이 바뀌어 빠지면 실행을 멈춘다.
    let occasion: String?

    init(_ name: String, _ region: Region, _ date: Date, _ weather: (WeatherCondition, Double, Double, Double)?, occasion: String? = nil) {
        self.name = name
        self.region = region
        self.date = date
        self.weather = weather.map { (condition: $0.0, intensity: $0.1, cloudCover: $0.2, temperature: $0.3) }
        self.occasion = occasion
    }

    var forecast: WeatherForecast? {
        weather.map {
            WeatherForecast(samples: [
                WeatherSample(time: date, condition: $0.condition, intensity: $0.intensity, cloudCover: $0.cloudCover, temperatureCelsius: $0.temperature),
            ])
        }
    }
}

func region(_ id: String) -> Region {
    guard let region = CountryRegistry.standard.region(id: id) else { fatalError("등록되지 않은 지역: \(id)") }
    return region
}

func fileSuffix(_ size: WindowSize) -> String {
    switch size {
    case .compact: "small"
    case .regular: "medium"
    case .expanded: "large"
    }
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

let seoul = region("KR.seoul")
let scenarios: [Scenario] = [
    Scenario("01-summer-clear-day", seoul, localTime(seoul, 7, 15, 13), (.clear, 0, 0.1, 31)),
    Scenario("02-spring-blossom-day", region("KR.daegu"), localTime(region("KR.daegu"), 4, 5, 11), (.partlyCloudy, 0, 0.3, 17)),
    Scenario("03-sunrise", seoul, sunTime(seoul, 10, 18, \.sunrise), (.clear, 0, 0.2, 9), occasion: "sky.sunrise"),
    Scenario("04-sunset", region("KR.busan"), sunTime(region("KR.busan"), 6, 21, \.sunset), (.partlyCloudy, 0, 0.35, 24), occasion: "sky.sunset"),
    Scenario("05-crescent-night", seoul, localTime(seoul, 3, 22, 20), (.clear, 0, 0, 5)),
    Scenario("06-chuseok-full-moon", seoul, localTime(seoul, 9, 25, 21), (.clear, 0, 0.05, 19), occasion: "KR.chuseok"),
    Scenario("07-rainy-afternoon", region("KR.gwangju"), localTime(region("KR.gwangju"), 7, 10, 15), (.rain, 0.6, 0.95, 24)),
    Scenario("08-thunderstorm", region("KR.daejeon"), localTime(region("KR.daejeon"), 8, 5, 17), (.thunderstorm, 0.8, 1, 27)),
    Scenario("09-foggy-morning", region("KR.chuncheon"), localTime(region("KR.chuncheon"), 11, 5, 7, 30), (.fog, 0.7, 0.6, 6)),
    Scenario("10-snowy-christmas-day", seoul, localTime(seoul, 12, 25, 10), (.snow, 0.6, 0.9, -2), occasion: "KR.christmas"),
    Scenario("11-christmas-eve-night", seoul, localTime(seoul, 12, 24, 21), (.clear, 0, 0.1, -5), occasion: "KR.christmasEve"),
    Scenario("12-halloween-night", seoul, localTime(seoul, 10, 31, 20), (.partlyCloudy, 0, 0.4, 12), occasion: "KR.halloween"),
    Scenario("13-seollal-morning", seoul, localTime(seoul, 2, 17, 8), (.clear, 0, 0.1, -3), occasion: "KR.seollal"),
    Scenario("14-buddha-birthday-sunset", seoul, sunTime(seoul, 5, 24, \.sunset), (.clear, 0, 0.1, 20), occasion: "KR.buddhasBirthday"),
    Scenario("15-autumn-foliage-day", region("KR.jeonju"), localTime(region("KR.jeonju"), 10, 25, 14), (.clear, 0, 0.15, 16)),
    Scenario("16-offline-night", region("KR.jeju"), localTime(region("KR.jeju"), 1, 10, 23), nil),
    Scenario("17-jeongwol-daeboreum-night", seoul, localTime(seoul, 3, 3, 21), (.clear, 0, 0.05, 2), occasion: "KR.jeongwolDaeboreum"),
    Scenario("18-new-year-sunrise", region("KR.gangneung"), sunTime(region("KR.gangneung"), 1, 1, \.sunrise), (.clear, 0, 0.1, -6), occasion: "KR.newYearsDay"),
    Scenario("19-warm-winter-clear-day", region("KR.busan"), localTime(region("KR.busan"), 1, 15, 14), (.clear, 0, 0.1, 8)),
]

let output = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "snapshots", isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

/// 시안(06-lofi.html)의 SCENES 한 줄과 같은 모양. 계산한 해·달 값을 그대로 넘겨 같은 입력으로 그리게 한다.
func designScene(_ name: String, _ context: SceneContext) -> [String: Any] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = context.region.timeZone
    let t = calendar.dateComponents([.month, .day, .hour, .minute], from: context.date)
    return [
        "title": name, "region": context.region.name,
        "date": "\(t.month!)월 \(t.day!)일", "time": "\(t.hour!):\(String(format: "%02d", t.minute!))", "hour": t.hour!,
        "season": "\(context.season)",
        "sun": [context.sun.altitude, context.sun.azimuth],
        "moon": [context.moon.phase, context.moon.altitude, context.moon.azimuth],
        "weather": context.weather.map { ["\($0.condition)", $0.intensity, $0.cloudCover, $0.temperatureCelsius] as [Any] } ?? NSNull(),
        "occasions": context.occasions.map(\.id),
    ]
}

func gridText(_ grid: DotGrid) -> String {
    (0..<grid.rows).map { y in
        (0..<grid.cols).map { x in grid.cells[y * grid.cols + x].map { String(format: "%06X", $0) } ?? "------" }.joined(separator: " ")
    }.joined(separator: "\n")
}

let factory = SceneContextFactory()
var designScenes: [[String: Any]] = []
for scenario in scenarios {
    let context = factory.context(at: scenario.date, region: scenario.region, forecast: scenario.forecast)
    if let id = scenario.occasion, !context.occasions.contains(where: { $0.id == id }) {
        fatalError("\(scenario.name): 이벤트 \(id) 가 진행 중이 아니다. 실제 이벤트 \(context.occasions.map(\.id))")
    }
    let time = context.date.formatted(Date.FormatStyle(date: .numeric, time: .shortened, timeZone: context.region.timeZone))
    print(
        "\(scenario.name): \(context.region.name) \(time)",
        "해 \(Int(context.sun.altitude.rounded()))°/\(Int(context.sun.azimuth.rounded()))°",
        "달 위상 \((context.moon.phase * 100).rounded() / 100) \(Int(context.moon.altitude.rounded()))°/\(Int(context.moon.azimuth.rounded()))°",
        "이벤트 \(context.occasions.map(\.id))")
    designScenes.append(designScene(scenario.name, context))
    for style in WindowSize.allCases {
        let size = style.referenceSize
        let grid = SceneComposer.grid(for: context, cols: Int((size.width / DotGrid.dot).rounded(.up)), rows: Int((size.height / DotGrid.dot).rounded(.up)))
        try gridText(grid).write(to: output.appending(path: "\(scenario.name)-\(fileSuffix(style)).grid"), atomically: true, encoding: .utf8)
        // 위젯은 시스템이 둥근 모서리로 자른다. 비슷하게 보이도록 같은 반지름으로 자른다.
        let view = WindowView(context: context)
            .frame(width: size.width, height: size.height)
            .clipShape(.rect(cornerRadius: 22, style: .continuous))
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let url = output.appending(path: "\(scenario.name)-\(fileSuffix(style)).png")
        guard let image = renderer.cgImage,
              let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
        else {
            fatalError("렌더링 실패: \(url.lastPathComponent)")
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { fatalError("저장 실패: \(url.path)") }
    }
}
try JSONSerialization.data(withJSONObject: designScenes, options: [.prettyPrinted, .sortedKeys]).write(to: output.appending(path: "scenes.json"))
print("\(scenarios.count * WindowSize.allCases.count) PNG → \(output.path)")
