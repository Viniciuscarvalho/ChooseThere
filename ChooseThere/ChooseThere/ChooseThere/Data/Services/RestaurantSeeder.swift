//
//  RestaurantSeeder.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData
import OSLog

/// Seeds RestaurantModel from bundled Restaurants.json
enum RestaurantSeeder {
  private static let logger = Logger(subsystem: "ChooseThere", category: "Seeder")

  /// Executes seeding idempotently.
  /// - Parameter context: The `ModelContext` to insert models into.
  static func seedIfNeeded(context: ModelContext) {
    do {
      // Check if already seeded
      let existingDescriptor = FetchDescriptor<RestaurantModel>()
      let existingCount = try context.fetchCount(existingDescriptor)
      if existingCount > 0 {
        logger.info("Seed skipped: \(existingCount) restaurants already exist.")
        return
      }

      // Load JSON from bundle
      guard let url = Bundle.main.url(forResource: "Restaurants", withExtension: "json") else {
        logger.error("Restaurants.json not found in bundle.")
        return
      }
      let data = try Data(contentsOf: url)
      let decoded = try JSONDecoder().decode(RestaurantsResponse.self, from: data)
      logger.info("Parsed \(decoded.restaurants.count) restaurants from JSON.")

      // Insert models
      for dto in decoded.restaurants {
        // Skip if lat/lng missing and log warning
        let latitude = dto.lat ?? 0
        let longitude = dto.lng ?? 0
        if dto.lat == nil || dto.lng == nil {
          logger.warning("Restaurant \(dto.id) missing lat/lng; defaulting to 0.")
        }
        let model = RestaurantModel(
          id: dto.id,
          name: dto.name,
          category: dto.category,
          address: dto.address,
          city: dto.city,
          state: dto.state,
          tags: dto.tags,
          notes: dto.notes,
          externalLink: dto.externalLink,
          lat: latitude,
          lng: longitude,
          isFavorite: false
        )
        context.insert(model)
      }
      try context.save()
      logger.info("Seed completed: \(decoded.restaurants.count) restaurants inserted.")
    } catch {
      logger.error("Seed failed: \(error.localizedDescription)")
    }
  }
}

