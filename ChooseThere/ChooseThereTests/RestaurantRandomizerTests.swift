//
//  RestaurantRandomizerTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import CoreLocation
import XCTest

@testable import ChooseThere

// MARK: - Deterministic RNG for testing

struct SeededRandomNumberGenerator: RandomNumberGenerator {
  private var seed: UInt64

  init(seed: UInt64 = 0) {
    self.seed = seed
  }

  mutating func next() -> UInt64 {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return seed
  }
}

// MARK: - Test Fixtures

extension Restaurant {
  static func fixture(
    id: String = "test-id",
    name: String = "Test Restaurant",
    category: String = "restaurant",
    tags: [String] = [],
    lat: Double = -23.55,
    lng: Double = -46.63,
    isFavorite: Bool = false
  ) -> Restaurant {
    Restaurant(
      id: id,
      name: name,
      category: category,
      address: "Test Address",
      city: "São Paulo",
      state: "SP",
      tags: tags,
      notes: "",
      externalLink: nil,
      lat: lat,
      lng: lng,
      isFavorite: isFavorite
    )
  }
}

// MARK: - Tests

final class RestaurantRandomizerTests: XCTestCase {

  // MARK: - Basic Selection

  func testPickFromEmptyListReturnsNil() {
    let randomizer = RestaurantRandomizer()
    let context = PreferenceContext()

    let result = randomizer.pick(from: [], context: context, excludeRestaurantIDs: [])

    XCTAssertNil(result)
  }

  func testPickFromSingleRestaurantReturnsThatRestaurant() {
    let randomizer = RestaurantRandomizer()
    let restaurant = Restaurant.fixture(id: "only-one")
    let context = PreferenceContext()

    let result = randomizer.pick(from: [restaurant], context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "only-one")
  }

  // MARK: - Exclusion

  func testExcludedRestaurantsAreNotPicked() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a"),
      Restaurant.fixture(id: "b"),
      Restaurant.fixture(id: "c")
    ]
    let context = PreferenceContext()

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: ["a", "b", "c"])

    XCTAssertNil(result)
  }

  func testExcludingTwoLeavesOnlyOne() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a"),
      Restaurant.fixture(id: "b"),
      Restaurant.fixture(id: "c")
    ]
    let context = PreferenceContext()

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: ["a", "b"])

    XCTAssertEqual(result?.id, "c")
  }

  // MARK: - Desired Tags Filter

  func testDesiredTagsFilterIncludesOnlyMatching() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "japanese", tags: ["japanese", "sushi"]),
      Restaurant.fixture(id: "italian", tags: ["italian", "pasta"]),
      Restaurant.fixture(id: "mexican", tags: ["mexican", "tacos"])
    ]
    var context = PreferenceContext()
    context.desiredTags = ["japanese"]

    // Run multiple times to ensure only japanese is picked
    for _ in 0..<10 {
      let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
      XCTAssertEqual(result?.id, "japanese")
    }
  }

  func testDesiredTagsAreCaseInsensitive() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", tags: ["Japanese"]),
      Restaurant.fixture(id: "b", tags: ["italian"])
    ]
    var context = PreferenceContext()
    context.desiredTags = ["JAPANESE"]

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "a")
  }

  // MARK: - Avoid Tags Filter

  func testAvoidTagsFilterExcludesMatching() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", tags: ["spicy"]),
      Restaurant.fixture(id: "b", tags: ["mild"])
    ]
    var context = PreferenceContext()
    context.avoidTags = ["spicy"]

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "b")
  }

  func testAvoidTagsAreCaseInsensitive() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", tags: ["SPICY"]),
      Restaurant.fixture(id: "b", tags: ["mild"])
    ]
    var context = PreferenceContext()
    context.avoidTags = ["spicy"]

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "b")
  }

  // MARK: - Radius Filter

  func testRadiusFilterExcludesFarRestaurants() {
    let randomizer = RestaurantRandomizer()
    // User at Paulista
    let userLat = -23.5632
    let userLng = -46.6541

    let restaurants = [
      // Close (~1km)
      Restaurant.fixture(id: "close", lat: -23.5650, lng: -46.6550),
      // Far (~10km)
      Restaurant.fixture(id: "far", lat: -23.65, lng: -46.75)
    ]

    var context = PreferenceContext()
    context.radiusKm = 2
    context.userLocation = CLLocationCoordinate2D(latitude: userLat, longitude: userLng)

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "close")
  }

  func testNoRadiusFilterIncludesAll() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", lat: -23.55, lng: -46.63),
      Restaurant.fixture(id: "b", lat: -30.0, lng: -50.0)
    ]
    var context = PreferenceContext()
    context.radiusKm = nil

    // Without radius, both should be candidates
    var foundA = false
    var foundB = false
    for _ in 0..<50 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "a" { foundA = true }
        if r.id == "b" { foundB = true }
      }
    }

    XCTAssertTrue(foundA && foundB, "Both restaurants should be pickable without radius filter")
  }

  // MARK: - Combined Filters

  func testCombinedFiltersWork() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "perfect", tags: ["japanese"], lat: -23.5632, lng: -46.6541),
      Restaurant.fixture(id: "wrong-tag", tags: ["italian"], lat: -23.5632, lng: -46.6541),
      Restaurant.fixture(id: "too-far", tags: ["japanese"], lat: -30.0, lng: -50.0),
      Restaurant.fixture(id: "avoid-tag", tags: ["japanese", "spicy"], lat: -23.5632, lng: -46.6541)
    ]

    var context = PreferenceContext()
    context.desiredTags = ["japanese"]
    context.avoidTags = ["spicy"]
    context.radiusKm = 5
    context.userLocation = CLLocationCoordinate2D(latitude: -23.5632, longitude: -46.6541)

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "perfect")
  }

  // MARK: - Deterministic RNG

  func testDeterministicRNGProducesSameResult() {
    let restaurants = [
      Restaurant.fixture(id: "a"),
      Restaurant.fixture(id: "b"),
      Restaurant.fixture(id: "c"),
      Restaurant.fixture(id: "d"),
      Restaurant.fixture(id: "e")
    ]
    let context = PreferenceContext()

    var rng1 = SeededRandomNumberGenerator(seed: 42)
    var rng2 = SeededRandomNumberGenerator(seed: 42)

    let randomizer1 = RestaurantRandomizer(rng: rng1)
    let randomizer2 = RestaurantRandomizer(rng: rng2)

    let result1 = randomizer1.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
    let result2 = randomizer2.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result1?.id, result2?.id)
  }
}


