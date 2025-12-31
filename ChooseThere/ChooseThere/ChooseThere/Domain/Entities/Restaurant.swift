//
//  Restaurant.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

struct Restaurant: Identifiable, Equatable, Hashable {
  let id: String
  var name: String
  var category: String
  var address: String
  var city: String
  var state: String
  var tags: [String]
  var notes: String
  var externalLink: URL?
  var lat: Double
  var lng: Double
  var isFavorite: Bool
  
  // MARK: - Apple Maps Location Enrichment
  
  /// Indica se a localização foi resolvida/validada via Apple Maps
  var applePlaceResolved: Bool
  /// Data da última resolução via Apple Maps
  var applePlaceResolvedAt: Date?
  /// Nome normalizado retornado pelo Apple Maps
  var applePlaceName: String?
  /// Endereço normalizado retornado pelo Apple Maps
  var applePlaceAddress: String?
  
  // MARK: - Internal Rating (Snapshot)
  
  /// Média de rating (0–5) baseada nas avaliações do usuário
  var ratingAverage: Double
  /// Quantidade de avaliações feitas pelo usuário
  var ratingCount: Int
  /// Data da última visita avaliada
  var ratingLastVisitedAt: Date?
  
  // MARK: - External Links (Manual/Curated)
  
  /// URL do restaurante no TripAdvisor (página exata)
  var tripAdvisorURL: URL?
  /// URL do restaurante no iFood (loja/cardápio)
  var iFoodURL: URL?
  /// URL do 99 ou link de corrida (opcional; fallback para rota no Maps)
  var ride99URL: URL?
  /// URL de imagem do restaurante (curada manualmente, maior prioridade)
  var imageURL: URL?
  
  // MARK: - Computed Properties
  
  /// Indica se o restaurante tem avaliações
  var hasRatings: Bool {
    ratingCount > 0
  }
  
  /// Indica se o restaurante é considerado "bem avaliado" (média >= 4 com pelo menos 1 avaliação)
  var isHighlyRated: Bool {
    ratingCount > 0 && ratingAverage >= 4.0
  }
  
  /// Indica se o restaurante tem pelo menos um link externo cadastrado
  var hasExternalLinks: Bool {
    tripAdvisorURL != nil || iFoodURL != nil || ride99URL != nil
  }
  
  // MARK: - Initializer with Defaults
  
  init(
    id: String,
    name: String,
    category: String,
    address: String,
    city: String,
    state: String,
    tags: [String],
    notes: String,
    externalLink: URL? = nil,
    lat: Double,
    lng: Double,
    isFavorite: Bool = false,
    applePlaceResolved: Bool = false,
    applePlaceResolvedAt: Date? = nil,
    applePlaceName: String? = nil,
    applePlaceAddress: String? = nil,
    ratingAverage: Double = 0,
    ratingCount: Int = 0,
    ratingLastVisitedAt: Date? = nil,
    tripAdvisorURL: URL? = nil,
    iFoodURL: URL? = nil,
    ride99URL: URL? = nil,
    imageURL: URL? = nil
  ) {
    self.id = id
    self.name = name
    self.category = category
    self.address = address
    self.city = city
    self.state = state
    self.tags = tags
    self.notes = notes
    self.externalLink = externalLink
    self.lat = lat
    self.lng = lng
    self.isFavorite = isFavorite
    self.applePlaceResolved = applePlaceResolved
    self.applePlaceResolvedAt = applePlaceResolvedAt
    self.applePlaceName = applePlaceName
    self.applePlaceAddress = applePlaceAddress
    self.ratingAverage = ratingAverage
    self.ratingCount = ratingCount
    self.ratingLastVisitedAt = ratingLastVisitedAt
    self.tripAdvisorURL = tripAdvisorURL
    self.iFoodURL = iFoodURL
    self.ride99URL = ride99URL
    self.imageURL = imageURL
  }
}

// MARK: - Mapping

extension Restaurant {
  init(from model: RestaurantModel) {
    self.id = model.id
    self.name = model.name
    self.category = model.category
    self.address = model.address
    self.city = model.city
    self.state = model.state
    self.tags = model.tags
    self.notes = model.notes
    self.externalLink = model.externalLink.flatMap { URL(string: $0) }
    self.lat = model.lat
    self.lng = model.lng
    self.isFavorite = model.isFavorite
    self.applePlaceResolved = model.applePlaceResolved
    self.applePlaceResolvedAt = model.applePlaceResolvedAt
    self.applePlaceName = model.applePlaceName
    self.applePlaceAddress = model.applePlaceAddress
    self.ratingAverage = model.ratingAverage
    self.ratingCount = model.ratingCount
    self.ratingLastVisitedAt = model.ratingLastVisitedAt
    
    // External Links
    self.tripAdvisorURL = model.tripAdvisorURL.flatMap { URL(string: $0) }
    self.iFoodURL = model.iFoodURL.flatMap { URL(string: $0) }
    self.ride99URL = model.ride99URL.flatMap { URL(string: $0) }
    self.imageURL = model.imageURL.flatMap { URL(string: $0) }
  }
}



