import AppIntents
import ChristofKit
import WidgetKit

struct SelectRegionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Region"
    static let description = IntentDescription("Choose the region to show outside the window.")

    @Parameter(title: "Region")
    var region: RegionEntity?

    // 목록에서 빠진 지역을 골라 둔 위젯도 기본 지역으로 그린다.
    var selectedRegion: Region {
        region?.region ?? CountryRegistry.standard.defaultRegion
    }
}

struct RegionEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Region"
    static let defaultQuery = RegionQuery()

    let region: Region

    var id: String { region.id }

    var displayRepresentation: DisplayRepresentation {
        // 위젯 편집은 시스템 화면이라 둘레 문구처럼 시스템 언어를 따른다.
        DisplayRepresentation(title: "\(region.name[AppLanguage(.current)])")
    }
}

struct RegionQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [RegionEntity] {
        identifiers.compactMap(CountryRegistry.standard.region(id:)).map(RegionEntity.init)
    }

    func suggestedEntities() async throws -> [RegionEntity] {
        CountryRegistry.standard.regions.map(RegionEntity.init)
    }

    func defaultResult() async -> RegionEntity? {
        RegionEntity(region: CountryRegistry.standard.defaultRegion)
    }
}
