import Foundation

enum OpenMeteoRequest {
    // 리터럴이라 실패하지 않는다.
    private static let endpoint = URL(string: "https://api.open-meteo.com/v1/forecast")!
    private static let variables = "temperature_2m,weather_code,cloud_cover"

    static func url(for region: Region) -> URL {
        endpoint.appending(queryItems: [
            URLQueryItem(name: "latitude", value: String(region.latitude)),
            URLQueryItem(name: "longitude", value: String(region.longitude)),
            URLQueryItem(name: "current", value: variables),
            URLQueryItem(name: "hourly", value: variables),
            URLQueryItem(name: "timeformat", value: "unixtime"),
            URLQueryItem(name: "forecast_days", value: "2"),
        ])
    }
}
