//
//  RouletteViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class RouletteViewModel {
  // MARK: - State

  enum Phase: Equatable {
    case idle
    case spinning
    case finished(restaurantId: String)
    case noResults
  }

  private(set) var phase: Phase = .idle
  private(set) var displayedNames: [String] = []
  private(set) var currentIndex: Int = 0
  private(set) var reRollCount: Int = 0
  let maxReRolls = 3

  var canReRoll: Bool { reRollCount < maxReRolls }

  // MARK: - Dependencies

  private let restaurantRepository: any RestaurantRepository
  private let randomizer: any RestaurantRandomizerProtocol
  private var drawnIds: Set<String> = []
  private var allRestaurants: [Restaurant] = []

  init(
    restaurantRepository: any RestaurantRepository,
    randomizer: any RestaurantRandomizerProtocol = RestaurantRandomizer()
  ) {
    self.restaurantRepository = restaurantRepository
    self.randomizer = randomizer
  }

  // MARK: - Actions

  func loadAndSpin(pendingId: String?) {
    do {
      allRestaurants = try restaurantRepository.fetchAll()
    } catch {
      allRestaurants = []
    }

    // If we already have a pending id from preferences, use it
    if let pending = pendingId, !pending.isEmpty {
      drawnIds.insert(pending)
      startSpinAnimation(finalId: pending)
    } else {
      spinNew()
    }
  }

  func spinNew() {
    guard !allRestaurants.isEmpty else {
      phase = .noResults
      return
    }
    // pick a random one
    let context = PreferenceContext(
      desiredTags: [],
      avoidTags: [],
      radiusKm: nil,
      priceTier: nil,
      userLocation: nil
    )
    if let picked = randomizer.pick(from: allRestaurants, context: context, excludeRestaurantIDs: drawnIds) {
      drawnIds.insert(picked.id)
      startSpinAnimation(finalId: picked.id)
    } else {
      phase = .noResults
    }
  }

  func reRoll() {
    guard canReRoll else { return }
    reRollCount += 1
    spinNew()
  }

  // MARK: - Animation

  private func startSpinAnimation(finalId: String) {
    phase = .spinning

    // Generate shuffled names for animation
    let names = allRestaurants.map { $0.name }.shuffled()
    displayedNames = Array(names.prefix(8)) + [allRestaurants.first { $0.id == finalId }?.name ?? ""]
    currentIndex = 0

    animateNextCard(finalId: finalId)
  }

  private func animateNextCard(finalId: String) {
    guard currentIndex < displayedNames.count - 1 else {
      // Finished
      phase = .finished(restaurantId: finalId)
      return
    }
    // Exponential slowdown
    let delay = 0.08 + Double(currentIndex) * 0.04
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(delay))
      currentIndex += 1
      animateNextCard(finalId: finalId)
    }
  }
}

