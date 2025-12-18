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

  // MARK: - Init

  init(restaurantRepository: RestaurantRepository) {
    self.restaurantRepository = restaurantRepository
  }

  // MARK: - Public Methods

  func loadRestaurants() {
    isLoading = true
    errorMessage = nil

    do {
      restaurants = try restaurantRepository.fetchAll()
      extractCategories()
      applyFilters()
      isLoading = false
    } catch {
      errorMessage = "Erro ao carregar restaurantes: \(error.localizedDescription)"
      isLoading = false
    }
  }

  func toggleFavorite(for restaurant: Restaurant) {
    do {
      let newFavoriteStatus = !restaurant.isFavorite
      try restaurantRepository.setFavorite(id: restaurant.id, isFavorite: newFavoriteStatus)
      // Refresh the list
      if let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
        restaurants[index] = Restaurant(
          id: restaurant.id,
          name: restaurant.name,
          category: restaurant.category,
          address: restaurant.address,
          city: restaurant.city,
          state: restaurant.state,
          tags: restaurant.tags,
          notes: restaurant.notes,
          externalLink: restaurant.externalLink,
          lat: restaurant.lat,
          lng: restaurant.lng,
          isFavorite: newFavoriteStatus
        )
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

