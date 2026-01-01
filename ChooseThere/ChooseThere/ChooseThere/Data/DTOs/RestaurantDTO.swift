//
//  RestaurantDTO.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

/// DTO para decodificar restaurantes de Restaurants.json
struct RestaurantsResponse: Decodable {
  let restaurants: [RestaurantDTO]
}

struct RestaurantDTO: Decodable {
  let id: String
  let name: String
  let category: String
  let address: String
  let city: String
  let state: String
  let tags: [String]
  let notes: String
  let externalLink: String?
  let lat: Double?
  let lng: Double?
}







