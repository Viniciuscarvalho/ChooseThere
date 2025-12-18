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

  // Session state
  private(set) var drawnRestaurantIds: Set<String> = []
  private(set) var reRollCount: Int = 0
  let maxReRolls = 3

  var canReRoll: Bool { reRollCount < maxReRolls }

  // MARK: - Dependencies

  private let restaurantRepository: any RestaurantRepository
  private let randomizer: any RestaurantRandomizerProtocol

  init(
    restaurantRepository: any RestaurantRepository,
    randomizer: any RestaurantRandomizerProtocol = RestaurantRandomizer()
  ) {
    self.restaurantRepository = restaurantRepository
    self.randomizer = randomizer
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
      userLocation: userLocation
    )
  }

  /// Returns a restaurant id, or nil if none found
  func draw(userLocation: CLLocationCoordinate2D? = nil) -> String? {
    do {
      let restaurants = try restaurantRepository.fetchAll()
      let context = buildContext(userLocation: userLocation)
      if let picked = randomizer.pick(
        from: restaurants,
        context: context,
        excludeRestaurantIDs: drawnRestaurantIds
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


