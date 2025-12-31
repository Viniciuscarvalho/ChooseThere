//
//  RestaurantRepository.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

/// Contract for restaurant data access (Domain layer)
protocol RestaurantRepository {
  /// Fetch all restaurants
  func fetchAll() throws -> [Restaurant]
  /// Fetch a single restaurant by its stable id
  func fetch(id: String) throws -> Restaurant?
  /// Set the favorite status for a restaurant
  func setFavorite(id: String, isFavorite: Bool) throws
  
  // MARK: - Location Enrichment
  
  /// Atualiza os dados de localização resolvida via Apple Maps
  func updateApplePlaceData(
    id: String,
    lat: Double,
    lng: Double,
    applePlaceName: String?,
    applePlaceAddress: String?
  ) throws
  
  /// Marca um restaurante como não resolvido pelo Apple Maps
  func markApplePlaceUnresolved(id: String) throws
  
  // MARK: - Rating Snapshot
  
  /// Atualiza o snapshot de rating interno do restaurante
  func updateRatingSnapshot(
    id: String,
    average: Double,
    count: Int,
    lastVisitedAt: Date?
  ) throws
  
  /// Busca restaurantes que ainda não foram resolvidos via Apple Maps
  func fetchUnresolvedLocations() throws -> [Restaurant]
  
  // MARK: - External Links
  
  /// Atualiza os links externos do restaurante (TripAdvisor, iFood, 99, imagem)
  func updateExternalLinks(
    id: String,
    tripAdvisorURL: URL?,
    iFoodURL: URL?,
    ride99URL: URL?,
    imageURL: URL?
  ) throws
  
  /// Atualiza apenas o site externo (externalLink) do restaurante
  func updateExternalLink(id: String, externalLink: URL?) throws
}



