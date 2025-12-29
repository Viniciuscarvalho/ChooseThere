//
//  BackupCodec.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation

// MARK: - BackupValidationError

/// Erros de validação do backup
enum BackupValidationError: Error, LocalizedError, Equatable {
  case invalidJSON(String)
  case unsupportedSchemaVersion(Int)
  case missingRequiredField(String)
  case invalidRestaurantData(String, reason: String)
  case invalidVisitData(UUID, reason: String)
  case orphanedVisit(visitId: UUID, restaurantId: String)
  case emptyBackup
  case futureDate

  var errorDescription: String? {
    switch self {
    case .invalidJSON(let detail):
      return "O arquivo não é um JSON válido: \(detail)"
    case .unsupportedSchemaVersion(let version):
      return "Versão do backup não suportada: \(version). Atualize o app."
    case .missingRequiredField(let field):
      return "Campo obrigatório ausente: \(field)"
    case .invalidRestaurantData(let id, let reason):
      return "Dados inválidos no restaurante '\(id)': \(reason)"
    case .invalidVisitData(let id, let reason):
      return "Dados inválidos na visita '\(id.uuidString)': \(reason)"
    case .orphanedVisit(let visitId, let restaurantId):
      return "A visita '\(visitId.uuidString)' referencia um restaurante inexistente: '\(restaurantId)'"
    case .emptyBackup:
      return "O backup está vazio (sem restaurantes)."
    case .futureDate:
      return "A data de criação do backup está no futuro."
    }
  }
}

// MARK: - BackupCoding Protocol

/// Protocolo para encode/decode de backups
protocol BackupCoding {
  /// Codifica um BackupV1 para Data (JSON)
  func encode(_ backup: BackupV1) throws -> Data

  /// Decodifica Data (JSON) para BackupV1
  func decode(from data: Data) throws -> BackupV1

  /// Valida um BackupV1 após decode
  /// - Parameter backup: O backup a ser validado
  /// - Parameter strict: Se true, valida referências de visitas para restaurantes
  /// - Throws: BackupValidationError se houver problemas
  func validate(_ backup: BackupV1, strict: Bool) throws
}

// MARK: - BackupCodec

/// Implementação do codec de backup com validação
struct BackupCodec: BackupCoding {
  // MARK: - Constants

  /// Versão mínima suportada do schema
  static let minimumSupportedVersion = 1

  /// Versão máxima suportada do schema
  static let maximumSupportedVersion = 1

  /// Nome padrão do arquivo de backup
  static let defaultFileName = "chooseThere_backup.json"

  // MARK: - Private Properties

  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  // MARK: - Initializer

  init() {
    encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
  }

  // MARK: - BackupCoding

  func encode(_ backup: BackupV1) throws -> Data {
    do {
      return try encoder.encode(backup)
    } catch {
      throw BackupValidationError.invalidJSON(error.localizedDescription)
    }
  }

  func decode(from data: Data) throws -> BackupV1 {
    do {
      let backup = try decoder.decode(BackupV1.self, from: data)
      return backup
    } catch let error as DecodingError {
      throw mapDecodingError(error)
    } catch {
      throw BackupValidationError.invalidJSON(error.localizedDescription)
    }
  }

  func validate(_ backup: BackupV1, strict: Bool = true) throws {
    // 1. Validar versão do schema
    guard backup.schemaVersion >= Self.minimumSupportedVersion,
          backup.schemaVersion <= Self.maximumSupportedVersion else {
      throw BackupValidationError.unsupportedSchemaVersion(backup.schemaVersion)
    }

    // 2. Validar data de criação
    if backup.createdAt > Date().addingTimeInterval(60) { // 1 minuto de tolerância
      throw BackupValidationError.futureDate
    }

    // 3. Validar que há pelo menos algum conteúdo
    if backup.restaurants.isEmpty && backup.visits.isEmpty {
      throw BackupValidationError.emptyBackup
    }

    // 4. Validar cada restaurante
    for restaurant in backup.restaurants {
      try validateRestaurant(restaurant)
    }

    // 5. Validar cada visita
    for visit in backup.visits {
      try validateVisit(visit)
    }

    // 6. Validar referências (strict mode)
    if strict {
      try validateReferences(backup)
    }
  }

  // MARK: - Private Validation Methods

  private func validateRestaurant(_ restaurant: BackupRestaurant) throws {
    // ID não pode ser vazio
    guard !restaurant.id.trimmingCharacters(in: .whitespaces).isEmpty else {
      throw BackupValidationError.invalidRestaurantData(restaurant.id, reason: "ID vazio")
    }

    // Nome não pode ser vazio
    guard !restaurant.name.trimmingCharacters(in: .whitespaces).isEmpty else {
      throw BackupValidationError.invalidRestaurantData(restaurant.id, reason: "Nome vazio")
    }

    // Coordenadas devem ser válidas
    guard restaurant.lat >= -90, restaurant.lat <= 90 else {
      throw BackupValidationError.invalidRestaurantData(
        restaurant.id,
        reason: "Latitude inválida: \(restaurant.lat)")
    }

    guard restaurant.lng >= -180, restaurant.lng <= 180 else {
      throw BackupValidationError.invalidRestaurantData(
        restaurant.id,
        reason: "Longitude inválida: \(restaurant.lng)")
    }
  }

  private func validateVisit(_ visit: BackupVisit) throws {
    // restaurantId não pode ser vazio
    guard !visit.restaurantId.trimmingCharacters(in: .whitespaces).isEmpty else {
      throw BackupValidationError.invalidVisitData(visit.id, reason: "restaurantId vazio")
    }

    // Rating deve estar entre 0 e 5
    guard visit.rating >= 0, visit.rating <= 5 else {
      throw BackupValidationError.invalidVisitData(
        visit.id,
        reason: "Rating fora do intervalo (0-5): \(visit.rating)")
    }

    // Data da visita não pode ser no futuro distante
    if visit.dateVisited > Date().addingTimeInterval(86400) { // 1 dia de tolerância
      throw BackupValidationError.invalidVisitData(
        visit.id,
        reason: "Data da visita no futuro")
    }
  }

  private func validateReferences(_ backup: BackupV1) throws {
    let restaurantIds = Set(backup.restaurants.map { $0.id })

    for visit in backup.visits {
      guard restaurantIds.contains(visit.restaurantId) else {
        throw BackupValidationError.orphanedVisit(
          visitId: visit.id,
          restaurantId: visit.restaurantId)
      }
    }
  }

  // MARK: - Error Mapping

  private func mapDecodingError(_ error: DecodingError) -> BackupValidationError {
    switch error {
    case .keyNotFound(let key, _):
      return .missingRequiredField(key.stringValue)
    case .typeMismatch(_, let context):
      let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
      return .invalidJSON("Tipo incorreto em '\(path)'")
    case .valueNotFound(_, let context):
      let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
      return .missingRequiredField(path)
    case .dataCorrupted(let context):
      return .invalidJSON(context.debugDescription)
    @unknown default:
      return .invalidJSON("Erro desconhecido de decodificação")
    }
  }
}

// MARK: - Convenience Extensions

extension BackupCodec {
  /// Decodifica e valida em uma única operação
  func decodeAndValidate(from data: Data, strict: Bool = true) throws -> BackupV1 {
    let backup = try decode(from: data)
    try validate(backup, strict: strict)
    return backup
  }

  /// Gera um preview do backup sem validação completa
  func preview(from data: Data) throws -> BackupPreview {
    let backup = try decode(from: data)
    // Validação leve (apenas versão)
    guard backup.schemaVersion >= Self.minimumSupportedVersion,
          backup.schemaVersion <= Self.maximumSupportedVersion else {
      throw BackupValidationError.unsupportedSchemaVersion(backup.schemaVersion)
    }
    return BackupPreview(from: backup)
  }
}

