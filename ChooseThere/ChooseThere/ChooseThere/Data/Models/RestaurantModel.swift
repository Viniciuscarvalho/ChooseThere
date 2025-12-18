//
//  RestaurantModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData

@Model
final class RestaurantModel {
  @Attribute(.unique)
  var id: String

  var name: String
  var category: String
  var address: String
  var city: String
  var state: String
  var tags: [String]
  var notes: String
  var externalLink: String?
  var lat: Double
  var lng: Double
  var isFavorite: Bool

  init(
    id: String,
    name: String,
    category: String,
    address: String,
    city: String,
    state: String,
    tags: [String],
    notes: String,
    externalLink: String?,
    lat: Double,
    lng: Double,
    isFavorite: Bool = false
  ) {
    self.id = id
    self.name = name
    self.category = category
    self.address = address
    self.city = city
    self.state = state
    self.tags = tags
    self.notes = notes
    self.externalLink = externalLink
    self.lat = lat
    self.lng = lng
    self.isFavorite = isFavorite
  }
}

