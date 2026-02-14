//
//  DefaultPlaceStorage.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-07.
//

import Foundation
import SwiftData

struct DefaultPlaceStorage: PlaceStorage {
    let modelContext: ModelContext

    func save(place: Place) {
        do {
            let descriptor = FetchDescriptor<Place>()
            let existing = try modelContext.fetch(descriptor)

            if let existingPlace = existing.first(where: { $0.name == place.name }) {
                existingPlace.lastUsedAt = .now
            } else {
                modelContext.insert(place)
            }

            try modelContext.save()
        } catch {
            print("Failed to save place: \(error)")
        }
    }

    func load() -> [Place] {
        do {
            let descriptor = FetchDescriptor<Place>(
                sortBy: [SortDescriptor(\.lastUsedAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load places: \(error)")
            return []
        }
    }
}

