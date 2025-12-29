//
//  PreferencesViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import Observation
import CoreLocation

@MainActor
@Observable
final class PreferencesViewModel {
  // MARK: - State

  private(set) var availableTags: [String] = []
  var selectedTags: Set<String> = []
  var avoidTags: Set<String> = []
  var selectedRadius: Int? = nil
  var selectedPriceTier: PriceTier? = nil
  var ratingPriority: RatingPriority = .none

  // Session state
  private(set) var drawnRestaurantIds: Set<String> = []
  private(set) var reRollCount: Int = 0
  let maxReRolls = 3

  var canReRoll: Bool { reRollCount < maxReRolls }

  // MARK: - Dependencies

  private let restaurantRepository: any RestaurantRepository
  private let smartRoulette: SmartRouletteProtocol

  init(
    restaurantRepository: any RestaurantRepository,
    visitRepository: (any VisitRepository)? = nil,
    smartRoulette: SmartRouletteProtocol? = nil
  ) {
    self.restaurantRepository = restaurantRepository
    
    // Criar SmartRouletteService se não fornecido
    if let provided = smartRoulette {
      self.smartRoulette = provided
    } else if let visitRepo = visitRepository {
      // Usar visitRepository fornecido para criar SmartRouletteService com anti-repetição
      let recentHistory = RecentHistoryService(visitRepository: visitRepo)
      self.smartRoulette = SmartRouletteService(recentHistoryProvider: recentHistory)
    } else {
      // Fallback: criar SmartRouletteService sem histórico (comportamento antigo)
      // Usa um mock RecentHistoryProvider que sempre retorna vazio
      let mockHistory = MockRecentHistoryProvider()
      self.smartRoulette = SmartRouletteService(recentHistoryProvider: mockHistory)
    }
  }

  // MARK: - Actions

  func loadTags() {
    do {
      let restaurants = try restaurantRepository.fetchAll()
      let allTags = restaurants.flatMap { $0.tags }
      availableTags = Array(Set(allTags)).sorted()
    } catch {
      availableTags = []
    }
  }

  func toggleTag(_ tag: String) {
    if selectedTags.contains(tag) {
      selectedTags.remove(tag)
    } else {
      selectedTags.insert(tag)
    }
  }

  func toggleAvoidTag(_ tag: String) {
    if avoidTags.contains(tag) {
      avoidTags.remove(tag)
    } else {
      avoidTags.insert(tag)
    }
  }

  func buildContext(userLocation: CLLocationCoordinate2D? = nil) -> PreferenceContext {
    PreferenceContext(
      desiredTags: selectedTags,
      avoidTags: avoidTags,
      radiusKm: selectedRadius,
      priceTier: selectedPriceTier,
      userLocation: userLocation,
      ratingPriority: ratingPriority
    )
  }

  /// Returns a restaurant id, or nil if none found
  func draw(userLocation: CLLocationCoordinate2D? = nil) -> String? {
    do {
      var restaurants = try restaurantRepository.fetchAll()
      
      // Filtrar por cidade selecionada se não for "Any City"
      if let cityKey = AppSettingsStorage.selectedCityKey,
         let parsed = AppSettingsStorage.parseSelectedCity() {
        restaurants = restaurants.filter { restaurant in
          restaurant.city.lowercased() == parsed.city.lowercased() &&
          restaurant.state.lowercased() == parsed.state.lowercased()
        }
      }
      
      let context = buildContext(userLocation: userLocation)
      if let picked = smartRoulette.pick(
        from: restaurants,
        context: context,
        sessionExcludes: drawnRestaurantIds
      ) {
        drawnRestaurantIds.insert(picked.id)
        return picked.id
      }
      return nil
    } catch {
      return nil
    }
  }

  func reRoll(userLocation: CLLocationCoordinate2D? = nil) -> String? {
    guard canReRoll else { return nil }
    reRollCount += 1
    return draw(userLocation: userLocation)
  }

  func resetSession() {
    drawnRestaurantIds.removeAll()
    reRollCount = 0
  }
}

// MARK: - Mock RecentHistoryProvider

/// Mock que sempre retorna vazio (para compatibilidade quando VisitRepository não está disponível)
private final class MockRecentHistoryProvider: RecentHistoryProviding {
  func recentRestaurantIDs(limit: Int) throws -> [String] {
    return []
  }
}



