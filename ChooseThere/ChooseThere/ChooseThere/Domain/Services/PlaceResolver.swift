//
//  PlaceResolver.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import Foundation
import CoreLocation

/// Resultado de uma resolução de localização
struct PlaceResolverResult: Sendable {
  let latitude: Double
  let longitude: Double
  let normalizedName: String?
  let normalizedAddress: String?
  /// Indica o nível de confiança do match (0.0 a 1.0)
  let confidence: Double
}

/// Protocol para resolvedores de localização de places
protocol PlaceResolver: Sendable {
  /// Resolve coordenadas a partir de dados textuais
  /// - Parameters:
  ///   - name: Nome do estabelecimento
  ///   - address: Endereço
  ///   - city: Cidade
  ///   - state: Estado
  ///   - currentLat: Latitude atual (para heurística de distância)
  ///   - currentLng: Longitude atual (para heurística de distância)
  /// - Returns: Resultado com coordenadas e metadados, ou nil se não encontrado
  func resolve(
    name: String,
    address: String,
    city: String,
    state: String,
    currentLat: Double?,
    currentLng: Double?
  ) async throws -> PlaceResolverResult?
}

/// Erros específicos do PlaceResolver
enum PlaceResolverError: Error, LocalizedError {
  case noResults
  case ambiguousResults(count: Int)
  case searchFailed(underlying: Error)
  
  var errorDescription: String? {
    switch self {
    case .noResults:
      return "Nenhum resultado encontrado"
    case .ambiguousResults(let count):
      return "Resultados ambíguos (\(count) encontrados)"
    case .searchFailed(let error):
      return "Falha na busca: \(error.localizedDescription)"
    }
  }
}




