//
//  SwiftDataRestaurantRepository.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData

final class SwiftDataRestaurantRepository: RestaurantRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetchAll() throws -> [Restaurant] {
    let descriptor = FetchDescriptor<RestaurantModel>(sortBy: [SortDescriptor(\RestaurantModel.name)])
    let models = try context.fetch(descriptor)
    return models.map { Restaurant(from: $0) }
  }

  func fetch(id: String) throws -> Restaurant? {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return nil }
    return Restaurant(from: model)
  }

  func setFavorite(id: String, isFavorite: Bool) throws {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    model.isFavorite = isFavorite
    try context.save()
  }
}

