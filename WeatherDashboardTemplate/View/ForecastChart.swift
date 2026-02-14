//
//  ForecastChart.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-08.
//

import SwiftUI
import Charts

struct ForecastChart: View {
    let dailyTemps: [DailyTempEntry]

    private var chartData: [TempData] {
        dailyTemps.flatMap { day in
            [
                TempData(time: day.time, type: "High", value: day.high),
                TempData(time: day.time, type: "Low", value: day.low)
            ]
        }
    }

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    var body: some View {
        Chart {
            ForEach(chartData) { entry in
                BarMark(
                    x: .value("Day", entry.time),
                    y: .value("Temp", entry.value)
                )
                .foregroundStyle(by: .value("Type", entry.type))
                .position(by: .value("Type", entry.type))
                .cornerRadius(4)
            }
        }
        .chartLegend(.visible)

        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(dayFormatter.string(from: date))
                    }
                }
            }
        }

        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let temp = value.as(Double.self) {
                        Text("\(Int(temp))°")
                    }
                }
            }
        }

        .frame(height: 250)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}
