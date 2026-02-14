//
//  CityCoordinates.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-07.
//

import Foundation

struct CityCoordinates: Decodable, Equatable, Hashable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
}
