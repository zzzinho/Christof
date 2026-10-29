import AppIntents
import ChristofKit
import WidgetKit

struct SelectRegionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Region"
    static let description = IntentDescription("Choose the region to show outside the window.")

    @Parameter(title: "Region")
    var region: RegionEntity?

    // "자동"과 목록에서 빠진 지역(예전 버전의 대구 등)은 앱이 위치로 고른 지역으로 그린다.
    // ponytail: 위젯은 위치를 직접 보지 않아, 다른 도시로 옮겨도 앱을 열어야 바뀐다. 문제가 되면 NSWidgetWantsLocation 으로 위젯이 직접 본다.
    func selectedRegion(store: SceneSettingsStore) -> Region {
        region.flatMap { CountryRegistry.standard.region(id: $0.id) } ?? store.loadLocatedRegion()
    }
}

struct RegionEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Region"
    static let defaultQuery = RegionQuery()
    static let automatic = RegionEntity(id: "auto")

    let id: String

    var displayRepresentation: DisplayRepresentation {
        guard let region = CountryRegistry.standard.region(id: id) else { return DisplayRepresentation(title: "Auto") }
        // 위젯 편집은 시스템 화면이라 둘레 문구처럼 시스템 언어를 따른다.
        return DisplayRepresentation(title: "\(region.name[AppLanguage(.current)])")
    }
}

struct RegionQuery: EntityQuery {
    private static var all: [RegionEntity] {
        [.automatic] + CountryRegistry.standard.regions.map { RegionEntity(id: $0.id) }
    }

    func entities(for identifiers: [String]) async throws -> [RegionEntity] {
        Self.all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [RegionEntity] {
        Self.all
    }

    func defaultResult() async -> RegionEntity? {
        .automatic
    }
}
