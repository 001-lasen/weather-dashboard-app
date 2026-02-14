//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation

@MainActor
final class WeatherService {
    private let apiKey = "6aafa8c75abb421b0e775dd3119c7405"
    
    func fetch<T: Decodable>(url: String, type: T.Type) async throws -> T {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.inValidResponse
            }
            
            return try JSONDecoder().decode(type, from: data)
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        } catch let error as URLError {
            throw APIError.networkError(error)
        }
    }
    
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely&appid=\(apiKey)"
        
        return try await fetch(url: urlString, type: WeatherResponse.self)
    }
    
    func fetchCityCoordinates(for city: String) async throws -> [CityCoordinates] {
        guard let cityQuery = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(cityQuery)&limit=1&appid=\(apiKey)"
        
        return try await fetch(url: urlString, type: [CityCoordinates].self)
    }
}
