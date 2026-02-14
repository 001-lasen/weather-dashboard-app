//
//  NavBarView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 19/10/2025.
//

import SwiftUI
import SwiftData

struct NavBarView: View {
    @Environment(MainAppViewModel.self) var vm

    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CurrentWeatherView(viewModel: vm)
                .tabItem {
                    Label("Now", systemImage: "sun.max.fill")
                }
                .tag(0)
            
            ForecastView(viewModel: vm)
                .tabItem {
                    Label("Forecast", systemImage: "calendar")
                }
                .tag(1)
            
            MapView(viewModel: vm)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(2)
            
            VisitedPlacesView(
                viewModel: vm,
                onSelectPlace: { selectedTab = 0 }
            )
            .tabItem {
                Label("Saved", systemImage: "globe")
            }
            .tag(3)
        }
        .accentColor(.blue)
    }
}
