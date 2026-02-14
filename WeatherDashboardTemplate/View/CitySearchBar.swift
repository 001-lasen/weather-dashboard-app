//
//  CitySearchBar.swift
//  WeatherDashboardTemplate
//
//  Created by Lasen Punyawardana on 2026-01-07.
//

import SwiftUI

struct CitySearchBar: View {
    @Bindable var viewModel: MainAppViewModel
    @Binding var showSavedAlert: Bool

    var body: some View {
        HStack {
            TextField("Enter city name", text: $viewModel.query)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit { search() }

            Button(action: search) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func search() {
        Task {
            await viewModel.searchCity(viewModel.query) {
                showSavedAlert = true
            }
        }
    }
}

