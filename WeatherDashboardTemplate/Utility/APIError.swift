//
//  APIError.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-07.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case inValidResponse
    case decoding(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .inValidResponse:
            return "invalid response from server"
        case .decoding(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "A network error occurred: \(error.localizedDescription)"
        }
    }
}
