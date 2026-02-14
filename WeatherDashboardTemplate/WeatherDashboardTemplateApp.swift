//
//  ForecastChart.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-08.
//

import SwiftUI
import SwiftData

@main
struct WeatherDashboardTemplateApp: App {

    private let vm: MainAppViewModel
    private let container: ModelContainer
    private let service: WeatherService

    init() {
        let weatherService = WeatherService()
        self.service = weatherService
        
        let schema = Schema([Place.self, AnnotationModel.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        self.container = try! ModelContainer(for: schema, configurations: [configuration])

        let context = ModelContext(container)
        self.vm = MainAppViewModel(service: service, context: context)
    }

    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environment(vm)
                .modelContainer(container)
        }
    }
}
