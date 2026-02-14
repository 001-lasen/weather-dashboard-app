//
//  TouristPlaces.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-08.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class TouristPlace {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double

    init(name: String, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

