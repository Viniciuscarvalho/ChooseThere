//
//  BackupModels.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

// MARK: - BackupV1

/// Modelo principal do arquivo de backup (schema v1)
/// Contém todos os dados exportáveis: restaurantes e visitas
struct BackupV1: Codable, Equatable {
  /// Versão do schema (sempre 1 para este modelo)
  let schemaVersion: Int

  /// Data de criação do backup
  let createdAt: Date

  /// Versão do app que gerou o backup (opcional)
  let appVersion: String?

  /// Lista de restaurantes do usuário
  let restaurants: [BackupRestaurant]

  /// Lista de visitas/avaliações
  let visits: [BackupVisit]

  // MARK: - Initializers

  init(
    schemaVersion: Int = 1,
    createdAt: Date = Date(),
    appVersion: String? = nil,
    restaurants: [BackupRestaurant],
    visits: [BackupVisit]
  ) {
    self.schemaVersion = schemaVersion
    self.createdAt = createdAt
    self.appVersion = appVersion
    self.restaurants = restaurants
    self.visits = visits
  }
}

// MARK: - BackupRestaurant

/// Modelo de restaurante para backup (subset do RestaurantModel)
struct BackupRestaurant: Codable, Equatable, Identifiable {
  let id: String
  let name: String
  let category: String
  let address: String
  let city: String
  let state: String
  let tags: [String]
  let notes: String
  let externalLink: String?
  let lat: Double
  let lng: Double
  let isFavorite: Bool

  // Campos opcionais de rating (snapshot)
  let ratingAverage: Double?
  let ratingCount: Int?
  let ratingLastVisitedAt: Date?

  // MARK: - Initializers

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
    isFavorite: Bool,
    ratingAverage: Double? = nil,
    ratingCount: Int? = nil,
    ratingLastVisitedAt: Date? = nil
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
    self.ratingAverage = ratingAverage
    self.ratingCount = ratingCount
    self.ratingLastVisitedAt = ratingLastVisitedAt
  }
}

// MARK: - BackupVisit

/// Modelo de visita para backup (espelha VisitModel)
struct BackupVisit: Codable, Equatable, Identifiable {
  let id: UUID
  let restaurantId: String
  let dateVisited: Date
  let rating: Int
  let tags: [String]
  let note: String?
  let isMatch: Bool
  let wouldReturn: Bool

  // MARK: - Initializers

  init(
    id: UUID,
    restaurantId: String,
    dateVisited: Date,
    rating: Int,
    tags: [String],
    note: String?,
    isMatch: Bool,
    wouldReturn: Bool
  ) {
    self.id = id
    self.restaurantId = restaurantId
    self.dateVisited = dateVisited
    self.rating = rating
    self.tags = tags
    self.note = note
    self.isMatch = isMatch
    self.wouldReturn = wouldReturn
  }
}

// MARK: - BackupImportMode

/// Estratégia de importação do backup
enum BackupImportMode: String, CaseIterable {
  /// Substitui toda a base local pelo conteúdo do backup
  case replaceAll

  /// Mescla por ID: insere novos, atualiza existentes, não apaga o restante
  case mergeByID

  var displayName: String {
    switch self {
    case .replaceAll:
      return "Substituir tudo"
    case .mergeByID:
      return "Mesclar por ID"
    }
  }

  var description: String {
    switch self {
    case .replaceAll:
      return "Apaga todos os dados locais e importa o backup do zero."
    case .mergeByID:
      return "Adiciona novos itens e atualiza existentes sem apagar o restante."
    }
  }
}

// MARK: - BackupImportResult

/// Resultado da operação de importação
struct BackupImportResult: Equatable {
  let importedRestaurants: Int
  let updatedRestaurants: Int
  let importedVisits: Int
  let updatedVisits: Int
  let skippedInvalidEntries: Int

  var totalRestaurantsAffected: Int {
    importedRestaurants + updatedRestaurants
  }

  var totalVisitsAffected: Int {
    importedVisits + updatedVisits
  }

  var hasSkippedEntries: Bool {
    skippedInvalidEntries > 0
  }

  /// Mensagem formatada para exibição ao usuário
  var summary: String {
    var parts: [String] = []

    if importedRestaurants > 0 {
      parts.append("\(importedRestaurants) restaurante(s) importado(s)")
    }
    if updatedRestaurants > 0 {
      parts.append("\(updatedRestaurants) restaurante(s) atualizado(s)")
    }
    if importedVisits > 0 {
      parts.append("\(importedVisits) visita(s) importada(s)")
    }
    if updatedVisits > 0 {
      parts.append("\(updatedVisits) visita(s) atualizada(s)")
    }
    if skippedInvalidEntries > 0 {
      parts.append("\(skippedInvalidEntries) entrada(s) inválida(s) ignorada(s)")
    }

    return parts.isEmpty ? "Nenhuma alteração realizada." : parts.joined(separator: ", ")
  }

  static let empty = BackupImportResult(
    importedRestaurants: 0,
    updatedRestaurants: 0,
    importedVisits: 0,
    updatedVisits: 0,
    skippedInvalidEntries: 0)
}

// MARK: - BackupPreview

/// Preview/resumo do backup antes de aplicar
struct BackupPreview: Equatable {
  let schemaVersion: Int
  let createdAt: Date
  let appVersion: String?
  let restaurantCount: Int
  let visitCount: Int
  let favoriteCount: Int
  let uniqueCities: [String]

  /// Cria um preview a partir de um BackupV1 validado
  init(from backup: BackupV1) {
    self.schemaVersion = backup.schemaVersion
    self.createdAt = backup.createdAt
    self.appVersion = backup.appVersion
    self.restaurantCount = backup.restaurants.count
    self.visitCount = backup.visits.count
    self.favoriteCount = backup.restaurants.filter { $0.isFavorite }.count
    self.uniqueCities = Array(Set(backup.restaurants.map { $0.city })).sorted()
  }
}

// MARK: - Transferable Conformance

extension BackupV1: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .json) { backup in
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      return try encoder.encode(backup)
    }
  }
}

// MARK: - FileDocument Wrapper

import SwiftUI

/// Wrapper para usar BackupV1 com fileExporter (alternativa ao ShareLink)
struct BackupFileDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.json] }
  
  let backup: BackupV1
  
  init(backup: BackupV1) {
    self.backup = backup
  }
  
  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents else {
      throw CocoaError(.fileReadCorruptFile)
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    self.backup = try decoder.decode(BackupV1.self, from: data)
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(backup)
    return FileWrapper(regularFileWithContents: data)
  }
}

