//
//  RouletteViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class RouletteViewModel {
  // MARK: - State

  enum Phase: Equatable {
    case idle
    case spinning
    case finished(restaurantId: String)
    case noResults
  }

  private(set) var phase: Phase = .idle
  private(set) var displayedNames: [String] = []
  private(set) var currentIndex: Int = 0
  private(set) var reRollCount: Int = 0
  let maxReRolls = 3

  var canReRoll: Bool { reRollCount < maxReRolls }

  // MARK: - Dependencies

  private let restaurantRepository: any RestaurantRepository
  private let smartRoulette: SmartRouletteProtocol
  private var drawnIds: Set<String> = []
  private var allRestaurants: [Restaurant] = []
  
  /// Contexto de preferências passado externamente (tags, raio, rating priority, userLocation)
  private(set) var preferenceContext: PreferenceContext = PreferenceContext()

  init(
    restaurantRepository: any RestaurantRepository,
    visitRepository: (any VisitRepository)? = nil,
    smartRoulette: SmartRouletteProtocol? = nil
  ) {
    self.restaurantRepository = restaurantRepository
    
    // Criar SmartRouletteService se não fornecido
    if let provided = smartRoulette {
      self.smartRoulette = provided
    } else if let visitRepo = visitRepository {
      // Usar visitRepository fornecido para criar SmartRouletteService com anti-repetição
      let recentHistory = RecentHistoryService(visitRepository: visitRepo)
      self.smartRoulette = SmartRouletteService(recentHistoryProvider: recentHistory)
    } else {
      // Fallback: criar SmartRouletteService sem histórico
      let mockHistory = MockRecentHistoryProvider()
      self.smartRoulette = SmartRouletteService(recentHistoryProvider: mockHistory)
    }
  }

  // MARK: - Actions
  
  /// Configura o contexto de preferências para o sorteio.
  /// Deve ser chamado antes de loadAndSpin quando houver filtros ativos.
  func setPreferenceContext(_ context: PreferenceContext) {
    preferenceContext = context
  }

  func loadAndSpin(pendingId: String?) {
    do {
      allRestaurants = try restaurantRepository.fetchAll()
      
      // Filtrar por cidade selecionada se aplicável
      if let parsed = AppSettingsStorage.parseSelectedCity() {
        allRestaurants = allRestaurants.filter { restaurant in
          restaurant.city.lowercased() == parsed.city.lowercased() &&
          restaurant.state.lowercased() == parsed.state.lowercased()
        }
      }
    } catch {
      allRestaurants = []
    }

    // If we already have a pending id from preferences, use it
    if let pending = pendingId, !pending.isEmpty {
      drawnIds.insert(pending)
      startSpinAnimation(finalId: pending)
    } else {
      spinNew()
    }
  }

  func spinNew() {
    guard !allRestaurants.isEmpty else {
      phase = .noResults
      return
    }
    
    // Usa o contexto de preferências configurado externamente
    if let picked = smartRoulette.pick(from: allRestaurants, context: preferenceContext, sessionExcludes: drawnIds) {
      drawnIds.insert(picked.id)
      startSpinAnimation(finalId: picked.id)
    } else {
      phase = .noResults
    }
  }

  func reRoll() {
    guard canReRoll else { return }
    reRollCount += 1
    spinNew()
  }

  // MARK: - Animation

  private func startSpinAnimation(finalId: String) {
    phase = .spinning

    // Generate shuffled names for animation
    let names = allRestaurants.map { $0.name }.shuffled()
    displayedNames = Array(names.prefix(8)) + [allRestaurants.first { $0.id == finalId }?.name ?? ""]
    currentIndex = 0

    animateNextCard(finalId: finalId)
  }

  private func animateNextCard(finalId: String) {
    guard currentIndex < displayedNames.count - 1 else {
      // Finished
      phase = .finished(restaurantId: finalId)
      return
    }
    // Exponential slowdown
    let delay = 0.08 + Double(currentIndex) * 0.04
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(delay))
      currentIndex += 1
      animateNextCard(finalId: finalId)
    }
  }
}

// MARK: - Mock RecentHistoryProvider

/// Mock que sempre retorna vazio (para compatibilidade quando VisitRepository não está disponível)
private final class MockRecentHistoryProvider: RecentHistoryProviding {
  func recentRestaurantIDs(limit: Int) throws -> [String] {
    return []
  }
}

