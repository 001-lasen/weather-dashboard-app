//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(MainAppViewModel.self) var vm
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var viewModel: MainAppViewModel
    
    @State private var showSavedAlert = false
    
    @Query(sort: \TouristPlace.name) private var allPlaces: [TouristPlace]
    
    private var topFivePlaces: [TouristPlace] {
        Array(allPlaces.prefix(5))
    }

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Map(position: $position) {
                    ForEach(topFivePlaces) { place in
                        Annotation(place.name, coordinate: place.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                                .background(Circle().fill(.white))
                                .onTapGesture {
                                    withAnimation { zoomTo(place.coordinate) }
                                }
                        }
                    }
                }
                .frame(height: 300)

                Text("Top 5 Tourist Attractions in London")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.3))
                    .foregroundColor(.white)

                List(topFivePlaces) { place in
                    HStack(spacing: 15) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        
                        Text(place.name)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation { centerOn(place.coordinate) }
                    }
                }
                .listStyle(.plain)
                .background(
                    LinearGradient(colors: [Color(red: 0.1, green: 0.2, blue: 0.4), .black],
                                   startPoint: .top, endPoint: .bottom)
                )
                
                Spacer()
                
                CitySearchBar(viewModel: viewModel, showSavedAlert: $showSavedAlert)
            }
        }
        .onAppear {
            if allPlaces.isEmpty {
                addSampleData()
            }
        }
    }
    
    /*
     TODO -  This does not work as needed
     
     
     
     Half way through this I ran out of beer.
     I remember arguing with the chatta
     He doesnt take insults very well
     */
    
    private func addSampleData() {
        let samples = [
            TouristPlace(name: "Tower Bridge", latitude: 51.5055, longitude: -0.0754),
            TouristPlace(name: "The Queen's Walk", latitude: 51.5042, longitude: -0.1111),
            TouristPlace(name: "Tower Torture", latitude: 51.5081, longitude: -0.0759),
            TouristPlace(name: "The View From The Shard", latitude: 51.5045, longitude: -0.0865),
            TouristPlace(name: "Roman Wall", latitude: 51.5103, longitude: -0.0768)
        ]
        for place in samples { modelContext.insert(place) }
    }
}

extension MapView {
    func zoomTo(_ coordinate: CLLocationCoordinate2D) {
        position = .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500))
    }
    
    func centerOn(_ coordinate: CLLocationCoordinate2D) {
        position = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
}
