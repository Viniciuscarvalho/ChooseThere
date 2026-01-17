//
//  DistanceBracket.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-17.
//

import Foundation

// MARK: - DistanceBracket

/// Faixas de distância para agrupamento de resultados
enum DistanceBracket: CaseIterable, Hashable {
  case veryClose    // < 1km
  case close        // 1-3km
  case medium       // 3-5km
  case far          // > 5km

  var displayName: String {
    switch self {
    case .veryClose: return "Muito perto"
    case .close: return "Perto"
    case .medium: return "Média distância"
    case .far: return "Mais distante"
    }
  }

  var range: ClosedRange<Double> {
    switch self {
    case .veryClose: return 0...0.999
    case .close: return 1...2.999
    case .medium: return 3...4.999
    case .far: return 5...Double.infinity
    }
  }

  func contains(distanceKm: Double) -> Bool {
    range.contains(distanceKm)
  }
}
