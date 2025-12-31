//
//  LocationEnrichmentManager.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import Foundation
import Observation
import OSLog

/// Manager para orquestrar enriquecimento batch de localização com estado observável
@MainActor
@Observable
final class LocationEnrichmentManager {
  // MARK: - Observable State
  
  /// Indica se o batch está em execução
  private(set) var isRunning = false
  
  /// Indica se está em processo de cancelamento
  private(set) var isCancelling = false
  
  /// Progresso atual (0.0 a 1.0)
  private(set) var progress: Double = 0
  
  /// Nome do restaurante sendo processado atualmente
  private(set) var currentRestaurantName: String?
  
  /// Contagem de processados / total
  private(set) var processedCount = 0
  private(set) var totalCount = 0
  
  /// Resultado do último batch
  private(set) var lastResult: BatchResult?
  
  /// Mensagem de status para exibir na UI
  var statusMessage: String {
    if isCancelling {
      return "Cancelando..."
    }
    if isRunning {
      if let current = currentRestaurantName {
        return "Processando: \(current)"
      }
      return "Iniciando..."
    } else if let result = lastResult {
      if result.cancelled {
        return "Cancelado: \(result.success) resolvidos, \(result.failed) falhas"
      }
      return "Concluído: \(result.success) resolvidos, \(result.failed) falhas"
    }
    return "Pronto para enriquecer"
  }
  
  // MARK: - Dependencies
  
  private var enrichmentService: RestaurantLocationEnrichmentService?
  private var enrichmentTask: Task<BatchResult, Never>?
  private let logger = Logger(subsystem: "ChooseThere", category: "EnrichmentManager")
  
  // MARK: - Public API
  
  /// Configura o manager com as dependências necessárias
  func configure(with repository: RestaurantRepository) {
    let placeResolver = MapKitPlaceResolver()
    self.enrichmentService = RestaurantLocationEnrichmentService(
      placeResolver: placeResolver,
      restaurantRepository: repository
    )
  }
  
  /// Inicia o enriquecimento de todos os restaurantes não resolvidos
  func startEnrichment() async {
    guard !isRunning else {
      logger.warning("Enrichment already running")
      return
    }
    
    guard let service = enrichmentService else {
      logger.error("EnrichmentManager not configured")
      return
    }
    
    isRunning = true
    isCancelling = false
    progress = 0
    processedCount = 0
    totalCount = 0
    currentRestaurantName = nil
    lastResult = nil
    
    logger.info("Starting batch enrichment")
    
    // Criar task para poder cancelar posteriormente
    enrichmentTask = Task {
      await service.enrichAll { [weak self] batchProgress in
        Task { @MainActor in
          self?.updateProgress(batchProgress)
        }
      }
    }
    
    // Aguardar resultado da task
    let result = await enrichmentTask?.value ?? .empty
    
    // Finalizar
    lastResult = result
    isRunning = false
    isCancelling = false
    progress = result.cancelled ? progress : 1.0
    currentRestaurantName = nil
    enrichmentTask = nil
    
    if result.cancelled {
      logger.info("Batch enrichment was cancelled")
    } else {
      logger.info("Batch enrichment completed")
    }
  }
  
  /// Cancela o enriquecimento em andamento
  func cancel() {
    guard isRunning, let task = enrichmentTask else {
      logger.info("No enrichment task to cancel")
      return
    }
    
    isCancelling = true
    task.cancel()
    logger.info("Enrichment cancellation requested")
  }
  
  // MARK: - Private
  
  private func updateProgress(_ batchProgress: BatchProgress) {
    self.processedCount = batchProgress.processed
    self.totalCount = batchProgress.total
    self.progress = batchProgress.percentage
    self.currentRestaurantName = batchProgress.current
  }
}




