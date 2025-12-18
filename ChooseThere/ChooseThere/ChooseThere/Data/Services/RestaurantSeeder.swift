//
//  RestaurantSeeder.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import SwiftData
import OSLog

// Helper class to find bundle
private class BundleFinder {}

/// Seeds RestaurantModel from bundled Restaurants.json
enum RestaurantSeeder {
  private static let logger = Logger(subsystem: "ChooseThere", category: "Seeder")

  /// Executes seeding idempotently.
  /// - Parameter context: The `ModelContext` to insert models into.
  static func seedIfNeeded(context: ModelContext) {
    do {
      // Check if already seeded with all data (115+ restaurants from JSON)
      let existingDescriptor = FetchDescriptor<RestaurantModel>()
      let existingCount = try context.fetchCount(existingDescriptor)

      // Only skip if we have the full set (100+ restaurants)
      if existingCount >= 100 {
        logger.info("Seed skipped: \(existingCount) restaurants already exist.")
        return
      }

      // If incomplete, force reseed
      if existingCount > 0 && existingCount < 100 {
        logger.info("Incomplete data detected (\(existingCount)). Forcing reseed...")
        forceReseed(context: context)
        return
      }

      // First run: seed from JSON
      seedFromJSON(context: context)
    } catch {
      logger.error("Seed check failed: \(error.localizedDescription)")
      seedFromJSON(context: context)
    }
  }

  /// Forces a complete reseed, deleting all existing data
  static func forceReseed(context: ModelContext) {
    do {
      // Delete all existing restaurants
      let existingDescriptor = FetchDescriptor<RestaurantModel>()
      let existing = try context.fetch(existingDescriptor)
      logger.info("Force reseed: Deleting \(existing.count) existing restaurants...")
      for r in existing {
        context.delete(r)
      }
      try context.save()

      // Now seed fresh
      seedFromJSON(context: context)
    } catch {
      logger.error("Force reseed failed: \(error.localizedDescription)")
    }
  }

  /// Seeds from JSON file - tries multiple locations
  private static func seedFromJSON(context: ModelContext) {
    do {
      var data: Data?

      // Try 1: Bundle main
      if let bundleUrl = Bundle.main.url(forResource: "Restaurants", withExtension: "json") {
        data = try? Data(contentsOf: bundleUrl)
        if data != nil {
          logger.info("Loaded Restaurants.json from main bundle.")
        }
      }

      // Try 2: Bundle for class
      if data == nil, let bundleUrl = Bundle(for: BundleFinder.self).url(forResource: "Restaurants", withExtension: "json") {
        data = try? Data(contentsOf: bundleUrl)
        if data != nil {
          logger.info("Loaded Restaurants.json from class bundle.")
        }
      }

      // Try 3: Search in all bundles
      if data == nil {
        for bundle in Bundle.allBundles {
          if let url = bundle.url(forResource: "Restaurants", withExtension: "json") {
            data = try? Data(contentsOf: url)
            if data != nil {
              logger.info("Loaded Restaurants.json from bundle: \(bundle.bundlePath)")
              break
            }
          }
        }
      }

      guard let jsonData = data else {
        logger.warning("Restaurants.json not found in any bundle. Using embedded data.")
        seedFromEmbeddedData(context: context)
        return
      }

      let decoded = try JSONDecoder().decode(RestaurantsResponse.self, from: jsonData)
      logger.info("Parsed \(decoded.restaurants.count) restaurants from JSON.")

      // Insert models
      for dto in decoded.restaurants {
        let latitude = dto.lat ?? 0
        let longitude = dto.lng ?? 0
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
      logger.info("JSON seed completed: \(decoded.restaurants.count) restaurants inserted.")
    } catch {
      logger.error("JSON seed failed: \(error.localizedDescription)")
      seedFromEmbeddedData(context: context)
    }
  }

  /// Fallback seeding with embedded restaurant data
  private static func seedFromEmbeddedData(context: ModelContext) {
    let embeddedRestaurants: [(id: String, name: String, category: String, address: String, tags: [String], lat: Double, lng: Double)] = [
      ("izakaya-matsu", "Izakaya Matsu", "bar", "Rua Pedroso de Morais, 403", ["bar", "izakaya", "japanese", "drinks"], -23.5648, -46.6933),
      ("aizome", "Aizomê", "restaurant", "Alameda Fernão Cardim, 70", ["japanese", "sushi", "fine-dining", "omakase"], -23.5704, -46.6502),
      ("la-pizza-della-nonna", "La Pizza della Nonna", "restaurant", "Rua Haddock Lobo, 1240", ["italian", "pizza", "casual"], -23.5549, -46.6636),
      ("mocoto", "Mocotó", "restaurant", "Av. Nossa Senhora do Loreto, 1100", ["brazilian", "nordestino", "comfort-food"], -23.4904, -46.5891),
      ("mani", "Maní", "restaurant", "Rua Joaquim Antunes, 210", ["brazilian", "contemporary", "fine-dining"], -23.5653, -46.6797),
      ("beco-do-batman", "Bar do Beco", "bar", "Rua Gonçalo Afonso, 87", ["bar", "drinks", "craft-beer", "casual"], -23.5555, -46.6862),
      ("jiquitaia", "Jiquitaia", "restaurant", "Rua Antonio Carlos, 268", ["brazilian", "contemporary", "tasting-menu"], -23.5525, -46.6675),
      ("tanit", "Tanit", "restaurant", "Rua General Mena Barreto, 765", ["mediterranean", "lebanese", "middle-eastern"], -23.5774, -46.6671),
      ("a-casa-do-porco", "A Casa do Porco", "restaurant", "Rua Araújo, 124", ["brazilian", "pork", "fine-dining", "meat"], -23.5416, -46.6455),
      ("astor", "Astor", "bar", "Rua Delfina, 163", ["bar", "cocktails", "drinks", "upscale"], -23.5555, -46.6857),
      ("ramen-kazu", "Ramen Kazu", "restaurant", "Rua Thomaz Gonzaga, 84", ["japanese", "ramen", "casual", "noodles"], -23.5556, -46.6395),
      ("tordesilhas", "Tordesilhas", "restaurant", "Alameda Tietê, 489", ["brazilian", "regional", "comfort-food"], -23.5539, -46.6678),
      ("meats", "Meats", "restaurant", "Rua Fradique Coutinho, 1460", ["american", "burger", "bbq", "meat"], -23.5611, -46.6913),
      ("tuju", "Tuju", "restaurant", "Rua Fradique Coutinho, 1248", ["brazilian", "fine-dining", "contemporary", "tasting-menu"], -23.5604, -46.6896),
      ("bar-da-dona-onca", "Bar da Dona Onça", "bar", "Av. Ipiranga, 200", ["bar", "brazilian", "boteco", "drinks"], -23.5453, -46.6438),
      ("sushi-leblon", "Sushi Leblon", "restaurant", "Rua Dias Ferreira, 256", ["japanese", "sushi", "upscale"], -23.5649, -46.6927),
      ("koya", "Koya", "restaurant", "Rua Wisard, 419", ["japanese", "ramen", "izakaya", "noodles"], -23.5574, -46.6870),
      ("pi-burger", "Pi Burger", "restaurant", "Rua Girassol, 381", ["american", "burger", "casual"], -23.5586, -46.6869),
      ("sal-gastronomia", "Sal Gastronomia", "restaurant", "Rua Minas Gerais, 352", ["brazilian", "contemporary", "upscale"], -23.5571, -46.6529),
      ("frank-bar", "Frank Bar", "bar", "Rua Aspicuelta, 599", ["bar", "cocktails", "speakeasy", "drinks"], -23.5582, -46.6879)
    ]

    do {
      for r in embeddedRestaurants {
        let model = RestaurantModel(
          id: r.id,
          name: r.name,
          category: r.category,
          address: r.address,
          city: "São Paulo",
          state: "SP",
          tags: r.tags,
          notes: "",
          externalLink: nil,
          lat: r.lat,
          lng: r.lng,
          isFavorite: false
        )
        context.insert(model)
      }
      try context.save()
      logger.info("Embedded seed completed: \(embeddedRestaurants.count) restaurants inserted.")
    } catch {
      logger.error("Embedded seed failed: \(error.localizedDescription)")
    }
  }
}
