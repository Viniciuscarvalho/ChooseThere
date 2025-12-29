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
    isFavorite: Bool = false,
    ratingAverage: Double = 0,
    ratingCount: Int = 0
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
      isFavorite: isFavorite,
      applePlaceResolved: false,
      applePlaceResolvedAt: nil,
      applePlaceName: nil,
      applePlaceAddress: nil,
      ratingAverage: ratingAverage,
      ratingCount: ratingCount,
      ratingLastVisitedAt: nil
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
  
  // MARK: - Rating Priority Filter (Only Mode)
  
  func testRatingOnlyModeExcludesUnratedRestaurants() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "unrated", ratingAverage: 0, ratingCount: 0),
      Restaurant.fixture(id: "rated", ratingAverage: 4.5, ratingCount: 3)
    ]
    var context = PreferenceContext()
    context.ratingPriority = .only
    
    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
    
    XCTAssertEqual(result?.id, "rated")
  }
  
  func testRatingOnlyModeExcludesLowRatedRestaurants() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "low-rated", ratingAverage: 3.5, ratingCount: 5),
      Restaurant.fixture(id: "high-rated", ratingAverage: 4.5, ratingCount: 3)
    ]
    var context = PreferenceContext()
    context.ratingPriority = .only
    
    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
    
    XCTAssertEqual(result?.id, "high-rated")
  }
  
  func testRatingOnlyModeReturnsNilWhenNoHighRatedRestaurants() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "low-rated-1", ratingAverage: 3.0, ratingCount: 2),
      Restaurant.fixture(id: "low-rated-2", ratingAverage: 2.5, ratingCount: 1),
      Restaurant.fixture(id: "unrated", ratingAverage: 0, ratingCount: 0)
    ]
    var context = PreferenceContext()
    context.ratingPriority = .only
    
    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
    
    XCTAssertNil(result)
  }
  
  // MARK: - Rating Priority Prefer Mode
  
  func testRatingPreferModeIncludesAllRestaurants() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "unrated"),
      Restaurant.fixture(id: "low-rated", ratingAverage: 3.0, ratingCount: 1),
      Restaurant.fixture(id: "high-rated", ratingAverage: 4.5, ratingCount: 3)
    ]
    var context = PreferenceContext()
    context.ratingPriority = .prefer
    
    // In prefer mode, all should be candidates (with weighted probability)
    var foundUnrated = false
    var foundLowRated = false
    var foundHighRated = false
    
    for _ in 0..<200 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        switch r.id {
        case "unrated": foundUnrated = true
        case "low-rated": foundLowRated = true
        case "high-rated": foundHighRated = true
        default: break
        }
      }
    }
    
    XCTAssertTrue(foundUnrated, "Unrated should be pickable in prefer mode")
    XCTAssertTrue(foundLowRated, "Low rated should be pickable in prefer mode")
    XCTAssertTrue(foundHighRated, "High rated should be pickable in prefer mode")
  }
  
  func testRatingPreferModeFavorsHighRatedRestaurants() {
    // Using seeded RNG for deterministic results
    var rng = SeededRandomNumberGenerator(seed: 12345)
    let randomizer = RestaurantRandomizer(rng: rng)
    
    let restaurants = [
      Restaurant.fixture(id: "unrated"),
      Restaurant.fixture(id: "high-rated", ratingAverage: 4.5, ratingCount: 5)
    ]
    var context = PreferenceContext()
    context.ratingPriority = .prefer
    
    // High-rated should be picked more often due to 3x weight
    var highRatedCount = 0
    var unratedCount = 0
    
    for _ in 0..<100 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "high-rated" { highRatedCount += 1 }
        else { unratedCount += 1 }
      }
    }
    
    // With 3x weight, high-rated should be picked ~75% of the time (3 / (3+1))
    // We use a generous threshold to avoid flaky tests
    XCTAssertGreaterThan(highRatedCount, unratedCount, "High-rated should be picked more often")
  }
  
  // MARK: - Rating None Mode
  
  func testRatingNoneModeIncludesAllWithEqualProbability() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", ratingAverage: 0, ratingCount: 0),
      Restaurant.fixture(id: "b", ratingAverage: 4.5, ratingCount: 10),
      Restaurant.fixture(id: "c", ratingAverage: 2.0, ratingCount: 5)
    ]
    var context = PreferenceContext()
    context.ratingPriority = .none
    
    // All should be candidates
    var found: Set<String> = []
    for _ in 0..<100 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        found.insert(r.id)
      }
    }
    
    XCTAssertEqual(found, ["a", "b", "c"], "All restaurants should be pickable in none mode")
  }
  
  // MARK: - Rating Combined with Other Filters
  
  func testRatingOnlyModeCombinedWithTagFilter() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "japanese-high", tags: ["japanese"], ratingAverage: 4.5, ratingCount: 3),
      Restaurant.fixture(id: "japanese-low", tags: ["japanese"], ratingAverage: 3.0, ratingCount: 2),
      Restaurant.fixture(id: "italian-high", tags: ["italian"], ratingAverage: 5.0, ratingCount: 10)
    ]
    var context = PreferenceContext()
    context.desiredTags = ["japanese"]
    context.ratingPriority = .only

    let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result?.id, "japanese-high")
  }

  // MARK: - Learned Preferences (Match Weighting)

  func testMatchWeighting_NoPreferences_BehavesLikeRandom() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "b", category: "Italiano", tags: ["pizza"]),
      Restaurant.fixture(id: "c", category: "Brasileiro", tags: ["churrasco"])
    ]
    var context = PreferenceContext()
    context.learnedPreferences = nil

    // Sem preferências, todos devem ser candidatos
    var found: Set<String> = []
    for _ in 0..<100 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        found.insert(r.id)
      }
    }

    XCTAssertEqual(found, ["a", "b", "c"], "All restaurants should be pickable without preferences")
  }

  func testMatchWeighting_EmptyPreferences_BehavesLikeRandom() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "a", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "b", category: "Italiano", tags: ["pizza"])
    ]
    var context = PreferenceContext()
    context.learnedPreferences = .empty()

    // Preferências vazias = todos devem ser candidatos com probabilidade igual
    var found: Set<String> = []
    for _ in 0..<100 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        found.insert(r.id)
      }
    }

    XCTAssertEqual(found, ["a", "b"], "All restaurants should be pickable with empty preferences")
  }

  func testMatchWeighting_FavorsHighMatchRestaurants() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "loved", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "neutral", category: "Italiano", tags: ["pizza"])
    ]

    // Criar preferências que favorecem "sushi" e "Japonês"
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 3.0)
    prefs.setWeight(forCategory: "Japonês", weight: 2.0)

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    // O restaurante "loved" deve ser escolhido mais frequentemente
    var lovedCount = 0
    var neutralCount = 0

    for _ in 0..<200 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "loved" { lovedCount += 1 }
        else { neutralCount += 1 }
      }
    }

    // "loved" tem peso ~6.0 (1 + 3 + 2), "neutral" tem peso 1.0
    // Então "loved" deve ser ~6x mais frequente
    XCTAssertGreaterThan(lovedCount, neutralCount * 2, "Loved restaurant should be picked significantly more often")
  }

  func testMatchWeighting_NegativeWeightsReduceProbability() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "disliked", category: "FastFood", tags: ["hamburguer"]),
      Restaurant.fixture(id: "neutral", category: "Outro", tags: ["outro"])
    ]

    // Criar preferências negativas para "hamburguer"
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "hamburguer", weight: -2.0)
    prefs.setWeight(forCategory: "FastFood", weight: -1.0)

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    // O restaurante "neutral" deve ser escolhido mais frequentemente
    var dislikedCount = 0
    var neutralCount = 0

    for _ in 0..<200 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "disliked" { dislikedCount += 1 }
        else { neutralCount += 1 }
      }
    }

    // "disliked" tem peso ~0.1 (clamped: 1 - 2 - 1 = -2, max(0.1, 1 + score) = 0.1)
    // "neutral" tem peso 1.0
    // Então "neutral" deve ser ~10x mais frequente
    XCTAssertGreaterThan(neutralCount, dislikedCount * 3, "Neutral restaurant should be picked significantly more often")
  }

  func testMatchWeighting_DeterministicWithSeededRNG() {
    let restaurants = [
      Restaurant.fixture(id: "a", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "b", category: "Italiano", tags: ["pizza"]),
      Restaurant.fixture(id: "c", category: "Brasileiro", tags: ["churrasco"])
    ]

    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.0)

    var rng1 = SeededRandomNumberGenerator(seed: 42)
    var rng2 = SeededRandomNumberGenerator(seed: 42)

    let randomizer1 = RestaurantRandomizer(rng: rng1)
    let randomizer2 = RestaurantRandomizer(rng: rng2)

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    let result1 = randomizer1.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
    let result2 = randomizer2.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    XCTAssertEqual(result1?.id, result2?.id, "Same seed should produce same result with learned preferences")
  }

  func testMatchWeighting_CombinedWithRatingPriority() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "loved-rated", category: "Japonês", tags: ["sushi"], ratingAverage: 4.5, ratingCount: 5),
      Restaurant.fixture(id: "loved-unrated", category: "Japonês", tags: ["sushi"], ratingAverage: 0, ratingCount: 0),
      Restaurant.fixture(id: "neutral-rated", category: "Outro", tags: ["outro"], ratingAverage: 4.5, ratingCount: 5)
    ]

    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 3.0)
    prefs.setWeight(forCategory: "Japonês", weight: 2.0)

    var context = PreferenceContext()
    context.learnedPreferences = prefs
    context.ratingPriority = .prefer

    // "loved-rated" deve ter o maior peso combinado
    var lovedRatedCount = 0
    var otherCount = 0

    for _ in 0..<300 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "loved-rated" { lovedRatedCount += 1 }
        else { otherCount += 1 }
      }
    }

    // loved-rated: match ~6.0 * rating 3.0 = 18.0
    // loved-unrated: match ~6.0 * rating 1.0 = 6.0
    // neutral-rated: match 1.0 * rating 3.0 = 3.0
    XCTAssertGreaterThan(lovedRatedCount, otherCount / 2, "Loved and rated should dominate picks")
  }

  func testMatchWeighting_WorksWithFilters() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "japanese-sushi", category: "Japonês", tags: ["sushi", "japanese"]),
      Restaurant.fixture(id: "japanese-other", category: "Japonês", tags: ["tempura", "japanese"]),
      Restaurant.fixture(id: "italian", category: "Italiano", tags: ["pizza", "italian"])
    ]

    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 5.0)

    var context = PreferenceContext()
    context.desiredTags = ["japanese"]
    context.learnedPreferences = prefs

    // Apenas restaurantes japoneses são candidatos, mas "sushi" é favorecido
    var sushiCount = 0
    var otherJapaneseCount = 0

    for _ in 0..<200 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "japanese-sushi" { sushiCount += 1 }
        else if r.id == "japanese-other" { otherJapaneseCount += 1 }
        else { XCTFail("Italian should not be picked with japanese filter") }
      }
    }

    XCTAssertGreaterThan(sushiCount, otherJapaneseCount, "Sushi restaurant should be favored due to learned preferences")
  }

  func testMatchWeighting_AllRestaurantsStillHaveChance() {
    let randomizer = RestaurantRandomizer()
    let restaurants = [
      Restaurant.fixture(id: "loved", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "hated", category: "FastFood", tags: ["hamburguer"])
    ]

    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: LearnedPreferences.maxWeight)
    prefs.setWeight(forCategory: "Japonês", weight: LearnedPreferences.maxWeight)
    prefs.setWeight(forTag: "hamburguer", weight: LearnedPreferences.minWeight)
    prefs.setWeight(forCategory: "FastFood", weight: LearnedPreferences.minWeight)

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    // Mesmo com preferências extremas, "hated" ainda deve aparecer ocasionalmente
    // (peso mínimo é 0.1, não 0)
    var lovedCount = 0
    var hatedCount = 0

    for _ in 0..<500 {
      if let r = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if r.id == "loved" { lovedCount += 1 }
        else { hatedCount += 1 }
      }
    }

    XCTAssertGreaterThan(lovedCount, 0, "Loved should be picked")
    XCTAssertGreaterThan(hatedCount, 0, "Even hated should have some chance (min weight 0.1)")
  }
}



