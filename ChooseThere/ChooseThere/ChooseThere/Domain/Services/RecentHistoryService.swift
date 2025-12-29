//
//  RecentHistoryService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation

// MARK: - RecentHistoryProviding Protocol

/// Protocolo para obter histórico recente de restaurantes visitados
protocol RecentHistoryProviding {
  /// Retorna os IDs dos últimos N restaurantes visitados (únicos, ordenados por data)
  /// - Parameter limit: Número máximo de IDs a retornar
  /// - Returns: Array de restaurantIds ordenados do mais recente ao mais antigo
  func recentRestaurantIDs(limit: Int) throws -> [String]
}

// MARK: - RecentHistoryService

/// Serviço que obtém os restaurantes recentemente visitados
/// Usado para evitar repetição no sorteio
final class RecentHistoryService: RecentHistoryProviding {
  // MARK: - Dependencies

  private let visitRepository: VisitRepository

  // MARK: - Initialization

  init(visitRepository: VisitRepository) {
    self.visitRepository = visitRepository
  }

  // MARK: - RecentHistoryProviding

  /// Retorna os IDs dos últimos N restaurantes visitados (únicos)
  /// Se um restaurante foi visitado múltiplas vezes, aparece apenas uma vez
  /// na posição de sua visita mais recente
  func recentRestaurantIDs(limit: Int) throws -> [String] {
    guard limit > 0 else { return [] }

    // Buscar todas as visitas (já vêm ordenadas por data desc)
    let visits = try visitRepository.fetchAll()

    // Extrair IDs únicos mantendo a ordem (mais recentes primeiro)
    var seen = Set<String>()
    var uniqueIDs: [String] = []

    for visit in visits {
      if !seen.contains(visit.restaurantId) {
        seen.insert(visit.restaurantId)
        uniqueIDs.append(visit.restaurantId)

        // Parar quando atingir o limite
        if uniqueIDs.count >= limit {
          break
        }
      }
    }

    return uniqueIDs
  }
}

// MARK: - Convenience Factory

extension RecentHistoryService {
  /// Cria uma instância do serviço usando o repositório padrão
  /// Nota: Requer um ModelContext válido para funcionar
  static func make(visitRepository: VisitRepository) -> RecentHistoryService {
    RecentHistoryService(visitRepository: visitRepository)
  }
}

// MARK: - Mock for Testing

#if DEBUG
/// Mock do RecentHistoryService para testes
final class MockRecentHistoryService: RecentHistoryProviding {
  var recentIDs: [String] = []
  var shouldThrow: Bool = false

  func recentRestaurantIDs(limit: Int) throws -> [String] {
    if shouldThrow {
      throw NSError(domain: "MockError", code: 1, userInfo: nil)
    }
    return Array(recentIDs.prefix(limit))
  }
}
#endif

