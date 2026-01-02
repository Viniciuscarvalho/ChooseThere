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
  
  /// Sorteia com fallback de rating.only → .prefer quando não há candidatos com rating interno.
  /// Útil para Apple Maps onde candidatos não possuem ratingCount.
  func pickWithRatingFallback(
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

    // Determinar estratégia de seleção
    let hasLearnedPrefs = context.learnedPreferences?.hasLearnedPreferences ?? false
    let hasRatingPriority = context.ratingPriority == .prefer

    if hasLearnedPrefs && hasRatingPriority {
      // Combinar pesos de match + rating
      return pickWithCombinedWeights(from: candidates, context: context, using: &gen)
    } else if hasLearnedPrefs {
      // Apenas pesos de match (sem rating priority)
      return pickWithMatchWeights(from: candidates, context: context, using: &gen)
    } else if hasRatingPriority {
      // Apenas pesos de rating (comportamento existente)
      return pickWithRatingPriority(from: candidates, using: &gen)
    } else {
      // Sorteio uniforme (fallback)
      return candidates.randomElement(using: &gen)
    }
  }

  // MARK: - Weighted Selection Methods

  /// Seleciona com maior probabilidade para restaurantes bem avaliados
  /// Restaurantes com rating >= 4.0 têm 3x mais chance de serem escolhidos
  private func pickWithRatingPriority(
    from candidates: [Restaurant],
    using gen: inout RandomNumberGenerator
  ) -> Restaurant? {
    let weights = calculateRatingWeights(for: candidates)
    return pickWeighted(from: candidates, weights: weights, using: &gen)
  }

  /// Seleciona com ponderação baseada em preferências aprendidas (match de tags/categoria)
  private func pickWithMatchWeights(
    from candidates: [Restaurant],
    context: PreferenceContext,
    using gen: inout RandomNumberGenerator
  ) -> Restaurant? {
    guard let prefs = context.learnedPreferences else {
      return candidates.randomElement(using: &gen)
    }

    let weights = candidates.map { prefs.sortingWeight(tags: $0.tags, category: $0.category) }
    return pickWeighted(from: candidates, weights: weights, using: &gen)
  }

  /// Seleciona combinando pesos de match e rating
  /// Fórmula: finalWeight = matchWeight * ratingMultiplier
  private func pickWithCombinedWeights(
    from candidates: [Restaurant],
    context: PreferenceContext,
    using gen: inout RandomNumberGenerator
  ) -> Restaurant? {
    guard let prefs = context.learnedPreferences else {
      return pickWithRatingPriority(from: candidates, using: &gen)
    }

    let matchWeights = candidates.map { prefs.sortingWeight(tags: $0.tags, category: $0.category) }
    let ratingWeights = calculateRatingWeights(for: candidates)

    // Combinar: matchWeight * ratingMultiplier (normalizado)
    let combinedWeights = zip(matchWeights, ratingWeights).map { $0 * $1 }

    return pickWeighted(from: candidates, weights: combinedWeights, using: &gen)
  }

  // MARK: - Helper Methods

  /// Calcula pesos baseados no rating
  private func calculateRatingWeights(for candidates: [Restaurant]) -> [Double] {
    candidates.map { r in
      if r.ratingCount > 0 && r.ratingAverage >= minHighRating {
        return 3.0 // 3x mais chance para bem avaliados
      } else if r.ratingCount > 0 {
        return 1.5 // 1.5x para avaliados mas não top
      } else {
        return 1.0 // Peso padrão para não avaliados
      }
    }
  }

  /// Realiza seleção ponderada genérica
  private func pickWeighted(
    from candidates: [Restaurant],
    weights: [Double],
    using gen: inout RandomNumberGenerator
  ) -> Restaurant? {
    guard !candidates.isEmpty, !weights.isEmpty else { return nil }

    let totalWeight = weights.reduce(0, +)
    guard totalWeight > 0 else { return candidates.randomElement(using: &gen) }

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
  
  // MARK: - Rating Fallback (para Apple Maps)
  
  /// Tenta pick com o contexto atual; se ratingPriority==.only e retornar nil,
  /// relaxa para .prefer e tenta novamente.
  func pickWithRatingFallback(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant? {
    // Primeiro tenta com o contexto original
    if let result = pick(from: restaurants, context: context, excludeRestaurantIDs: excludeRestaurantIDs) {
      return result
    }
    
    // Se era .only e não encontrou nada, relaxar para .prefer
    if context.ratingPriority == .only {
      var relaxedContext = context
      relaxedContext.ratingPriority = .prefer
      return pick(from: restaurants, context: relaxedContext, excludeRestaurantIDs: excludeRestaurantIDs)
    }
    
    return nil
  }
}

