//
//  BackupImportService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation
import SwiftData

// MARK: - BackupImportError

/// Erros durante importação do backup
enum BackupImportError: Error, LocalizedError {
  case repositoryError(String)
  case invalidData(String)
  case referentialIntegrity(String)

  var errorDescription: String? {
    switch self {
    case .repositoryError(let detail):
      return "Erro ao salvar dados: \(detail)"
    case .invalidData(let detail):
      return "Dados inválidos: \(detail)"
    case .referentialIntegrity(let detail):
      return "Erro de integridade: \(detail)"
    }
  }
}

// MARK: - BackupImporting Protocol

/// Protocolo para serviços de importação de backup
protocol BackupImporting {
  /// Aplica um backup usando o modo especificado
  func apply(_ backup: BackupV1, mode: BackupImportMode) async throws -> BackupImportResult
}

// MARK: - BackupImportService

/// Serviço para importar backup da coleção
final class BackupImportService: BackupImporting {
  // MARK: - Properties

  private let context: ModelContext

  // MARK: - Initializer

  init(context: ModelContext) {
    self.context = context
  }

  // MARK: - BackupImporting

  func apply(_ backup: BackupV1, mode: BackupImportMode) async throws -> BackupImportResult {
    switch mode {
    case .replaceAll:
      return try await replaceAll(backup)
    case .mergeByID:
      return try await mergeByID(backup)
    }
  }

  // MARK: - Replace All Strategy

  /// Estratégia: Apaga todos os dados locais e importa o backup do zero
  private func replaceAll(_ backup: BackupV1) async throws -> BackupImportResult {
    // 1. Deletar todas as visitas (primeiro, por integridade referencial)
    let visitDescriptor = FetchDescriptor<VisitModel>()
    let existingVisits = try context.fetch(visitDescriptor)
    for visit in existingVisits {
      context.delete(visit)
    }

    // 2. Deletar todos os restaurantes
    let restaurantDescriptor = FetchDescriptor<RestaurantModel>()
    let existingRestaurants = try context.fetch(restaurantDescriptor)
    for restaurant in existingRestaurants {
      context.delete(restaurant)
    }

    // 3. Inserir restaurantes do backup
    var importedRestaurants = 0
    for backupRestaurant in backup.restaurants {
      let model = convertToRestaurantModel(backupRestaurant)
      context.insert(model)
      importedRestaurants += 1
    }

    // 4. Inserir visitas do backup
    var importedVisits = 0
    for backupVisit in backup.visits {
      let model = convertToVisitModel(backupVisit)
      context.insert(model)
      importedVisits += 1
    }

    // 5. Salvar mudanças
    try context.save()

    return BackupImportResult(
      importedRestaurants: importedRestaurants,
      updatedRestaurants: 0,
      importedVisits: importedVisits,
      updatedVisits: 0,
      skippedInvalidEntries: 0
    )
  }

  // MARK: - Merge By ID Strategy

  /// Estratégia: Mescla por ID (upsert) sem apagar dados existentes
  private func mergeByID(_ backup: BackupV1) async throws -> BackupImportResult {
    var importedRestaurants = 0
    var updatedRestaurants = 0
    var importedVisits = 0
    var updatedVisits = 0

    // 1. Mesclar restaurantes
    for backupRestaurant in backup.restaurants {
      let targetId = backupRestaurant.id
      var descriptor = FetchDescriptor<RestaurantModel>(
        predicate: #Predicate { $0.id == targetId }
      )
      descriptor.fetchLimit = 1

      if let existing = try context.fetch(descriptor).first {
        // Atualizar existente
        updateRestaurantModel(existing, from: backupRestaurant)
        updatedRestaurants += 1
      } else {
        // Inserir novo
        let model = convertToRestaurantModel(backupRestaurant)
        context.insert(model)
        importedRestaurants += 1
      }
    }

    // 2. Mesclar visitas
    for backupVisit in backup.visits {
      let targetId = backupVisit.id
      var descriptor = FetchDescriptor<VisitModel>(
        predicate: #Predicate { $0.id == targetId }
      )
      descriptor.fetchLimit = 1

      if let existing = try context.fetch(descriptor).first {
        // Atualizar existente
        updateVisitModel(existing, from: backupVisit)
        updatedVisits += 1
      } else {
        // Inserir novo
        let model = convertToVisitModel(backupVisit)
        context.insert(model)
        importedVisits += 1
      }
    }

    // 3. Salvar mudanças
    try context.save()

    return BackupImportResult(
      importedRestaurants: importedRestaurants,
      updatedRestaurants: updatedRestaurants,
      importedVisits: importedVisits,
      updatedVisits: updatedVisits,
      skippedInvalidEntries: 0
    )
  }

  // MARK: - Conversion Methods

  private func convertToRestaurantModel(_ backup: BackupRestaurant) -> RestaurantModel {
    RestaurantModel(
      id: backup.id,
      name: backup.name,
      category: backup.category,
      address: backup.address,
      city: backup.city,
      state: backup.state,
      tags: backup.tags,
      notes: backup.notes,
      externalLink: backup.externalLink,
      lat: backup.lat,
      lng: backup.lng,
      isFavorite: backup.isFavorite,
      applePlaceResolved: false, // Não importar status de resolução
      applePlaceResolvedAt: nil,
      applePlaceName: nil,
      applePlaceAddress: nil,
      ratingAverage: backup.ratingAverage ?? 0,
      ratingCount: backup.ratingCount ?? 0,
      ratingLastVisitedAt: backup.ratingLastVisitedAt
    )
  }

  private func updateRestaurantModel(
    _ model: RestaurantModel,
    from backup: BackupRestaurant
  ) {
    // Atualizar todos os campos (exceto ID que é imutável)
    model.name = backup.name
    model.category = backup.category
    model.address = backup.address
    model.city = backup.city
    model.state = backup.state
    model.tags = backup.tags
    model.notes = backup.notes
    model.externalLink = backup.externalLink
    model.lat = backup.lat
    model.lng = backup.lng
    model.isFavorite = backup.isFavorite
    // Não sobrescrever dados de Apple Maps resolution
    // Atualizar rating snapshot
    if let average = backup.ratingAverage {
      model.ratingAverage = average
    }
    if let count = backup.ratingCount {
      model.ratingCount = count
    }
    if let lastVisited = backup.ratingLastVisitedAt {
      model.ratingLastVisitedAt = lastVisited
    }
  }

  private func convertToVisitModel(_ backup: BackupVisit) -> VisitModel {
    VisitModel(
      id: backup.id,
      restaurantId: backup.restaurantId,
      dateVisited: backup.dateVisited,
      rating: backup.rating,
      tags: backup.tags,
      note: backup.note,
      isMatch: backup.isMatch,
      wouldReturn: backup.wouldReturn
    )
  }

  private func updateVisitModel(
    _ model: VisitModel,
    from backup: BackupVisit
  ) {
    // Atualizar todos os campos (exceto ID que é imutável)
    model.restaurantId = backup.restaurantId
    model.dateVisited = backup.dateVisited
    model.rating = backup.rating
    model.tags = backup.tags
    model.note = backup.note
    model.isMatch = backup.isMatch
    model.wouldReturn = backup.wouldReturn
  }
}

// MARK: - Convenience Extension

extension BackupImportService {
  /// Cria um serviço de import usando o ModelContext
  static func make(context: ModelContext) -> BackupImportService {
    BackupImportService(context: context)
  }
}

