//
//  PreferenceContext.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import CoreLocation

/// Modo de priorização por rating
enum RatingPriority: Int, CaseIterable, Identifiable {
  case none = 0      // Sem priorização
  case prefer = 1    // Preferir bem avaliados (maior probabilidade)
  case only = 2      // Apenas bem avaliados (filtro mínimo de 4.0)
  
  var id: Int { rawValue }
  
  var label: String {
    switch self {
    case .none: return "Todos"
    case .prefer: return "Preferir avaliados"
    case .only: return "Só top ★4+"
    }
  }
}

/// Captures user preferences for a single draw session
struct PreferenceContext {
  var desiredTags: Set<String>
  var avoidTags: Set<String>
  var radiusKm: Int?
  var priceTier: PriceTier?
  var userLocation: CLLocationCoordinate2D?
  var ratingPriority: RatingPriority

  init(
    desiredTags: Set<String> = [],
    avoidTags: Set<String> = [],
    radiusKm: Int? = nil,
    priceTier: PriceTier? = nil,
    userLocation: CLLocationCoordinate2D? = nil,
    ratingPriority: RatingPriority = .none
  ) {
    self.desiredTags = desiredTags
    self.avoidTags = avoidTags
    self.radiusKm = radiusKm
    self.priceTier = priceTier
    self.userLocation = userLocation
    self.ratingPriority = ratingPriority
  }
}

enum PriceTier: Int, CaseIterable, Identifiable {
  case cheap = 1
  case moderate = 2
  case expensive = 3

  var id: Int { rawValue }

  var symbol: String {
    switch self {
    case .cheap: return "$"
    case .moderate: return "$$"
    case .expensive: return "$$$"
    }
  }
}

