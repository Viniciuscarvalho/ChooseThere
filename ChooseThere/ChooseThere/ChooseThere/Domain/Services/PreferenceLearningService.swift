//
//  PreferenceLearningService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation

// MARK: - PreferenceLearning Protocol

/// Protocolo para serviço de aprendizado de preferências
protocol PreferenceLearning {
  /// Aplica uma avaliação para atualizar os pesos aprendidos
  /// - Parameters:
  ///   - rating: Nota da avaliação (1-5)
  ///   - tags: Tags do restaurante avaliado
  ///   - category: Categoria do restaurante avaliado
  /// - Returns: Preferências atualizadas (ou inalteradas se aprendizado desabilitado)
  @discardableResult
  func applyRating(
    rating: Int,
    tags: [String],
    category: String
  ) -> LearnedPreferences

  /// Verifica se o aprendizado está habilitado
  var isLearningEnabled: Bool { get }

  /// Carrega as preferências atuais
  func loadPreferences() -> LearnedPreferences

  /// Reseta todas as preferências aprendidas
  func resetPreferences()
}

// MARK: - PreferenceLearningService

/// Serviço responsável por atualizar preferências aprendidas com base em avaliações.
/// Respeita o toggle `learningEnabled` antes de fazer qualquer atualização.
final class PreferenceLearningService: PreferenceLearning {
  // MARK: - Dependencies

  private let store: LearnedPreferencesStoring
  private let settingsProvider: () -> Bool

  // MARK: - Initialization

  /// Cria um PreferenceLearningService com dependências injetáveis
  /// - Parameters:
  ///   - store: Store para persistência de preferências
  ///   - settingsProvider: Closure que retorna se learning está habilitado
  init(
    store: LearnedPreferencesStoring = LearnedPreferencesStore(),
    settingsProvider: @escaping () -> Bool = { AppSettingsStorage.learningEnabled }
  ) {
    self.store = store
    self.settingsProvider = settingsProvider
  }

  // MARK: - PreferenceLearning

  var isLearningEnabled: Bool {
    settingsProvider()
  }

  func loadPreferences() -> LearnedPreferences {
    store.load()
  }

  func resetPreferences() {
    store.reset()
  }

  @discardableResult
  func applyRating(
    rating: Int,
    tags: [String],
    category: String
  ) -> LearnedPreferences {
    // Se aprendizado está desabilitado, não faz nada
    guard isLearningEnabled else {
      return store.load()
    }

    // Carregar preferências atuais
    var prefs = store.load()

    // Calcular delta baseado no rating
    let delta = LearnedPreferences.weightDelta(forRating: rating)

    // Se delta é zero (rating 3), não precisa atualizar
    guard delta != 0 else {
      return prefs
    }

    // Atualizar pesos das tags
    for tag in tags where !tag.isEmpty {
      prefs.updateWeight(forTag: tag, delta: delta)
    }

    // Atualizar peso da categoria
    if !category.isEmpty {
      prefs.updateWeight(forCategory: category, delta: delta)
    }

    // Persistir
    store.save(prefs)

    return prefs
  }
}

// MARK: - Convenience Factory

extension PreferenceLearningService {
  /// Cria uma instância padrão do serviço
  nonisolated static func makeDefault() -> PreferenceLearningService {
    PreferenceLearningService()
  }
}

// MARK: - Testing Support

#if DEBUG
extension PreferenceLearningService {
  /// Cria uma instância para testes com learning sempre habilitado
  static func makeForTesting(
    store: LearnedPreferencesStoring,
    learningEnabled: Bool = true
  ) -> PreferenceLearningService {
    PreferenceLearningService(
      store: store,
      settingsProvider: { learningEnabled }
    )
  }
}
#endif

