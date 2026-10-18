import AppIntents
import ChristofKit
import WidgetKit

struct SelectRegionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "지역 선택"
    static let description = IntentDescription("창밖 풍경을 보여줄 지역을 고릅니다.")

    @Parameter(title: "지역")
    var region: RegionEntity?

    /// 고른 지역이 없거나 목록에서 사라졌으면 기본 지역.
    var selectedRegion: Region {
        region?.region ?? CountryRegistry.standard.defaultRegion
    }
}

struct RegionEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "지역"
    static let defaultQuery = RegionQuery()

    let region: Region

    var id: String { region.id }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(region.name)")
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
