//
//  RestaurantRatingAggregator.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import Foundation
import OSLog

/// Resultado da agregação de rating de um restaurante
struct RatingAggregation: Sendable, Equatable {
  /// Média do rating (1–5). Retorna 0 se não há avaliações
  let average: Double
  /// Quantidade de avaliações
  let count: Int
  /// Data da última visita avaliada
  let lastVisitedAt: Date?
  
  /// Indica se há avaliações
  var hasRatings: Bool {
    count > 0
  }
  
  /// Agregação vazia (sem avaliações)
  static let empty = RatingAggregation(average: 0, count: 0, lastVisitedAt: nil)
}

/// Serviço para agregar ratings de restaurantes a partir de VisitModel
@MainActor
final class RestaurantRatingAggregator {
  private let visitRepository: VisitRepository
  private let restaurantRepository: RestaurantRepository
  private let logger = Logger(subsystem: "ChooseThere", category: "RatingAggregator")
  
  init(visitRepository: VisitRepository, restaurantRepository: RestaurantRepository) {
    self.visitRepository = visitRepository
    self.restaurantRepository = restaurantRepository
  }
  
  // MARK: - Aggregation
  
  /// Calcula a agregação de rating para um restaurante
  /// - Parameter restaurantId: ID do restaurante
  /// - Returns: Agregação com média, contagem e última visita
  func compute(for restaurantId: String) -> RatingAggregation {
    do {
      let visits = try visitRepository.fetchVisits(for: restaurantId)
      
      guard !visits.isEmpty else {
        return .empty
      }
      
      // Calcular média
      let totalRating = visits.reduce(0) { $0 + $1.rating }
      let average = Double(totalRating) / Double(visits.count)
      
      // Encontrar data mais recente
      let lastVisitedAt = visits.map { $0.dateVisited }.max()
      
      return RatingAggregation(
        average: average,
        count: visits.count,
        lastVisitedAt: lastVisitedAt
      )
    } catch {
      logger.error("Failed to compute rating for \(restaurantId): \(error.localizedDescription)")
      return .empty
    }
  }
  
  // MARK: - Persist Snapshot
  
  /// Calcula e persiste o snapshot de rating no RestaurantModel
  /// - Parameter restaurantId: ID do restaurante
  /// - Returns: A agregação calculada
  @discardableResult
  func updateSnapshot(for restaurantId: String) -> RatingAggregation {
    let aggregation = compute(for: restaurantId)
    
    do {
      try restaurantRepository.updateRatingSnapshot(
        id: restaurantId,
        average: aggregation.average,
        count: aggregation.count,
        lastVisitedAt: aggregation.lastVisitedAt
      )
      
      logger.info("Updated rating snapshot for restaurant \(restaurantId): avg=\(aggregation.average), count=\(aggregation.count)")
    } catch {
      logger.error("Failed to persist rating snapshot: \(error.localizedDescription)")
    }
    
    return aggregation
  }
  
  // MARK: - Batch Update
  
  /// Recalcula e persiste ratings para todos os restaurantes que têm visitas
  /// Útil para migração/sincronização inicial
  func updateAllSnapshots() {
    do {
      let allVisits = try visitRepository.fetchAll()
      let restaurantIds = Set(allVisits.map { $0.restaurantId })
      
      logger.info("Updating rating snapshots for \(restaurantIds.count) restaurants")
      
      for restaurantId in restaurantIds {
        updateSnapshot(for: restaurantId)
      }
      
      logger.info("Batch rating update completed")
    } catch {
      logger.error("Failed to fetch visits for batch update: \(error.localizedDescription)")
    }
  }
}

