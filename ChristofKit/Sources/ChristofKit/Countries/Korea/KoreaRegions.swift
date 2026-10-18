import Foundation

/// 서울이 첫 지역이라 기본 지역이 된다.
public enum KoreaRegions {
    // 좌표는 Open-Meteo 지오코딩(GeoNames) 의 도시 중심점.
    public static let all: [Region] = [
        region("seoul", "서울", 37.566, 126.9784),
        region("busan", "부산", 35.10168, 129.03004),
        region("incheon", "인천", 37.45646, 126.70515),
        region("daegu", "대구", 35.87028, 128.59111),
        region("daejeon", "대전", 36.34913, 127.38493),
        region("gwangju", "광주", 35.15472, 126.91556),
        region("ulsan", "울산", 35.53722, 129.31667),
        region("sejong", "세종", 36.59245, 127.29223),
        region("suwon", "수원", 37.29111, 127.00889),
        region("chuncheon", "춘천", 37.87472, 127.73417),
        region("gangneung", "강릉", 37.75266, 128.87239),
        region("jeonju", "전주", 35.82194, 127.14889),
        region("jeju", "제주", 33.50972, 126.52194),
    ]

    private static func region(_ key: String, _ name: String, _ latitude: Double, _ longitude: Double) -> Region {
        // 고정 식별자라 실패하지 않는다.
        Region(id: "KR.\(key)", name: name, countryCode: "KR", latitude: latitude, longitude: longitude, timeZone: TimeZone(identifier: "Asia/Seoul")!)
    }
}
