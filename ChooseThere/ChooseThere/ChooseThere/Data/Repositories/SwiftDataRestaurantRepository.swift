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
  
  // MARK: - Location Enrichment
  
  func updateApplePlaceData(
    id: String,
    lat: Double,
    lng: Double,
    applePlaceName: String?,
    applePlaceAddress: String?
  ) throws {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    
    model.lat = lat
    model.lng = lng
    model.applePlaceResolved = true
    model.applePlaceResolvedAt = Date()
    model.applePlaceName = applePlaceName
    model.applePlaceAddress = applePlaceAddress
    
    try context.save()
  }
  
  func markApplePlaceUnresolved(id: String) throws {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    
    model.applePlaceResolved = false
    model.applePlaceResolvedAt = Date()
    model.applePlaceName = nil
    model.applePlaceAddress = nil
    
    try context.save()
  }
  
  // MARK: - Rating Snapshot
  
  func updateRatingSnapshot(
    id: String,
    average: Double,
    count: Int,
    lastVisitedAt: Date?
  ) throws {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    
    model.ratingAverage = average
    model.ratingCount = count
    model.ratingLastVisitedAt = lastVisitedAt
    
    try context.save()
  }
  
  // MARK: - Queries
  
  func fetchUnresolvedLocations() throws -> [Restaurant] {
    let descriptor = FetchDescriptor<RestaurantModel>(
      predicate: #Predicate { $0.applePlaceResolved == false },
      sortBy: [SortDescriptor(\RestaurantModel.name)]
    )
    let models = try context.fetch(descriptor)
    return models.map { Restaurant(from: $0) }
  }
  
  // MARK: - External Links
  
  func updateExternalLinks(
    id: String,
    tripAdvisorURL: URL?,
    iFoodURL: URL?,
    ride99URL: URL?,
    imageURL: URL?
  ) throws {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    
    model.tripAdvisorURL = tripAdvisorURL?.absoluteString
    model.iFoodURL = iFoodURL?.absoluteString
    model.ride99URL = ride99URL?.absoluteString
    model.imageURL = imageURL?.absoluteString
    
    try context.save()
  }
  
  func updateExternalLink(id: String, externalLink: URL?) throws {
    var descriptor = FetchDescriptor<RestaurantModel>(predicate: #Predicate { $0.id == id })
    descriptor.fetchLimit = 1
    guard let model = try context.fetch(descriptor).first else { return }
    
    model.externalLink = externalLink?.absoluteString
    
    try context.save()
  }
}



