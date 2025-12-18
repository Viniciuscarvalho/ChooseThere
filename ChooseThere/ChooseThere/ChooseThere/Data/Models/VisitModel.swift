//
//  VisitModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData

@Model
final class VisitModel {
  @Attribute(.unique)
  var id: UUID

  var restaurantId: String
  var dateVisited: Date
  var rating: Int
  var tags: [String]
  var note: String?
  var isMatch: Bool
  var wouldReturn: Bool

  init(
    id: UUID = UUID(),
    restaurantId: String,
    dateVisited: Date,
    rating: Int,
    tags: [String],
    note: String?,
    isMatch: Bool,
    wouldReturn: Bool
  ) {
    self.id = id
    self.restaurantId = restaurantId
    self.dateVisited = dateVisited
    self.rating = rating
    self.tags = tags
    self.note = note
    self.isMatch = isMatch
    self.wouldReturn = wouldReturn
  }
}

