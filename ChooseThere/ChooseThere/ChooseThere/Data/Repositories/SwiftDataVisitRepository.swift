//
//  SwiftDataVisitRepository.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData

final class SwiftDataVisitRepository: VisitRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func add(_ visit: Visit) throws {
    let model = VisitModel(
      id: visit.id,
      restaurantId: visit.restaurantId,
      dateVisited: visit.dateVisited,
      rating: visit.rating,
      tags: visit.tags,
      note: visit.note,
      isMatch: visit.isMatch,
      wouldReturn: visit.wouldReturn
    )
    context.insert(model)
    try context.save()
  }

  func update(_ visit: Visit) throws {
    let targetId = visit.id
    var descriptor = FetchDescriptor<VisitModel>(predicate: #Predicate { $0.id == targetId })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    model.restaurantId = visit.restaurantId
    model.dateVisited = visit.dateVisited
    model.rating = visit.rating
    model.tags = visit.tags
    model.note = visit.note
    model.isMatch = visit.isMatch
    model.wouldReturn = visit.wouldReturn
    try context.save()
  }

  func fetchAll() throws -> [Visit] {
    let descriptor = FetchDescriptor<VisitModel>(sortBy: [SortDescriptor(\VisitModel.dateVisited, order: .reverse)])
    return try context.fetch(descriptor).map { Visit(from: $0) }
  }

  func fetchVisits(for restaurantId: String) throws -> [Visit] {
    let descriptor = FetchDescriptor<VisitModel>(predicate: #Predicate { $0.restaurantId == restaurantId })
    return try context.fetch(descriptor).map { Visit(from: $0) }
  }
}

