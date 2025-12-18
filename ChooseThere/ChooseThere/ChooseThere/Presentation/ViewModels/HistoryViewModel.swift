//
//  HistoryViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {
  // MARK: - Filter Options

  enum Filter: String, CaseIterable {
    case all = "Todos"
    case bestRated = "Melhores"
    case wouldReturn = "Voltaria"
    case isMatch = "Match"
  }

  // MARK: - State

  private(set) var visits: [Visit] = []
  private(set) var restaurants: [String: Restaurant] = [:] // id -> Restaurant
  private(set) var isLoading = true
  var selectedFilter: Filter = .all

  var filteredVisits: [Visit] {
    switch selectedFilter {
    case .all:
      return visits
    case .bestRated:
      return visits.filter { $0.rating >= 4 }
    case .wouldReturn:
      return visits.filter { $0.wouldReturn }
    case .isMatch:
      return visits.filter { $0.isMatch }
    }
  }

  var isEmpty: Bool {
    visits.isEmpty
  }

  // MARK: - Dependencies

  private let visitRepository: any VisitRepository
  private let restaurantRepository: any RestaurantRepository

  init(visitRepository: any VisitRepository, restaurantRepository: any RestaurantRepository) {
    self.visitRepository = visitRepository
    self.restaurantRepository = restaurantRepository
  }

  // MARK: - Actions

  func load() {
    isLoading = true
    do {
      visits = try visitRepository.fetchAll()
      let allRestaurants = try restaurantRepository.fetchAll()
      restaurants = Dictionary(uniqueKeysWithValues: allRestaurants.map { ($0.id, $0) })
    } catch {
      visits = []
      restaurants = [:]
    }
    isLoading = false
  }

  func restaurant(for visit: Visit) -> Restaurant? {
    restaurants[visit.restaurantId]
  }
}

