//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

struct VisitedPlacesView: View {
    @Bindable var viewModel: MainAppViewModel
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showSavedAlert = false
    
    let onSelectPlace: () -> Void

    @Query(
        sort: \Place.lastUsedAt,
        order: .reverse
    )
    private var places: [Place]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.35), .blue.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    if places.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(places) { place in
                                Button {
                                    Task {
                                        await viewModel.loadVisitedPlace(place: place)
                                        onSelectPlace()
                                    }
                                } label: {
                                    placeRow(place)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let placeToDelete = places[index]
                                    modelContext.delete(placeToDelete)
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("Failed to delete place: \(error)")
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)

                    }

                    CitySearchBar(viewModel: viewModel, showSavedAlert: $showSavedAlert)
                }
            }
            .navigationTitle("Saved Places")
        }
        .alert("Location saved!", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}


private extension VisitedPlacesView {

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No saved places yet")
                .font(.headline)

            Text("Search for a city to save it here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    func placeRow(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.headline)
            
            Text("Lat: \(String(format: "%.2f", place.latitude)), Lon: \(String(format: "%.2f", place.longitude))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Last viewed: \(place.lastUsedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onLongPressGesture {
            let query = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? place.name
            if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                UIApplication.shared.open(url)
            }
        }
    }


}

