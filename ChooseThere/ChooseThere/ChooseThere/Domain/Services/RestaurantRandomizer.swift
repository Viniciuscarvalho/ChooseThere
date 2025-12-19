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
  
  /// Rating mínimo para ser considerado "bem avaliado"
  private let minHighRating: Double = 4.0

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
      
      // Rating filter (modo "only" - apenas bem avaliados)
      if context.ratingPriority == .only {
        // Requer pelo menos 1 avaliação e média >= 4.0
        if r.ratingCount == 0 || r.ratingAverage < minHighRating {
          return false
        }
      }

      return true
    }

    guard !candidates.isEmpty else { return nil }

    var gen = rng
    
    // Aplicar priorização por rating (modo "prefer")
    if context.ratingPriority == .prefer {
      return pickWithRatingPriority(from: candidates, using: &gen)
    }
    
    return candidates.randomElement(using: &gen)
  }
  
  /// Seleciona com maior probabilidade para restaurantes bem avaliados
  /// Restaurantes com rating >= 4.0 têm 3x mais chance de serem escolhidos
  private func pickWithRatingPriority(
    from candidates: [Restaurant],
    using gen: inout RandomNumberGenerator
  ) -> Restaurant? {
    // Criar pesos baseados no rating
    let weights: [Double] = candidates.map { r in
      if r.ratingCount > 0 && r.ratingAverage >= minHighRating {
        return 3.0 // 3x mais chance para bem avaliados
      } else if r.ratingCount > 0 {
        return 1.5 // 1.5x para avaliados mas não top
      } else {
        return 1.0 // Peso padrão para não avaliados
      }
    }
    
    let totalWeight = weights.reduce(0, +)
    let randomValue = Double.random(in: 0..<totalWeight, using: &gen)
    
    var cumulative = 0.0
    for (index, weight) in weights.enumerated() {
      cumulative += weight
      if randomValue < cumulative {
        return candidates[index]
      }
    }
    
    // Fallback
    return candidates.last
  }
}



