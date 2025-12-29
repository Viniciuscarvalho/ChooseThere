//
//  LearnedPreferencesStore.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation

// MARK: - LearnedPreferencesStoring Protocol

/// Protocolo para persistência de preferências aprendidas
protocol LearnedPreferencesStoring {
  /// Carrega as preferências aprendidas
  func load() -> LearnedPreferences

  /// Salva as preferências aprendidas
  func save(_ prefs: LearnedPreferences)

  /// Reseta as preferências para o estado inicial
  func reset()
}

// MARK: - LearnedPreferencesStore

/// Store que persiste preferências aprendidas em UserDefaults
/// Usa JSON encode/decode para inspeção e debug fácil
final class LearnedPreferencesStore: LearnedPreferencesStoring {
  // MARK: - Constants

  private let userDefaultsKey = "learnedPreferences"

  // MARK: - Dependencies

  private let userDefaults: UserDefaults

  // MARK: - Initialization

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }

  // MARK: - LearnedPreferencesStoring

  /// Carrega as preferências aprendidas do UserDefaults
  /// Retorna preferências vazias se não existir ou houver erro de decode
  func load() -> LearnedPreferences {
    guard let data = userDefaults.data(forKey: userDefaultsKey) else {
      return LearnedPreferences.empty()
    }

    do {
      let prefs = try JSONDecoder().decode(LearnedPreferences.self, from: data)

      // Verificar se precisa de migração
      if prefs.version < LearnedPreferences.currentVersion {
        return migrate(prefs)
      }

      return prefs
    } catch {
      print("⚠️ LearnedPreferencesStore: Failed to decode preferences: \(error)")
      return LearnedPreferences.empty()
    }
  }

  /// Salva as preferências aprendidas no UserDefaults
  func save(_ prefs: LearnedPreferences) {
    do {
      let data = try JSONEncoder().encode(prefs)
      userDefaults.set(data, forKey: userDefaultsKey)
    } catch {
      print("⚠️ LearnedPreferencesStore: Failed to encode preferences: \(error)")
    }
  }

  /// Reseta as preferências para o estado inicial (vazio)
  func reset() {
    userDefaults.removeObject(forKey: userDefaultsKey)
  }

  // MARK: - Migration

  /// Migra preferências de versões anteriores para a versão atual
  /// Por enquanto, apenas atualiza a versão (sem transformações de dados)
  private func migrate(_ prefs: LearnedPreferences) -> LearnedPreferences {
    let migratedPrefs = prefs

    // Placeholder para migrações futuras
    // Exemplo de migração de v1 para v2:
    // if prefs.version == 1 {
    //   // Aplicar transformações necessárias
    //   migratedPrefs.version = 2
    // }

    // Salvar após migração
    save(migratedPrefs)

    return migratedPrefs
  }
}

// MARK: - Convenience Extensions

extension LearnedPreferencesStore {
  /// Atualiza os pesos com base em uma avaliação
  /// Conveniência que carrega, aplica e salva em uma operação
  func applyRating(
    rating: Int,
    tags: [String],
    category: String
  ) {
    var prefs = load()
    let delta = LearnedPreferences.weightDelta(forRating: rating)

    // Atualizar pesos das tags
    for tag in tags {
      prefs.updateWeight(forTag: tag, delta: delta)
    }

    // Atualizar peso da categoria
    prefs.updateWeight(forCategory: category, delta: delta)

    save(prefs)
  }

  /// Obtém o peso de sorteio para um restaurante
  func getSortingWeight(tags: [String], category: String) -> Double {
    let prefs = load()
    return prefs.sortingWeight(tags: tags, category: category)
  }
}

