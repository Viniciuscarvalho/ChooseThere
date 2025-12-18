//
//  Visit.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

struct Visit: Identifiable, Equatable, Hashable {
  let id: UUID
  var restaurantId: String
  var dateVisited: Date
  var rating: Int // 1–5
  var tags: [String]
  var note: String?
  var isMatch: Bool
  var wouldReturn: Bool
}

// MARK: - Mapping

extension Visit {
  init(from model: VisitModel) {
    self.id = model.id
    self.restaurantId = model.restaurantId
    self.dateVisited = model.dateVisited
    self.rating = model.rating
    self.tags = model.tags
    self.note = model.note
    self.isMatch = model.isMatch
    self.wouldReturn = model.wouldReturn
  }
}

