//
//  RestaurantRepository.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

/// Contract for restaurant data access (Domain layer)
protocol RestaurantRepository {
  /// Fetch all restaurants
  func fetchAll() throws -> [Restaurant]
  /// Fetch a single restaurant by its stable id
  func fetch(id: String) throws -> Restaurant?
  /// Set the favorite status for a restaurant
  func setFavorite(id: String, isFavorite: Bool) throws
}

