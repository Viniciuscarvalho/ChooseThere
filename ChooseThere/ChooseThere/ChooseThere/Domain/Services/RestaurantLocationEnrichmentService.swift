//
//  RestaurantLocationEnrichmentService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import Foundation
import OSLog

/// Resultado do enriquecimento de localização
enum LocationEnrichmentResult: Sendable {
  case success(lat: Double, lng: Double, name: String?, address: String?)
  case notFound
  case alreadyResolved
  case cacheHit
  case failed(Error)
}

/// Serviço que orquestra o enriquecimento de localização de restaurantes
/// usando PlaceResolver e persistindo resultados via RestaurantRepository
@MainActor
final class RestaurantLocationEnrichmentService {
  private let placeResolver: PlaceResolver
  private let restaurantRepository: RestaurantRepository
  private let logger = Logger(subsystem: "ChooseThere", category: "LocationEnrichment")
  
  /// Janela de cache em segundos (7 dias)
  private let cacheWindowSeconds: TimeInterval = 7 * 24 * 60 * 60
  
  init(placeResolver: PlaceResolver, restaurantRepository: RestaurantRepository) {
    self.placeResolver = placeResolver
    self.restaurantRepository = restaurantRepository
  }
  
  // MARK: - Single Resolve
  
  /// Resolve e atualiza a localização de um restaurante específico
  /// - Parameters:
  ///   - restaurantId: ID do restaurante
  ///   - forceRefresh: Se true, ignora o cache e força nova resolução
  /// - Returns: Resultado do enriquecimento
  func resolve(restaurantId: String, forceRefresh: Bool = false) async -> LocationEnrichmentResult {
    do {
      guard let restaurant = try restaurantRepository.fetch(id: restaurantId) else {
        logger.warning("Restaurant not found: \(restaurantId)")
        return .failed(RestaurantEnrichmentError.restaurantNotFound)
      }
      
      // Verificar cache
      if !forceRefresh, let resolvedAt = restaurant.applePlaceResolvedAt {
        let age = Date().timeIntervalSince(resolvedAt)
        if age < cacheWindowSeconds {
          logger.info("Cache hit for \(restaurant.name)")
          return restaurant.applePlaceResolved ? .alreadyResolved : .cacheHit
        }
      }
      
      // Resolver via PlaceResolver
      let result = try await placeResolver.resolve(
        name: restaurant.name,
        address: restaurant.address,
        city: restaurant.city,
        state: restaurant.state,
        currentLat: restaurant.lat,
        currentLng: restaurant.lng
      )
      
      if let resolved = result {
        // Atualizar com dados resolvidos
        try restaurantRepository.updateApplePlaceData(
          id: restaurantId,
          lat: resolved.latitude,
          lng: resolved.longitude,
          applePlaceName: resolved.normalizedName,
          applePlaceAddress: resolved.normalizedAddress
        )
        
        logger.info("Successfully enriched location for \(restaurant.name)")
        return .success(
          lat: resolved.latitude,
          lng: resolved.longitude,
          name: resolved.normalizedName,
          address: resolved.normalizedAddress
        )
      } else {
        // Marcar como não resolvido (para não tentar novamente imediatamente)
        try restaurantRepository.markApplePlaceUnresolved(id: restaurantId)
        logger.info("Could not resolve location for \(restaurant.name)")
        return .notFound
      }
      
    } catch {
      logger.error("Enrichment failed: \(error.localizedDescription)")
      return .failed(error)
    }
  }
  
  // MARK: - Batch Resolve
  
  /// Resolve múltiplos restaurantes com throttling
  /// - Parameters:
  ///   - limit: Número máximo de restaurantes a processar (nil = todos)
  ///   - concurrency: Número de resoluções simultâneas
  ///   - onProgress: Callback opcional para reportar progresso
  /// - Returns: Estatísticas do batch
  func resolveUnresolved(
    limit: Int? = nil,
    concurrency: Int = 2,
    onProgress: ((BatchProgress) -> Void)? = nil
  ) async -> BatchResult {
    var successCount = 0
    var failedCount = 0
    var skippedCount = 0
    
    do {
      let unresolved = try restaurantRepository.fetchUnresolvedLocations()
      let batch = limit != nil ? Array(unresolved.prefix(limit!)) : unresolved
      let totalCount = batch.count
      var processedCount = 0
      
      logger.info("Starting batch resolve for \(totalCount) restaurants")
      
      // Reportar progresso inicial
      onProgress?(BatchProgress(processed: 0, total: totalCount, current: nil))
      
      // Processar em grupos para limitar concorrência
      for chunk in batch.chunked(into: concurrency) {
        await withTaskGroup(of: (String, String, LocationEnrichmentResult).self) { group in
          for restaurant in chunk {
            group.addTask {
              let result = await self.resolve(restaurantId: restaurant.id)
              return (restaurant.id, restaurant.name, result)
            }
          }
          
          for await (id, name, result) in group {
            processedCount += 1
            
            switch result {
            case .success:
              successCount += 1
            case .alreadyResolved, .cacheHit:
              skippedCount += 1
            case .notFound, .failed:
              failedCount += 1
            }
            
            // Reportar progresso
            onProgress?(BatchProgress(processed: processedCount, total: totalCount, current: name))
          }
        }
        
        // Pequena pausa entre chunks para não sobrecarregar o MapKit
        try? await Task.sleep(for: .milliseconds(500))
      }
      
      logger.info("Batch complete: \(successCount) success, \(failedCount) failed, \(skippedCount) skipped")
      
    } catch {
      logger.error("Batch resolve failed: \(error.localizedDescription)")
    }
    
    return BatchResult(success: successCount, failed: failedCount, skipped: skippedCount)
  }
  
  /// Enriquece todos os restaurantes não resolvidos
  func enrichAll(onProgress: ((BatchProgress) -> Void)? = nil) async -> BatchResult {
    return await resolveUnresolved(limit: nil, concurrency: 2, onProgress: onProgress)
  }
}

// MARK: - Batch Types

/// Progresso do processamento batch
struct BatchProgress: Sendable {
  let processed: Int
  let total: Int
  let current: String?
  
  var percentage: Double {
    guard total > 0 else { return 0 }
    return Double(processed) / Double(total)
  }
  
  var isComplete: Bool {
    processed >= total
  }
}

/// Resultado final do batch
struct BatchResult: Sendable {
  let success: Int
  let failed: Int
  let skipped: Int
  
  var total: Int { success + failed + skipped }
}

// MARK: - Errors

enum RestaurantEnrichmentError: Error, LocalizedError {
  case restaurantNotFound
  
  var errorDescription: String? {
    switch self {
    case .restaurantNotFound:
      return "Restaurante não encontrado"
    }
  }
}

// MARK: - Array Extension

private extension Array {
  /// Divide o array em chunks de tamanho especificado
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}

