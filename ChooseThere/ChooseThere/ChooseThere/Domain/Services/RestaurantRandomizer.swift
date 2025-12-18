//
//  RestaurantRandomizer.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import CoreLocation

/// Pure-domain service for picking a random restaurant from a filtered set
protocol RestaurantRandomizerProtocol {
  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant?
}

struct RestaurantRandomizer: RestaurantRandomizerProtocol {
  /// Injectable random number generator (determinism for tests)
  private var rng: RandomNumberGenerator

  init(rng: RandomNumberGenerator = SystemRandomNumberGenerator()) {
    self.rng = rng
  }

  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant? {
    let candidates = restaurants.filter { r in
      // Exclude already drawn restaurants
      guard !excludeRestaurantIDs.contains(r.id) else { return false }

      // Desired tags: at least one match (if specified)
      if !context.desiredTags.isEmpty {
        let restaurantTags = Set(r.tags.map { $0.lowercased() })
        let desired = context.desiredTags.map { $0.lowercased() }
        if !desired.contains(where: { restaurantTags.contains($0) }) {
          return false
        }
      }

      // Avoid tags: none should match
      if !context.avoidTags.isEmpty {
        let restaurantTags = Set(r.tags.map { $0.lowercased() })
        let avoid = context.avoidTags.map { $0.lowercased() }
        if avoid.contains(where: { restaurantTags.contains($0) }) {
          return false
        }
      }

      // Radius filter (requires user location and valid lat/lng)
      if let radius = context.radiusKm, let userLoc = context.userLocation {
        let userCL = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let restaurantCL = CLLocation(latitude: r.lat, longitude: r.lng)
        let distanceKm = userCL.distance(from: restaurantCL) / 1000
        if distanceKm > Double(radius) {
          return false
        }
      }

      // Price tier filter (optional; V1 JSON may not have price)
      // Skipped if price not in model

      return true
    }

    guard !candidates.isEmpty else { return nil }

    var gen = rng
    return candidates.randomElement(using: &gen)
  }
}

