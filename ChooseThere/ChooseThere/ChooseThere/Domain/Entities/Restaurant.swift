//
//  Restaurant.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

struct Restaurant: Identifiable, Equatable, Hashable {
  let id: String
  var name: String
  var category: String
  var address: String
  var city: String
  var state: String
  var tags: [String]
  var notes: String
  var externalLink: URL?
  var lat: Double
  var lng: Double
  var isFavorite: Bool
}

// MARK: - Mapping

extension Restaurant {
  init(from model: RestaurantModel) {
    self.id = model.id
    self.name = model.name
    self.category = model.category
    self.address = model.address
    self.city = model.city
    self.state = model.state
    self.tags = model.tags
    self.notes = model.notes
    if let linkStr = model.externalLink {
      self.externalLink = URL(string: linkStr)
    } else {
      self.externalLink = nil
    }
    self.lat = model.lat
    self.lng = model.lng
    self.isFavorite = model.isFavorite
  }
}


