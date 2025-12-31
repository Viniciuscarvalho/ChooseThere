//
//  RestaurantModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData

@Model
final class RestaurantModel {
  @Attribute(.unique)
  var id: String

  var name: String
  var category: String
  var address: String
  var city: String
  var state: String
  var tags: [String]
  var notes: String
  var externalLink: String?
  var lat: Double
  var lng: Double
  var isFavorite: Bool = false
  
  // MARK: - Apple Maps Location Enrichment
  
  /// Indica se a localização foi resolvida/validada via Apple Maps (MKLocalSearch)
  var applePlaceResolved: Bool = false
  /// Data da última resolução via Apple Maps
  var applePlaceResolvedAt: Date? = nil
  /// Nome normalizado retornado pelo Apple Maps
  var applePlaceName: String? = nil
  /// Endereço normalizado retornado pelo Apple Maps
  var applePlaceAddress: String? = nil
  
  // MARK: - Internal Rating (Snapshot from VisitModel)
  
  /// Média de rating (0–5) baseada nas avaliações do usuário
  var ratingAverage: Double = 0.0
  /// Quantidade de avaliações feitas pelo usuário
  var ratingCount: Int = 0
  /// Data da última visita avaliada
  var ratingLastVisitedAt: Date? = nil
  
  // MARK: - External Links (Manual/Curated)
  
  /// URL do restaurante no TripAdvisor (página exata)
  var tripAdvisorURL: String? = nil
  /// URL do restaurante no iFood (loja/cardápio)
  var iFoodURL: String? = nil
  /// URL do 99 ou link de corrida (opcional; fallback para rota no Maps)
  var ride99URL: String? = nil
  /// URL de imagem do restaurante (curada manualmente, maior prioridade)
  var imageURL: String? = nil

  init(
    id: String,
    name: String,
    category: String,
    address: String,
    city: String,
    state: String,
    tags: [String],
    notes: String,
    externalLink: String?,
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
    tripAdvisorURL: String? = nil,
    iFoodURL: String? = nil,
    ride99URL: String? = nil,
    imageURL: String? = nil
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



