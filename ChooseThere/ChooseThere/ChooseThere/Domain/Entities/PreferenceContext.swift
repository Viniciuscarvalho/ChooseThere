//
//  PreferenceContext.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import CoreLocation

/// Captures user preferences for a single draw session
struct PreferenceContext {
  var desiredTags: Set<String>
  var avoidTags: Set<String>
  var radiusKm: Int?
  var priceTier: PriceTier?
  var userLocation: CLLocationCoordinate2D?

  init(
    desiredTags: Set<String> = [],
    avoidTags: Set<String> = [],
    radiusKm: Int? = nil,
    priceTier: PriceTier? = nil,
    userLocation: CLLocationCoordinate2D? = nil
  ) {
    self.desiredTags = desiredTags
    self.avoidTags = avoidTags
    self.radiusKm = radiusKm
    self.priceTier = priceTier
    self.userLocation = userLocation
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

