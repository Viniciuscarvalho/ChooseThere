//
//  VisitRepository.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

/// Contract for visit/rating data access (Domain layer)
protocol VisitRepository {
  /// Add a new visit
  func add(_ visit: Visit) throws
  /// Update an existing visit
  func update(_ visit: Visit) throws
  /// Fetch all visits ordered by date descending
  func fetchAll() throws -> [Visit]
  /// Fetch all visits for a specific restaurant
  func fetchVisits(for restaurantId: String) throws -> [Visit]
}

