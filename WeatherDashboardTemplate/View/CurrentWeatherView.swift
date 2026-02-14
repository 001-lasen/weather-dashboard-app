//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

struct CurrentWeatherView: View {
    @Bindable var viewModel: MainAppViewModel
    
    @State private var showSavedAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.35), .blue.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    content
                        .padding()
                }
                
                CitySearchBar(viewModel: viewModel, showSavedAlert: $showSavedAlert)
            }
        }
        .alert("Location saved!", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
        .task {
            if case .idle = viewModel.state {
                await viewModel.fetch()
            }
        }
        
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading weather...")
        case .error(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationMark.triangle")
                Text(message)
            }
        case .loaded(let weather):
            let highLow = viewModel.dailyHighLow(hourly: weather.hourly)
            let celcius = weather.current.temp - 273.15
            let advice = WeatherAdviceCategory.from(temp: celcius, description: weather.current.weather.first?.description ?? "")
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(cityName(from: weather.timeZone))
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: weather.current.dt))
                        .font(.subheadline)
                }
                
                HStack {
                    Text("\(Int(weather.current.temp - 273.15))°")
                        .font(.system(size: 72))
                        .bold()
                    
                    Spacer()
                    
                    WeatherIconView(iconCode: weather.current.weather.first?.icon)
                }
                
                Text(weather.current.weather.first?.description.capitalized ?? "")
                    .font(.subheadline)
                    .bold()
                    .fontWeight(.medium)
                
                HStack(spacing: 24) {
                    tempRangeView(icon: "arrow.up", label: "High", value: "\(highLow.high)°")
                    
                    tempRangeView(icon: "arrow.down", label: "Low", value: "\(highLow.low)°")
                }
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    weatherInfo(icon: "sunrise.fill", title: "Sunrise", value: DateFormatterUtils.formattedDate12Hour(from: weather.current.sunrise))
                    
                    weatherInfo(icon: "sunset.fill", title: "Sunset", value: DateFormatterUtils.formattedDate12Hour(from: weather.current.sunset))
                    
                    weatherInfo(icon: "gauge.medium", title: "Pressure", value: "\(weather.current.pressure) hPa")
                }
                
                WeatherInsightView(category: advice)
                
                Spacer()
                
            }
        }
    }
    
    private func weatherInfo(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .bold()
        }
    }
    
    struct WeatherIconView: View {
        let iconCode: String?
        
        var body: some View {
            if let iconCode {
                AsyncImage(
                    url: URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
                ) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_):
                        Image(systemName: "cloud.sun.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 112, height: 112)
                .id(iconCode)
            }
        }
    }
    
    struct WeatherInsightView: View {
        let category: WeatherAdviceCategory
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: category.icon)
                    .font(.system(size: 30))
                    .foregroundColor(category.color)
                    .frame(width: 50)
                
                Text(category.adviceText)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
        }
    }
    
    private func tempRangeView(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .bold()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .bold()
                
                Text(value)
                    .font(.headline)
                    .bold()
            }
        }
    }
    
    private func cityName(from timezone: String) -> String {
        return timezone.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? "Unknown"
    }
    
}
