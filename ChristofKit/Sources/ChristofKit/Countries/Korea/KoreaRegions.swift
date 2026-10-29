import Foundation

/// 부산이 첫 지역이라 기본 지역이 된다.
public enum KoreaRegions {
    // 좌표는 Open-Meteo 지오코딩(GeoNames) 의 도시 중심점.
    public static let all: [Region] = [
        region("busan", LocalizedName(en: "Busan", ko: "부산"), 35.10168, 129.03004, RegionLooks(far: BusanView())),
        region("seoul", LocalizedName(en: "Seoul", ko: "서울"), 37.566, 126.9784, RegionLooks(far: SeoulView())),
    ]

    private static func region(_ key: String, _ name: LocalizedName, _ latitude: Double, _ longitude: Double, _ looks: RegionLooks) -> Region {
        // 고정 식별자라 실패하지 않는다.
        Region(id: "KR.\(key)", name: name, countryCode: "KR", latitude: latitude, longitude: longitude, timeZone: TimeZone(identifier: "Asia/Seoul")!, looks: looks)
    }
}
