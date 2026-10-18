import Foundation

/// Open-Meteo 예보 API(키 없음)에서 현재 날씨와 이틀치 시간별 예보를 가져온다.
public struct OpenMeteoWeatherProvider: WeatherProviding {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// HTTP 200 이 아니면 `URLError(.badServerResponse)`, 응답 형식이 다르면 `DecodingError` 를 던진다.
    public func forecast(for region: Region) async throws -> WeatherForecast {
        let (data, response) = try await session.data(from: OpenMeteoRequest.url(for: region))
        // ponytail: 상태 코드를 버린다. 재시도·백오프를 상태별로 나눌 때 상태 코드를 담은 에러 타입을 만든다.
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try OpenMeteoResponse.forecast(from: data)
    }
}
