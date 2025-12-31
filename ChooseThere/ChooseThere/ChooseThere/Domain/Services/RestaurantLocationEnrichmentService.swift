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
  
  /// Resolve múltiplos restaurantes com throttling e suporte a cancelamento
  /// - Parameters:
  ///   - limit: Número máximo de restaurantes a processar (nil = todos)
  ///   - concurrency: Número de resoluções simultâneas
  ///   - onProgress: Callback opcional para reportar progresso
  /// - Returns: Estatísticas do batch (inclui flag cancelled se interrompido)
  func resolveUnresolved(
    limit: Int? = nil,
    concurrency: Int = 2,
    onProgress: ((BatchProgress) -> Void)? = nil
  ) async -> BatchResult {
    var successCount = 0
    var failedCount = 0
    var skippedCount = 0
    
    do {
      // Verificar cancelamento antes de iniciar
      try Task.checkCancellation()
      
      let unresolved = try restaurantRepository.fetchUnresolvedLocations()
      let batch = limit != nil ? Array(unresolved.prefix(limit!)) : unresolved
      let totalCount = batch.count
      var processedCount = 0
      
      logger.info("Starting batch resolve for \(totalCount) restaurants")
      
      // Reportar progresso inicial
      onProgress?(BatchProgress(processed: 0, total: totalCount, current: nil))
      
      // Processar em grupos para limitar concorrência
      for chunk in batch.chunked(into: concurrency) {
        // Verificar cancelamento antes de cada chunk
        if Task.isCancelled {
          logger.info("Batch cancelled by user")
          return .cancelled(success: successCount, failed: failedCount, skipped: skippedCount)
        }
        
        await withTaskGroup(of: (name: String, result: LocationEnrichmentResult).self) { group in
          for restaurant in chunk {
            // Usar addTaskUnlessCancelled para respeitar cancelamento
            let added = group.addTaskUnlessCancelled {
              let result = await self.resolve(restaurantId: restaurant.id)
              return (name: restaurant.name, result: result)
            }
            
            // Se não conseguiu adicionar (cancelado), sair do loop
            if !added { break }
          }
          
          for await item in group {
            processedCount += 1
            let name = item.name
            let result = item.result
            
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
        
        // Verificar cancelamento após processar chunk
        if Task.isCancelled {
          logger.info("Batch cancelled after chunk processing")
          return .cancelled(success: successCount, failed: failedCount, skipped: skippedCount)
        }
        
        // Pequena pausa entre chunks para não sobrecarregar o MapKit
        // Usar do/catch para parar se cancelado durante o sleep
        do {
          try await Task.sleep(for: .milliseconds(500))
        } catch {
          // CancellationError durante sleep - retornar como cancelado
          logger.info("Batch cancelled during throttle pause")
          return .cancelled(success: successCount, failed: failedCount, skipped: skippedCount)
        }
      }
      
      logger.info("Batch complete: \(successCount) success, \(failedCount) failed, \(skippedCount) skipped")
      
    } catch is CancellationError {
      logger.info("Batch cancelled")
      return .cancelled(success: successCount, failed: failedCount, skipped: skippedCount)
    } catch {
      logger.error("Batch resolve failed: \(error.localizedDescription)")
    }
    
    return BatchResult(success: successCount, failed: failedCount, skipped: skippedCount, cancelled: false)
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
  let cancelled: Bool
  
  var total: Int { success + failed + skipped }
  
  /// Cria um resultado vazio (para casos de erro ou cancelamento precoce)
  static var empty: BatchResult {
    BatchResult(success: 0, failed: 0, skipped: 0, cancelled: false)
  }
  
  /// Cria um resultado de cancelamento
  static func cancelled(success: Int, failed: Int, skipped: Int) -> BatchResult {
    BatchResult(success: success, failed: failed, skipped: skipped, cancelled: true)
  }
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

