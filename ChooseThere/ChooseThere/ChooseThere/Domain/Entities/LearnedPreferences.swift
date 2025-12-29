//
//  LearnedPreferences.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Foundation

// MARK: - LearnedPreferences

/// Modelo que armazena os pesos aprendidos de preferências do usuário.
/// Usado para ajustar probabilidades de sorteio com base em avaliações anteriores.
struct LearnedPreferences: Codable, Equatable {
  // MARK: - Properties

  /// Versão do schema para migrações futuras
  let version: Int

  /// Pesos aprendidos por tag (ex: "sushi" → 2.5, "hambúrguer" → -1.0)
  /// Valores positivos indicam preferência, negativos indicam aversão
  var tagWeights: [String: Double]

  /// Pesos aprendidos por categoria (ex: "Japonês" → 3.0, "Fast Food" → -0.5)
  var categoryWeights: [String: Double]

  /// Data da última atualização dos pesos
  var updatedAt: Date

  // MARK: - Constants

  /// Versão atual do schema
  static let currentVersion = 1

  /// Peso mínimo permitido (clamp)
  static let minWeight: Double = -5.0

  /// Peso máximo permitido (clamp)
  static let maxWeight: Double = 5.0

  /// Peso padrão para itens novos (neutro)
  static let defaultWeight: Double = 0.0

  // MARK: - Initialization

  /// Cria um novo `LearnedPreferences` com valores padrão (sem preferências aprendidas)
  static func empty() -> LearnedPreferences {
    LearnedPreferences(
      version: currentVersion,
      tagWeights: [:],
      categoryWeights: [:],
      updatedAt: Date()
    )
  }

  init(
    version: Int = LearnedPreferences.currentVersion,
    tagWeights: [String: Double] = [:],
    categoryWeights: [String: Double] = [:],
    updatedAt: Date = Date()
  ) {
    self.version = version
    self.tagWeights = tagWeights
    self.categoryWeights = categoryWeights
    self.updatedAt = updatedAt
  }

  // MARK: - Weight Access

  /// Retorna o peso de uma tag (0.0 se não existir)
  func weight(forTag tag: String) -> Double {
    tagWeights[tag.lowercased()] ?? Self.defaultWeight
  }

  /// Retorna o peso de uma categoria (0.0 se não existir)
  func weight(forCategory category: String) -> Double {
    categoryWeights[category.lowercased()] ?? Self.defaultWeight
  }

  // MARK: - Weight Update

  /// Atualiza o peso de uma tag, aplicando clamp
  mutating func updateWeight(forTag tag: String, delta: Double) {
    let normalizedTag = tag.lowercased()
    let currentWeight = tagWeights[normalizedTag] ?? Self.defaultWeight
    let newWeight = Self.clampWeight(currentWeight + delta)
    tagWeights[normalizedTag] = newWeight
    updatedAt = Date()
  }

  /// Atualiza o peso de uma categoria, aplicando clamp
  mutating func updateWeight(forCategory category: String, delta: Double) {
    let normalizedCategory = category.lowercased()
    let currentWeight = categoryWeights[normalizedCategory] ?? Self.defaultWeight
    let newWeight = Self.clampWeight(currentWeight + delta)
    categoryWeights[normalizedCategory] = newWeight
    updatedAt = Date()
  }

  /// Define o peso de uma tag diretamente, aplicando clamp
  mutating func setWeight(forTag tag: String, weight: Double) {
    let normalizedTag = tag.lowercased()
    tagWeights[normalizedTag] = Self.clampWeight(weight)
    updatedAt = Date()
  }

  /// Define o peso de uma categoria diretamente, aplicando clamp
  mutating func setWeight(forCategory category: String, weight: Double) {
    let normalizedCategory = category.lowercased()
    categoryWeights[normalizedCategory] = Self.clampWeight(weight)
    updatedAt = Date()
  }

  // MARK: - Score Calculation

  /// Calcula o score de match para um restaurante baseado em seus tags e categoria
  /// Retorna um valor que pode ser negativo, zero ou positivo
  func matchScore(tags: [String], category: String) -> Double {
    var score = 0.0

    // Soma os pesos das tags
    for tag in tags {
      score += weight(forTag: tag)
    }

    // Adiciona o peso da categoria
    score += weight(forCategory: category)

    return score
  }

  /// Converte o score em um peso positivo para uso no sorteio ponderado
  /// Usa a fórmula: weight = max(0.1, 1.0 + score)
  /// Isso garante que todos os itens têm chance > 0 de serem sorteados
  func sortingWeight(tags: [String], category: String) -> Double {
    let score = matchScore(tags: tags, category: category)
    return max(0.1, 1.0 + score)
  }

  // MARK: - Helpers

  /// Aplica clamp ao peso para manter dentro dos limites
  static func clampWeight(_ weight: Double) -> Double {
    min(maxWeight, max(minWeight, weight))
  }

  /// Verifica se existem preferências aprendidas
  var hasLearnedPreferences: Bool {
    !tagWeights.isEmpty || !categoryWeights.isEmpty
  }

  /// Número total de pesos aprendidos
  var totalWeightsCount: Int {
    tagWeights.count + categoryWeights.count
  }
}

// MARK: - Rating Delta Calculation

extension LearnedPreferences {
  /// Regras de ajuste de peso baseadas na avaliação
  /// Rating 5: +1.0 (muito positivo)
  /// Rating 4: +0.5 (positivo)
  /// Rating 3: 0.0 (neutro)
  /// Rating 2: -0.5 (negativo)
  /// Rating 1: -1.0 (muito negativo)
  static func weightDelta(forRating rating: Int) -> Double {
    switch rating {
    case 5: return 1.0
    case 4: return 0.5
    case 3: return 0.0
    case 2: return -0.5
    case 1: return -1.0
    default:
      // Clamp para valores fora do range esperado
      if rating > 5 {
        return 1.0
      } else {
        return -1.0
      }
    }
  }
}

