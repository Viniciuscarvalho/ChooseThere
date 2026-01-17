//
//  NearbyDisplayable.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-17.
//

import Foundation
import SwiftUI

// MARK: - ExternalAction

/// Ações externas disponíveis para restaurantes (links para apps/sites externos)
enum ExternalAction: String, CaseIterable, Hashable {
  case tripAdvisor
  case ifood
  case ride99
  case maps

  var displayName: String {
    switch self {
    case .tripAdvisor: return "TripAdvisor"
    case .ifood: return "iFood"
    case .ride99: return "99"
    case .maps: return "Maps"
    }
  }

  var icon: String {
    switch self {
    case .tripAdvisor: return "star.circle.fill"
    case .ifood: return "bag.fill"
    case .ride99: return "car.fill"
    case .maps: return "map.fill"
    }
  }

  var accessibilityLabel: String {
    switch self {
    case .tripAdvisor: return "Ver no TripAdvisor"
    case .ifood: return "Pedir no iFood"
    case .ride99: return "Ir de 99"
    case .maps: return "Abrir no Maps"
    }
  }
}

// MARK: - DataSource

/// Representa a fonte de dados de um restaurante
enum DataSource {
  case localBase
  case appleMaps

  var displayName: String {
    switch self {
    case .localBase: return "Minha Base"
    case .appleMaps: return "Apple Maps"
    }
  }

  var badgeColor: Color {
    switch self {
    case .localBase: return AppColors.primary.opacity(0.9)
    case .appleMaps: return AppColors.accent.opacity(0.9)
    }
  }

  var badgeIcon: String {
    switch self {
    case .localBase: return "externaldrive.fill"
    case .appleMaps: return "map.fill"
    }
  }

  var tooltipText: String {
    switch self {
    case .localBase:
      return "Minha Base: restaurantes da curadoria local de São Paulo"
    case .appleMaps:
      return "Apple Maps: estabelecimentos do banco de dados Apple Maps"
    }
  }
}

// MARK: - NearbyDisplayable

/// Protocol para unificar Restaurant e NearbyPlace em UI comum
protocol NearbyDisplayable {
  /// ID único do item
  var displayId: String { get }

  /// Nome do restaurante/estabelecimento
  var displayName: String { get }

  /// Categoria (ex: "Japonês", "Italiana")
  var displayCategory: String { get }

  /// URL da imagem (opcional)
  var displayImageURL: URL? { get }

  /// Rating/avaliação (0-5, opcional)
  var displayRating: Double? { get }

  /// Endereço formatado (opcional)
  var displayAddress: String? { get }

  /// Distância em quilômetros (opcional)
  var distanceKm: Double? { get }

  /// Fonte de dados (Minha Base ou Apple Maps)
  var dataSource: DataSource { get }

  /// Ações externas disponíveis (TripAdvisor, iFood, 99, Maps)
  var externalActions: [ExternalAction] { get }
}

// MARK: - Restaurant Extension

extension Restaurant: NearbyDisplayable {
  var displayId: String { id }

  var displayName: String { name }

  var displayCategory: String { category }

  var displayImageURL: URL? {
    guard let url = imageURL else { return nil }
    // Verifica se é uma URL válida (não vazia)
    return url.absoluteString.isEmpty ? nil : url
  }

  var displayRating: Double? {
    hasRatings ? ratingAverage : nil
  }

  var displayAddress: String? { address }

  var dataSource: DataSource { .localBase }

  var externalActions: [ExternalAction] {
    var actions: [ExternalAction] = []
    if tripAdvisorURL != nil { actions.append(.tripAdvisor) }
    if iFoodURL != nil { actions.append(.ifood) }
    if ride99URL != nil { actions.append(.ride99) }
    actions.append(.maps) // Sempre disponível
    return actions
  }
}

// MARK: - NearbyPlace Extension

extension NearbyPlace: NearbyDisplayable {
  var displayId: String { id }

  var displayName: String { name }

  var displayCategory: String { categoryHint ?? "Restaurante" }

  var displayImageURL: URL? { nil } // Apple Maps não fornece imagens

  var displayRating: Double? { nil } // Apple Maps não fornece ratings

  var displayAddress: String? { address }

  var dataSource: DataSource { .appleMaps }

  var externalActions: [ExternalAction] {
    [.maps] // Apple Maps só tem opção de abrir no Maps
  }
}
