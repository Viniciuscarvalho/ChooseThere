//
//  RatingViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class RatingViewModel {
  // MARK: - Quick Tags

  static let quickTags: [String] = [
    "Voltaria",
    "Bom custo-benefício",
    "Ambiente agradável",
    "Atendimento excelente",
    "Comida incrível",
    "Demorou",
    "Decepcionante"
  ]

  // MARK: - State

  var rating: Int = 0 // 1-5
  var isMatch: Bool = false
  var wouldReturn: Bool = true
  var selectedTags: Set<String> = []
  var note: String = ""

  private(set) var isSaving = false
  private(set) var errorMessage: String?

  let restaurantId: String
  private let visitRepository: any VisitRepository
  private let ratingAggregator: RestaurantRatingAggregator?
  private let preferenceLearningService: PreferenceLearning
  private let restaurantRepository: any RestaurantRepository

  init(
    restaurantId: String,
    visitRepository: any VisitRepository,
    ratingAggregator: RestaurantRatingAggregator? = nil,
    preferenceLearningService: PreferenceLearning = PreferenceLearningService.makeDefault(),
    restaurantRepository: any RestaurantRepository
  ) {
    self.restaurantId = restaurantId
    self.visitRepository = visitRepository
    self.ratingAggregator = ratingAggregator
    self.preferenceLearningService = preferenceLearningService
    self.restaurantRepository = restaurantRepository
  }

  // MARK: - Actions

  func toggleTag(_ tag: String) {
    if selectedTags.contains(tag) {
      selectedTags.remove(tag)
    } else {
      selectedTags.insert(tag)
    }
  }

  var canSave: Bool {
    rating >= 1 && rating <= 5
  }

  func save() -> Bool {
    guard canSave else {
      errorMessage = "Selecione uma nota de 1 a 5."
      return false
    }

    isSaving = true
    errorMessage = nil

    let visit = Visit(
      id: UUID(),
      restaurantId: restaurantId,
      dateVisited: Date(),
      rating: rating,
      tags: Array(selectedTags),
      note: note.isEmpty ? nil : note,
      isMatch: isMatch,
      wouldReturn: wouldReturn
    )

    do {
      try visitRepository.add(visit)
      
      // Atualizar snapshot de rating do restaurante
      ratingAggregator?.updateSnapshot(for: restaurantId)
      
      // Aplicar aprendizado de preferências (assíncrono, não bloqueia o fluxo)
      applyPreferenceLearning(visit: visit)
      
      isSaving = false
      return true
    } catch {
      errorMessage = "Não foi possível salvar. Tente novamente."
      isSaving = false
      return false
    }
  }

  // MARK: - Preference Learning

  /// Aplica aprendizado de preferências baseado na avaliação
  /// Executado de forma assíncrona e não bloqueia o fluxo de salvamento
  private func applyPreferenceLearning(visit: Visit) {
    Task {
      do {
        // Buscar dados do restaurante para obter categoria e tags
        guard let restaurant = try restaurantRepository.fetch(id: restaurantId) else {
          // Se não encontrar o restaurante, não aplica aprendizado
          // Mas não falha o fluxo de avaliação
          return
        }

        // Aplicar aprendizado com os dados do restaurante
        // O serviço já verifica internamente se learningEnabled está ativo
        preferenceLearningService.applyRating(
          rating: visit.rating,
          tags: restaurant.tags,
          category: restaurant.category
        )
      } catch {
        // Falha silenciosa: não queremos que erro no aprendizado quebre a avaliação
        // Log para debug (opcional)
        print("⚠️ RatingViewModel: Failed to apply preference learning: \(error)")
      }
    }
  }
}



