//
//  PlaceStorage.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-07.
//

import Foundation

protocol PlaceStorage {
    func save(place: Place)
    func load() throws -> [Place]
}
