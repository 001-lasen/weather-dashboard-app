import Foundation

struct WeatherResponse: Decodable, Equatable, Hashable {
    let timeZone: String
    let current: NowWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
    
    enum CodingKeys: String, CodingKey {
        case timeZone = "timezone"
        case current
        case hourly
        case daily
    }
}

struct NowWeather: Decodable, Equatable, Hashable {
    let dt: TimeInterval
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let temp: Double
    let pressure: Int
    let weather: [WeatherFeeling]
}

struct WeatherFeeling: Decodable, Equatable, Hashable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct HourlyWeather: Decodable, Equatable, Hashable {
    let dt: TimeInterval
    let temp: Double
}

struct DailyWeather: Decodable, Equatable, Hashable {
    let dt: TimeInterval
    let summary: String
    let temp: DailyTemp
}

struct DailyTemp: Decodable, Equatable, Hashable {
    let min: Double
    let max: Double
}
