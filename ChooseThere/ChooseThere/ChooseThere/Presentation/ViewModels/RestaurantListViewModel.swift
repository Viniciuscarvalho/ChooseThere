//
//  RestaurantListViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Combine
import Foundation
import Observation

@Observable
final class RestaurantListViewModel {
  // MARK: - Published State

  private(set) var restaurants: [Restaurant] = []
  private(set) var filteredRestaurants: [Restaurant] = []
  private(set) var categories: [String] = []
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  var searchText: String = "" {
    didSet { applyFilters() }
  }

  var selectedCategory: String? = nil {
    didSet { applyFilters() }
  }

  // MARK: - Dependencies

  private let restaurantRepository: RestaurantRepository
  private let appleMapsService: AppleMapsNearbySearchService
  private let cityGeocodingService: CityGeocodingService.Type

  // MARK: - Init

  init(
    restaurantRepository: RestaurantRepository,
    appleMapsService: AppleMapsNearbySearchService = AppleMapsNearbySearchService(),
    cityGeocodingService: CityGeocodingService.Type = CityGeocodingService.self
  ) {
    self.restaurantRepository = restaurantRepository
    self.appleMapsService = appleMapsService
    self.cityGeocodingService = cityGeocodingService
  }

  // MARK: - Public Methods

  func loadRestaurants() {
    isLoading = true
    errorMessage = nil

    Task {
      do {
        var allRestaurants = try restaurantRepository.fetchAll()
        
        // Filtrar por cidade selecionada se não for "Any City"
        if AppSettingsStorage.selectedCityKey != nil,
           let parsed = AppSettingsStorage.parseSelectedCity() {
          let cityFiltered = allRestaurants.filter { restaurant in
            restaurant.city.lowercased() == parsed.city.lowercased() &&
            restaurant.state.lowercased() == parsed.state.lowercased()
          }
          
          // Se não encontrou restaurantes locais para a cidade, buscar no Apple Maps
          if cityFiltered.isEmpty {
            await loadRestaurantsFromAppleMaps(city: parsed.city, state: parsed.state)
            return
          }
          
          allRestaurants = cityFiltered
        }
        
        await MainActor.run {
          restaurants = allRestaurants
          extractCategories()
          applyFilters()
          isLoading = false
        }
      } catch {
        await MainActor.run {
          errorMessage = "Erro ao carregar restaurantes: \(error.localizedDescription)"
          isLoading = false
        }
      }
    }
  }
  
  /// Carrega restaurantes do Apple Maps quando a cidade não está no JSON local
  private func loadRestaurantsFromAppleMaps(city: String, state: String) async {
    // Obter coordenadas da cidade
    guard let cityCoordinate = await cityGeocodingService.getCoordinates(city: city, state: state) else {
      await MainActor.run {
        errorMessage = "Não foi possível encontrar a localização de \(city), \(state)"
        isLoading = false
      }
      return
    }
    
    // Buscar restaurantes próximos usando Apple Maps
    do {
      let places = try await appleMapsService.search(
        radiusKm: 10, // Raio maior para cidade
        category: nil as String?,
        userCoordinate: cityCoordinate,
        cityHint: city
      )
      
      // Converter NearbyPlace para Restaurant (apenas para exibição na lista)
      // Nota: Estes não serão persistidos no SwiftData
      let restaurantsFromPlaces = places.map { place in
        Restaurant(
          id: place.id,
          name: place.name,
          category: place.categoryHint ?? "Restaurante",
          address: place.address ?? "",
          city: city,
          state: state,
          tags: [],
          notes: "",
          externalLink: place.externalLink,
          lat: place.latitude,
          lng: place.longitude,
          isFavorite: false,
          applePlaceResolved: true,
          applePlaceResolvedAt: Date(),
          applePlaceName: place.name,
          applePlaceAddress: place.address,
          ratingAverage: 0,
          ratingCount: 0,
          ratingLastVisitedAt: nil
        )
      }
      
      await MainActor.run {
        restaurants = restaurantsFromPlaces
        extractCategories()
        applyFilters()
        isLoading = false
      }
    } catch {
      await MainActor.run {
        errorMessage = "Erro ao buscar restaurantes em \(city): \(error.localizedDescription)"
        isLoading = false
      }
    }
  }

  func toggleFavorite(for restaurant: Restaurant) {
    do {
      let newFavoriteStatus = !restaurant.isFavorite
      try restaurantRepository.setFavorite(id: restaurant.id, isFavorite: newFavoriteStatus)
      // Refresh the list
      if let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
        var updated = restaurant
        updated.isFavorite = newFavoriteStatus
        restaurants[index] = updated
      }
      applyFilters()
    } catch {
      errorMessage = "Erro ao atualizar favorito"
    }
  }

  // MARK: - Private Methods

  private func extractCategories() {
    let allCategories = Set(restaurants.map { $0.category })
    categories = allCategories.sorted()
  }

  private func applyFilters() {
    var result = restaurants

    // Filter by search text
    if !searchText.isEmpty {
      let lowercased = searchText.lowercased()
      result = result.filter { restaurant in
        restaurant.name.lowercased().contains(lowercased) ||
        restaurant.category.lowercased().contains(lowercased) ||
        restaurant.tags.contains { $0.lowercased().contains(lowercased) }
      }
    }

    // Filter by category
    if let category = selectedCategory {
      result = result.filter { $0.category == category }
    }

    // Sort by name
    result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

    filteredRestaurants = result
  }

  /// Retorna restaurantes agrupados por categoria
  func groupedByCategory() -> [(category: String, restaurants: [Restaurant])] {
    let grouped = Dictionary(grouping: filteredRestaurants) { $0.category }
    return grouped
      .map { (category: $0.key, restaurants: $0.value) }
      .sorted { $0.category < $1.category }
  }
}

