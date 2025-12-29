//
//  SmartRouletteService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation

// MARK: - SmartRouletteProtocol

/// Protocolo para o serviço de roleta inteligente
protocol SmartRouletteProtocol {
  /// Sorteia um restaurante aplicando:
  /// - Preferências aprendidas (se habilitado)
  /// - Anti-repetição (últimos N, se habilitado)
  /// - Filtros do contexto
  /// - Parameters:
  ///   - restaurants: Lista de restaurantes candidatos
  ///   - context: Contexto de preferências do usuário
  ///   - sessionExcludes: IDs excluídos manualmente nesta sessão
  /// - Returns: Restaurante sorteado ou nil
  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    sessionExcludes: Set<String>
  ) -> Restaurant?
}

// MARK: - SmartRouletteService

/// Serviço que combina o sorteio com:
/// - Preferências aprendidas (ponderação por match)
/// - Anti-repetição (evitar últimos N)
/// - Fallback inteligente quando candidatos são insuficientes
final class SmartRouletteService: SmartRouletteProtocol {
  // MARK: - Dependencies

  private let randomizer: RestaurantRandomizerProtocol
  private let recentHistoryProvider: RecentHistoryProviding
  private let preferencesStore: LearnedPreferencesStoring
  private let settingsProvider: SettingsProvider

  // MARK: - Settings Provider

  struct SettingsProvider {
    var isLearningEnabled: () -> Bool
    var avoidRepeatsLimit: () -> Int

    static let `default` = SettingsProvider(
      isLearningEnabled: { AppSettingsStorage.learningEnabled },
      avoidRepeatsLimit: { AppSettingsStorage.avoidRepeatsLimit }
    )
  }

  // MARK: - Initialization

  init(
    randomizer: RestaurantRandomizerProtocol = RestaurantRandomizer(),
    recentHistoryProvider: RecentHistoryProviding,
    preferencesStore: LearnedPreferencesStoring = LearnedPreferencesStore(),
    settingsProvider: SettingsProvider = .default
  ) {
    self.randomizer = randomizer
    self.recentHistoryProvider = recentHistoryProvider
    self.preferencesStore = preferencesStore
    self.settingsProvider = settingsProvider
  }

  // MARK: - SmartRouletteProtocol

  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    sessionExcludes: Set<String>
  ) -> Restaurant? {
    // 1. Preparar contexto com preferências aprendidas (se habilitado)
    var enrichedContext = context
    if settingsProvider.isLearningEnabled() {
      enrichedContext.learnedPreferences = preferencesStore.load()
    }

    // 2. Preparar IDs a excluir (sessão + histórico recente)
    var allExcludes = sessionExcludes

    let avoidLimit = settingsProvider.avoidRepeatsLimit()
    if avoidLimit > 0 {
      if let recentIDs = try? recentHistoryProvider.recentRestaurantIDs(limit: avoidLimit) {
        allExcludes.formUnion(recentIDs)
      }
    }

    // 3. Tentar sorteio com todas as exclusões
    if let result = randomizer.pick(
      from: restaurants,
      context: enrichedContext,
      excludeRestaurantIDs: allExcludes
    ) {
      return result
    }

    // 4. Fallback: tentar apenas com exclusões da sessão (ignorar anti-repetição)
    if avoidLimit > 0 && !allExcludes.isEmpty {
      if let result = randomizer.pick(
        from: restaurants,
        context: enrichedContext,
        excludeRestaurantIDs: sessionExcludes
      ) {
        return result
      }
    }

    // 5. Fallback final: sorteio sem exclusões
    return randomizer.pick(
      from: restaurants,
      context: enrichedContext,
      excludeRestaurantIDs: []
    )
  }
}

// MARK: - Convenience Extensions

extension SmartRouletteService {
  /// Verifica quantos candidatos estariam disponíveis após aplicar exclusões
  func availableCandidatesCount(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    sessionExcludes: Set<String>
  ) -> Int {
    var allExcludes = sessionExcludes

    let avoidLimit = settingsProvider.avoidRepeatsLimit()
    if avoidLimit > 0 {
      if let recentIDs = try? recentHistoryProvider.recentRestaurantIDs(limit: avoidLimit) {
        allExcludes.formUnion(recentIDs)
      }
    }

    return restaurants.filter { !allExcludes.contains($0.id) }.count
  }

  /// Retorna informação sobre o fallback aplicado
  func wouldUseFallback(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    sessionExcludes: Set<String>
  ) -> Bool {
    availableCandidatesCount(from: restaurants, context: context, sessionExcludes: sessionExcludes) == 0
  }
}

// MARK: - Testing Support

#if DEBUG
extension SmartRouletteService {
  /// Cria uma instância para testes com dependências mockadas
  static func makeForTesting(
    randomizer: RestaurantRandomizerProtocol,
    recentHistoryProvider: RecentHistoryProviding,
    preferencesStore: LearnedPreferencesStoring,
    isLearningEnabled: Bool = true,
    avoidRepeatsLimit: Int = 10
  ) -> SmartRouletteService {
    SmartRouletteService(
      randomizer: randomizer,
      recentHistoryProvider: recentHistoryProvider,
      preferencesStore: preferencesStore,
      settingsProvider: SettingsProvider(
        isLearningEnabled: { isLearningEnabled },
        avoidRepeatsLimit: { avoidRepeatsLimit }
      )
    )
  }
}
#endif

