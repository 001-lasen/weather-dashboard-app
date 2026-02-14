//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

@MainActor
@Observable
class MainAppViewModel {
    var currentCityCoordinate: CLLocationCoordinate2D? = nil

    var state: LoadingState<WeatherResponse> = .idle
    
    var query: String = ""
    
    private let service: WeatherService
    private let modelContext: ModelContext
    
    init(service: WeatherService, context: ModelContext) {
        self.service = service
        self.modelContext = context
    }
    
    func fetch() async {
        let lat: Double = 51.50
        let lon: Double = 0.13
        
        guard !state.isLoading || state.error != nil else { return }
        
        state = LoadingState<WeatherResponse>.loading
        
        do {
            let currentWeather = try await service.fetchCurrentWeather(lat: lat, lon: lon)
            self.state = LoadingState<WeatherResponse>.loaded(currentWeather)
        } catch let error as APIError {
            self.state = LoadingState<WeatherResponse>.error(error.errorDescription ?? "Unknown Error")
        } catch {
            self.state = LoadingState<WeatherResponse>.error("An unexpected error occurred. Please try again.")
        }
    }
    
    func dailyHighLow(hourly: [HourlyWeather]) -> (high: Int, low: Int) {
        let temps = hourly.map { $0.temp }
        
        return (
            high: Int((temps.max() ?? 0) - 273.15),
            low: Int((temps.min() ?? 0) - 273.15)
        )
    }
    
    func searchCity(_ city: String, onSaved: (() -> Void)? = nil) async {
        let query = city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "London" : city
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            guard let location = placemarks.first?.location else {
                self.state = .error("Location not found.")
                return
            }
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            self.currentCityCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

            let weather = try await service.fetchCurrentWeather(lat: lat, lon: lon)
            self.state = .loaded(weather)
            
            let place = Place(name: query, latitude: lat, longitude: lon)
            let placeDescriptor = FetchDescriptor<Place>()
            let existingPlaces = try modelContext.fetch(placeDescriptor)
            if let existingPlace = existingPlaces.first(where: { $0.name == place.name }) {
                existingPlace.lastUsedAt = .now
            } else {
                modelContext.insert(place)
            }

            let defaultTouristPlaces = [
                TouristPlace(name: "City Center", latitude: lat, longitude: lon),
                TouristPlace(name: "Museum", latitude: lat + 0.01, longitude: lon),
                TouristPlace(name: "Park", latitude: lat, longitude: lon + 0.01),
                TouristPlace(name: "Shopping Street", latitude: lat - 0.01, longitude: lon),
                TouristPlace(name: "Landmark", latitude: lat, longitude: lon - 0.01)
            ]
            
            let touristDescriptor = FetchDescriptor<TouristPlace>()
            let existingTouristPlaces = try modelContext.fetch(touristDescriptor)
            
            for touristPlace in defaultTouristPlaces {
                if !existingTouristPlaces.contains(where: { $0.name == touristPlace.name }) {
                    modelContext.insert(touristPlace)
                }
            }
            
            try modelContext.save()
            onSaved?()
            
        } catch {
            self.state = .error("Could not find weather for '\(query)'.")
            print("Search Error: \(error.localizedDescription)")
        }
    }

    func loadVisitedPlace(place: Place) async {
        state = .loading
        
        do {
            let weather = try await service.fetchCurrentWeather(
                lat: place.latitude,
                lon: place.longitude
            )
            
            self.state = .loaded(weather)
            self.currentCityCoordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            
        } catch let error as APIError {
            self.state = .error(error.errorDescription ?? "Unknown Error")
        } catch {
            self.state = .error("An unexpected error occurred. Please try again.")
        }
    }
}
