//
//  BackupExportService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation
import SwiftData

// MARK: - BackupExportError

/// Erros durante exportação do backup
enum BackupExportError: Error, LocalizedError {
  case repositoryError(String)
  case encodingError(String)
  case emptyData

  var errorDescription: String? {
    switch self {
    case .repositoryError(let detail):
      return "Erro ao buscar dados: \(detail)"
    case .encodingError(let detail):
      return "Erro ao gerar backup: \(detail)"
    case .emptyData:
      return "Não há dados para exportar."
    }
  }
}

// MARK: - BackupExporting Protocol

/// Protocolo para serviços de exportação de backup
protocol BackupExporting {
  /// Gera um BackupV1 a partir dos dados locais
  func generateBackup() async throws -> BackupV1

  /// Gera o arquivo JSON do backup
  func generateBackupData() async throws -> Data
}

// MARK: - BackupExportService

/// Serviço para exportar backup da coleção do usuário
final class BackupExportService: BackupExporting {
  // MARK: - Properties

  private let restaurantRepository: RestaurantRepository
  private let visitRepository: VisitRepository
  private let codec: BackupCoding

  // MARK: - Initializer

  init(
    restaurantRepository: RestaurantRepository,
    visitRepository: VisitRepository,
    codec: BackupCoding = BackupCodec()
  ) {
    self.restaurantRepository = restaurantRepository
    self.visitRepository = visitRepository
    self.codec = codec
  }

  // MARK: - BackupExporting

  func generateBackup() async throws -> BackupV1 {
    // 1. Buscar todos os restaurantes
    let restaurants: [Restaurant]
    do {
      restaurants = try restaurantRepository.fetchAll()
    } catch {
      throw BackupExportError.repositoryError("Falha ao buscar restaurantes: \(error.localizedDescription)")
    }

    // 2. Buscar todas as visitas
    let visits: [Visit]
    do {
      visits = try visitRepository.fetchAll()
    } catch {
      throw BackupExportError.repositoryError("Falha ao buscar visitas: \(error.localizedDescription)")
    }

    // 3. Validar que há dados
    guard !restaurants.isEmpty || !visits.isEmpty else {
      throw BackupExportError.emptyData
    }

    // 4. Converter para modelos de backup
    let backupRestaurants = restaurants.map { convertToBackupRestaurant($0) }
    let backupVisits = visits.map { convertToBackupVisit($0) }

    // 5. Criar BackupV1
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: appVersion,
      restaurants: backupRestaurants,
      visits: backupVisits
    )

    return backup
  }

  func generateBackupData() async throws -> Data {
    let backup = try await generateBackup()

    do {
      let data = try codec.encode(backup)
      return data
    } catch {
      throw BackupExportError.encodingError(error.localizedDescription)
    }
  }

  // MARK: - Private Conversion Methods

  private func convertToBackupRestaurant(_ restaurant: Restaurant) -> BackupRestaurant {
    BackupRestaurant(
      id: restaurant.id,
      name: restaurant.name,
      category: restaurant.category,
      address: restaurant.address,
      city: restaurant.city,
      state: restaurant.state,
      tags: restaurant.tags,
      notes: restaurant.notes,
      externalLink: restaurant.externalLink?.absoluteString,
      lat: restaurant.lat,
      lng: restaurant.lng,
      isFavorite: restaurant.isFavorite,
      ratingAverage: restaurant.ratingAverage,
      ratingCount: restaurant.ratingCount,
      ratingLastVisitedAt: restaurant.ratingLastVisitedAt
    )
  }

  private func convertToBackupVisit(_ visit: Visit) -> BackupVisit {
    BackupVisit(
      id: visit.id,
      restaurantId: visit.restaurantId,
      dateVisited: visit.dateVisited,
      rating: visit.rating,
      tags: visit.tags,
      note: visit.note,
      isMatch: visit.isMatch,
      wouldReturn: visit.wouldReturn
    )
  }
}

// MARK: - Convenience Extension

extension BackupExportService {
  /// Cria um serviço de export usando o ModelContext padrão
  static func make(context: ModelContext) -> BackupExportService {
    let restaurantRepo = SwiftDataRestaurantRepository(context: context)
    let visitRepo = SwiftDataVisitRepository(context: context)
    return BackupExportService(
      restaurantRepository: restaurantRepo,
      visitRepository: visitRepo
    )
  }
}

