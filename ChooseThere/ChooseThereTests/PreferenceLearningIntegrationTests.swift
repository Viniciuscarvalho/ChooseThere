//
//  PreferenceLearningIntegrationTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

/// Testes de integração que simulam o fluxo completo:
/// aplicar rating → atualizar prefs → usar randomizer com contexto
final class PreferenceLearningIntegrationTests: XCTestCase {
  // MARK: - Properties

  private var learningService: PreferenceLearningService!
  private var prefsStore: LearnedPreferencesStore!
  private var randomizer: RestaurantRandomizer!
  private var testUserDefaults: UserDefaults!

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    testUserDefaults = UserDefaults(suiteName: "test.chooseThere.preferences")!
    testUserDefaults.removePersistentDomain(forName: "test.chooseThere.preferences")

    prefsStore = LearnedPreferencesStore(userDefaults: testUserDefaults)
    learningService = PreferenceLearningService(
      store: prefsStore,
      settingsProvider: { true } // Sempre habilitado para testes
    )
    randomizer = RestaurantRandomizer()
  }

  override func tearDown() {
    testUserDefaults.removePersistentDomain(forName: "test.chooseThere.preferences")
    learningService = nil
    prefsStore = nil
    randomizer = nil
    testUserDefaults = nil
    super.tearDown()
  }

  // MARK: - Integration Tests

  /// Testa o fluxo completo: aplicar rating → carregar prefs → usar no randomizer
  func testIntegration_ApplyRating_UpdatePrefs_UseInRandomizer() {
    // 1. Aplicar avaliação positiva para "sushi"
    learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    // 2. Carregar preferências atualizadas
    let prefs = prefsStore.load()

    // 3. Verificar que os pesos foram atualizados
    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)

    // 4. Criar restaurantes com diferentes match scores
    let restaurants = [
      Restaurant.fixture(id: "sushi-loved", category: "Japonês", tags: ["sushi"]), // Match alto
      Restaurant.fixture(id: "pizza-neutral", category: "Italiano", tags: ["pizza"]) // Match neutro
    ]

    // 5. Criar contexto com preferências aprendidas
    var context = PreferenceContext()
    context.learnedPreferences = prefs

    // 6. Fazer múltiplos sorteios e verificar que "sushi-loved" é favorecido
    var sushiCount = 0
    var pizzaCount = 0

    for _ in 0..<200 {
      if let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if result.id == "sushi-loved" {
          sushiCount += 1
        } else {
          pizzaCount += 1
        }
      }
    }

    // "sushi-loved" tem peso ~2.0 (1 + 1.0), "pizza-neutral" tem peso 1.0
    // Então "sushi-loved" deve ser ~2x mais frequente
    XCTAssertGreaterThan(sushiCount, pizzaCount, "Sushi restaurant should be favored after positive rating")
  }

  /// Testa múltiplas avaliações acumulando pesos
  func testIntegration_MultipleRatings_AccumulateWeights() {
    // Aplicar várias avaliações positivas
    learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês") // +1.0
    learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês") // +1.0
    learningService.applyRating(rating: 4, tags: ["sushi"], category: "Japonês") // +0.5

    let prefs = prefsStore.load()

    // Peso total deve ser 2.5 (1.0 + 1.0 + 0.5)
    XCTAssertEqual(prefs.weight(forTag: "sushi"), 2.5)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 2.5)
  }

  /// Testa avaliações mistas (positivas e negativas) balanceando pesos
  func testIntegration_MixedRatings_BalanceWeights() {
    // Aplicar avaliações mistas
    learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês") // +1.0
    learningService.applyRating(rating: 2, tags: ["sushi"], category: "Japonês") // -0.5
    learningService.applyRating(rating: 4, tags: ["sushi"], category: "Japonês") // +0.5

    let prefs = prefsStore.load()

    // Peso total deve ser 1.0 (1.0 - 0.5 + 0.5)
    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)
  }

  /// Testa que avaliações negativas reduzem probabilidade no randomizer
  func testIntegration_NegativeRating_ReducesProbability() {
    // Aplicar avaliação negativa
    learningService.applyRating(rating: 1, tags: ["fast-food"], category: "Hambúrguer")

    let prefs = prefsStore.load()

    let restaurants = [
      Restaurant.fixture(id: "fast-food-disliked", category: "Hambúrguer", tags: ["fast-food"]),
      Restaurant.fixture(id: "neutral", category: "Outro", tags: ["outro"])
    ]

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    var fastFoodCount = 0
    var neutralCount = 0

    for _ in 0..<200 {
      if let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        if result.id == "fast-food-disliked" {
          fastFoodCount += 1
        } else {
          neutralCount += 1
        }
      }
    }

    // "fast-food-disliked" tem peso ~0.1 (clamped), "neutral" tem peso 1.0
    // Então "neutral" deve ser muito mais frequente
    XCTAssertGreaterThan(neutralCount, fastFoodCount * 3, "Neutral restaurant should be favored after negative rating")
  }

  /// Testa que reset limpa os pesos e volta ao comportamento neutro
  func testIntegration_Reset_ClearsWeights() {
    // Aplicar avaliações
    learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    learningService.applyRating(rating: 1, tags: ["fast-food"], category: "Hambúrguer")

    var prefs = prefsStore.load()
    XCTAssertNotEqual(prefs.weight(forTag: "sushi"), 0.0)
    XCTAssertNotEqual(prefs.weight(forTag: "fast-food"), 0.0)

    // Reset
    prefsStore.reset()

    prefs = prefsStore.load()
    XCTAssertEqual(prefs.weight(forTag: "sushi"), 0.0)
    XCTAssertEqual(prefs.weight(forTag: "fast-food"), 0.0)

    // Após reset, randomizer deve se comportar de forma neutra
    let restaurants = [
      Restaurant.fixture(id: "a", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "b", category: "Hambúrguer", tags: ["fast-food"])
    ]

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    var found: Set<String> = []
    for _ in 0..<100 {
      if let result = randomizer.pick(from: restaurants, context: context, excludeRestaurantIDs: []) {
        found.insert(result.id)
      }
    }

    // Ambos devem ser escolhíveis (comportamento neutro)
    XCTAssertTrue(found.contains("a"))
    XCTAssertTrue(found.contains("b"))
  }

  /// Testa que múltiplas tags são atualizadas corretamente
  func testIntegration_MultipleTags_AllUpdated() {
    learningService.applyRating(
      rating: 5,
      tags: ["sushi", "premium", "omakase"],
      category: "Japonês"
    )

    let prefs = prefsStore.load()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(prefs.weight(forTag: "premium"), 1.0)
    XCTAssertEqual(prefs.weight(forTag: "omakase"), 1.0)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)
  }

  /// Testa determinismo com RNG fixo após aplicar ratings
  func testIntegration_DeterministicWithFixedRNG() {
    // Aplicar avaliação
    learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    let prefs = prefsStore.load()

    let restaurants = [
      Restaurant.fixture(id: "a", category: "Japonês", tags: ["sushi"]),
      Restaurant.fixture(id: "b", category: "Italiano", tags: ["pizza"]),
      Restaurant.fixture(id: "c", category: "Brasileiro", tags: ["churrasco"])
    ]

    var context = PreferenceContext()
    context.learnedPreferences = prefs

    // Usar RNG com seed fixo
    var rng1 = SeededRandomNumberGenerator(seed: 42)
    var rng2 = SeededRandomNumberGenerator(seed: 42)

    let randomizer1 = RestaurantRandomizer(rng: rng1)
    let randomizer2 = RestaurantRandomizer(rng: rng2)

    let result1 = randomizer1.pick(from: restaurants, context: context, excludeRestaurantIDs: [])
    let result2 = randomizer2.pick(from: restaurants, context: context, excludeRestaurantIDs: [])

    // Mesmo seed deve produzir mesmo resultado
    XCTAssertEqual(result1?.id, result2?.id, "Same seed should produce same result after applying ratings")
  }

  /// Testa que clamp funciona corretamente após muitas avaliações
  func testIntegration_Clamp_RespectsLimits() {
    // Aplicar muitas avaliações positivas
    for _ in 1...20 {
      learningService.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    }

    let prefs = prefsStore.load()

    // Peso deve estar no máximo (clamp)
    XCTAssertEqual(prefs.weight(forTag: "sushi"), LearnedPreferences.maxWeight)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), LearnedPreferences.maxWeight)

    // Aplicar muitas avaliações negativas
    for _ in 1...20 {
      learningService.applyRating(rating: 1, tags: ["fast-food"], category: "Hambúrguer")
    }

    let updatedPrefs = prefsStore.load()

    // Peso deve estar no mínimo (clamp)
    XCTAssertEqual(updatedPrefs.weight(forTag: "fast-food"), LearnedPreferences.minWeight)
    XCTAssertEqual(updatedPrefs.weight(forCategory: "hambúrguer"), LearnedPreferences.minWeight)
  }
}

// MARK: - Seeded RNG Helper

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
  private var seed: UInt64

  init(seed: UInt64 = 0) {
    self.seed = seed
  }

  mutating func next() -> UInt64 {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return seed
  }
}

