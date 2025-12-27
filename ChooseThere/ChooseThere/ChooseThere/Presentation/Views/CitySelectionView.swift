//
//  CitySelectionView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import SwiftData
import SwiftUI

// MARK: - CitySelectionView

/// View reutilizável para seleção de cidade
/// Usada no onboarding e em Configurações
struct CitySelectionView: View {
  // MARK: - Environment

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  // MARK: - Properties

  /// Callback executado quando uma cidade é selecionada
  let onCitySelected: (CityOption) -> Void

  /// Indica se estamos no contexto de onboarding (afeta o layout)
  var isOnboarding: Bool = false

  /// Título customizado (nil usa o padrão)
  var customTitle: String?

  // MARK: - State

  @State private var cities: [CityOption] = []
  @State private var selectedCity: CityOption?
  @State private var searchText = ""

  // MARK: - Computed

  private var filteredCities: [CityOption] {
    if searchText.isEmpty {
      return cities
    }
    return cities.filter { city in
      city.isAnyCity ||
      city.displayName.localizedCaseInsensitiveContains(searchText)
    }
  }

  private var title: String {
    customTitle ?? (isOnboarding ? "Onde você quer buscar?" : "Selecionar cidade")
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        AppColors.background.ignoresSafeArea()

        VStack(spacing: 0) {
          if isOnboarding {
            onboardingHeader
          }

          cityList
        }
      }
      .navigationTitle(isOnboarding ? "" : title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if !isOnboarding {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") {
              dismiss()
            }
            .foregroundStyle(AppColors.textSecondary)
          }
        }
      }
      .searchable(text: $searchText, prompt: "Buscar cidade...")
      .onAppear {
        loadCities()
      }
    }
  }

  // MARK: - Onboarding Header

  private var onboardingHeader: some View {
    VStack(spacing: 16) {
      // Icon
      ZStack {
        Circle()
          .fill(AppColors.accent.opacity(0.15))
          .frame(width: 100, height: 100)

        Image(systemName: "mappin.and.ellipse")
          .font(.system(size: 40, weight: .semibold))
          .foregroundStyle(AppColors.accent)
      }
      .padding(.top, 24)

      // Title
      Text(title)
        .font(.title2.weight(.bold))
        .foregroundStyle(AppColors.textPrimary)
        .multilineTextAlignment(.center)

      // Subtitle
      Text("Escolha uma cidade para ver restaurantes dessa região, ou selecione \"Qualquer lugar\" para buscar por perto.")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
    .padding(.bottom, 16)
  }

  // MARK: - City List

  private var cityList: some View {
    List {
      ForEach(filteredCities) { city in
        cityRow(for: city)
      }
    }
    .listStyle(.insetGrouped)
    .scrollContentBackground(.hidden)
  }

  private func cityRow(for city: CityOption) -> some View {
    Button {
      selectCity(city)
    } label: {
      HStack(spacing: 12) {
        // Icon
        if city.isAnyCity {
          Image(systemName: "location.fill")
            .font(.system(size: 20))
            .foregroundStyle(AppColors.accent)
            .frame(width: 32)
        } else {
          Image(systemName: "building.2.fill")
            .font(.system(size: 18))
            .foregroundStyle(AppColors.textSecondary)
            .frame(width: 32)
        }

        // Text
        VStack(alignment: .leading, spacing: 2) {
          Text(city.isAnyCity ? city.displayName : city.city)
            .font(city.isAnyCity ? .body.weight(.semibold) : .body)
            .foregroundStyle(AppColors.textPrimary)

          if !city.isAnyCity {
            Text(city.state)
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)
          }
        }

        Spacer()

        // Checkmark
        if selectedCity?.id == city.id {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 22))
            .foregroundStyle(AppColors.primary)
        }
      }
      .padding(.vertical, 4)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .listRowBackground(
      selectedCity?.id == city.id
        ? AppColors.primary.opacity(0.1)
        : AppColors.surface
    )
    .accessibilityLabel(city.displayName)
    .accessibilityHint(selectedCity?.id == city.id ? "Selecionada" : "Toque para selecionar")
  }

  // MARK: - Actions

  private func loadCities() {
    let repository = SwiftDataRestaurantRepository(context: modelContext)
    cities = CityCatalog.extractCities(from: repository)

    // Pre-select current city if exists
    let currentKey = AppSettingsStorage.selectedCityKey
    selectedCity = CityCatalog.findOption(for: currentKey, in: cities)
  }

  private func selectCity(_ city: CityOption) {
    selectedCity = city

    // Persist selection
    AppSettingsStorage.selectedCityKey = city.id

    // Small delay for visual feedback
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      onCitySelected(city)
    }
  }
}

// MARK: - Preview

#Preview("Onboarding") {
  CitySelectionView(
    onCitySelected: { city in
      print("Selected: \(city.displayName)")
    },
    isOnboarding: true
  )
  .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}

#Preview("Settings") {
  CitySelectionView(
    onCitySelected: { city in
      print("Selected: \(city.displayName)")
    },
    isOnboarding: false
  )
  .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}

