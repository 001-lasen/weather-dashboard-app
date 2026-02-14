//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData

struct ForecastView: View {
    @Bindable var viewModel: MainAppViewModel
    
    @State private var showSavedAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.35), .blue.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        Text("8 Day Forecast - \(currentCityName)")
                            .font(.title2)
                            .bold()
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Daily Highs and Lows (°C)")
                            .font(.headline)
                            .bold()
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if case .loaded(let weather) = viewModel.state {
                        ForecastChart(dailyTemps: dailyList())
                    } else {
                        ProgressView("Loading forecasts...")
                            .frame(height: 250)
                    }
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(dailyList(), id: \.id) { day in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: day.time.timeIntervalSince1970))
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(day.summary)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack(spacing: 16) {
                                        Text("Low: \(Int(day.low))°")
                                            .foregroundColor(.blue)
                                        Text("High: \(Int(day.high))°")
                                            .foregroundColor(.red)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.blue.opacity(0.1))
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Spacer()
                    
                    CitySearchBar(viewModel: viewModel, showSavedAlert: $showSavedAlert)
                }
            }
        }
        .alert("Location saved!", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func dailyList() -> [DailyTempEntry] {
        guard case .loaded(let weather) = viewModel.state else { return [] }
        
        return weather.daily.prefix(8).map { day in
            DailyTempEntry(
                time: Date(timeIntervalSince1970: day.dt),
                summary: day.summary,
                high: day.temp.max - 273.15,
                low: day.temp.min - 273.15
            )
        }
    }
    
    private func cityName(from timezone: String) -> String {
        return timezone.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? "Unknown"
    }
    
    private var currentCityName: String {
        guard case .loaded(let weather) = viewModel.state else { return "Unknown" }
        return cityName(from: weather.timeZone)
    }
}

struct TempData: Identifiable {
    let id = UUID()
    let time: Date
    let type: String
    let value: Double
}

struct DailyTempEntry: Identifiable {
    let id = UUID()
    let time: Date
    let summary: String
    let high: Double
    let low: Double
}
