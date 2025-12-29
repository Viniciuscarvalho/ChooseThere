//
//  LearnedPreferencesStoreTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

final class LearnedPreferencesStoreTests: XCTestCase {
  // MARK: - Properties

  private var sut: LearnedPreferencesStore!
  private var testUserDefaults: UserDefaults!

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    testUserDefaults = UserDefaults(suiteName: "LearnedPreferencesStoreTests")!
    testUserDefaults.removePersistentDomain(forName: "LearnedPreferencesStoreTests")
    sut = LearnedPreferencesStore(userDefaults: testUserDefaults)
  }

  override func tearDown() {
    testUserDefaults.removePersistentDomain(forName: "LearnedPreferencesStoreTests")
    testUserDefaults = nil
    sut = nil
    super.tearDown()
  }

  // MARK: - Load Tests

  func testLoad_NoData_ReturnsEmptyPreferences() {
    let prefs = sut.load()

    XCTAssertTrue(prefs.tagWeights.isEmpty)
    XCTAssertTrue(prefs.categoryWeights.isEmpty)
    XCTAssertEqual(prefs.version, LearnedPreferences.currentVersion)
  }

  func testLoad_WithSavedData_ReturnsSavedPreferences() {
    var original = LearnedPreferences.empty()
    original.setWeight(forTag: "sushi", weight: 2.5)
    original.setWeight(forCategory: "japonês", weight: 3.0)
    sut.save(original)

    let loaded = sut.load()

    XCTAssertEqual(loaded.weight(forTag: "sushi"), 2.5)
    XCTAssertEqual(loaded.weight(forCategory: "japonês"), 3.0)
  }

  func testLoad_WithCorruptedData_ReturnsEmptyPreferences() {
    // Salvar dados inválidos diretamente
    testUserDefaults.set("invalid json".data(using: .utf8), forKey: "learnedPreferences")

    let prefs = sut.load()

    XCTAssertTrue(prefs.tagWeights.isEmpty)
    XCTAssertTrue(prefs.categoryWeights.isEmpty)
  }

  // MARK: - Save Tests

  func testSave_PersistsData() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.5)
    sut.save(prefs)

    // Verificar que os dados estão no UserDefaults
    XCTAssertNotNil(testUserDefaults.data(forKey: "learnedPreferences"))
  }

  func testSave_Load_Roundtrip() {
    var original = LearnedPreferences.empty()
    original.setWeight(forTag: "sushi", weight: 2.5)
    original.setWeight(forTag: "pizza", weight: -1.0)
    original.setWeight(forCategory: "japonês", weight: 3.0)
    original.setWeight(forCategory: "italiano", weight: 1.5)

    sut.save(original)
    let loaded = sut.load()

    XCTAssertEqual(loaded.weight(forTag: "sushi"), 2.5)
    XCTAssertEqual(loaded.weight(forTag: "pizza"), -1.0)
    XCTAssertEqual(loaded.weight(forCategory: "japonês"), 3.0)
    XCTAssertEqual(loaded.weight(forCategory: "italiano"), 1.5)
  }

  func testSave_OverwritesPreviousData() {
    var prefs1 = LearnedPreferences.empty()
    prefs1.setWeight(forTag: "sushi", weight: 2.0)
    sut.save(prefs1)

    var prefs2 = LearnedPreferences.empty()
    prefs2.setWeight(forTag: "pizza", weight: 3.0)
    sut.save(prefs2)

    let loaded = sut.load()

    XCTAssertEqual(loaded.weight(forTag: "pizza"), 3.0)
    XCTAssertEqual(loaded.weight(forTag: "sushi"), 0.0) // Não existe mais
  }

  // MARK: - Reset Tests

  func testReset_RemovesData() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.5)
    sut.save(prefs)

    sut.reset()

    XCTAssertNil(testUserDefaults.data(forKey: "learnedPreferences"))
  }

  func testReset_LoadReturnsEmpty() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.5)
    sut.save(prefs)

    sut.reset()
    let loaded = sut.load()

    XCTAssertTrue(loaded.tagWeights.isEmpty)
    XCTAssertTrue(loaded.categoryWeights.isEmpty)
  }

  // MARK: - Apply Rating Tests

  func testApplyRating_Rating5_IncreasesWeights() {
    sut.applyRating(rating: 5, tags: ["sushi", "premium"], category: "Japonês")

    let prefs = sut.load()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(prefs.weight(forTag: "premium"), 1.0)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)
  }

  func testApplyRating_Rating1_DecreasesWeights() {
    sut.applyRating(rating: 1, tags: ["fast-food"], category: "Hambúrguer")

    let prefs = sut.load()

    XCTAssertEqual(prefs.weight(forTag: "fast-food"), -1.0)
    XCTAssertEqual(prefs.weight(forCategory: "hambúrguer"), -1.0)
  }

  func testApplyRating_Rating3_NoChange() {
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    let before = sut.load()

    sut.applyRating(rating: 3, tags: ["sushi"], category: "Japonês")

    let after = sut.load()

    XCTAssertEqual(after.weight(forTag: "sushi"), before.weight(forTag: "sushi"))
    XCTAssertEqual(after.weight(forCategory: "japonês"), before.weight(forCategory: "japonês"))
  }

  func testApplyRating_CumulativeEffect() {
    // Aplicar várias avaliações positivas
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    let prefs = sut.load()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 3.0) // 1.0 + 1.0 + 1.0
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 3.0)
  }

  func testApplyRating_MixedRatings() {
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês") // +1.0
    sut.applyRating(rating: 2, tags: ["sushi"], category: "Japonês") // -0.5
    sut.applyRating(rating: 4, tags: ["sushi"], category: "Japonês") // +0.5

    let prefs = sut.load()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.0) // 1.0 - 0.5 + 0.5
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)
  }

  func testApplyRating_RespectsClamp() {
    // Tentar exceder o limite máximo
    for _ in 1...10 {
      sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    }

    let prefs = sut.load()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), LearnedPreferences.maxWeight)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), LearnedPreferences.maxWeight)
  }

  // MARK: - Get Sorting Weight Tests

  func testGetSortingWeight_NoPreferences_ReturnsOne() {
    let weight = sut.getSortingWeight(tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(weight, 1.0)
  }

  func testGetSortingWeight_PositivePreferences_ReturnsHigherWeight() {
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    let weight = sut.getSortingWeight(tags: ["sushi"], category: "Japonês")

    // 1.0 (base) + 2.0 (sushi) + 2.0 (japonês) = 5.0
    XCTAssertEqual(weight, 5.0)
  }

  func testGetSortingWeight_NegativePreferences_ReturnsLowerWeight() {
    sut.applyRating(rating: 1, tags: ["fast-food"], category: "Hambúrguer")

    let weight = sut.getSortingWeight(tags: ["fast-food"], category: "Hambúrguer")

    // 1.0 (base) + (-1.0) (fast-food) + (-1.0) (hambúrguer) = -1.0, clamped to 0.1
    XCTAssertEqual(weight, 0.1)
  }

  // MARK: - Protocol Conformance

  func testProtocolConformance() {
    let store: LearnedPreferencesStoring = sut

    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.0)

    store.save(prefs)
    let loaded = store.load()

    XCTAssertEqual(loaded.weight(forTag: "sushi"), 2.0)

    store.reset()
    let afterReset = store.load()

    XCTAssertTrue(afterReset.tagWeights.isEmpty)
  }

  // MARK: - Multiple Stores

  func testMultipleStores_ShareSameData() {
    let store1 = LearnedPreferencesStore(userDefaults: testUserDefaults)
    let store2 = LearnedPreferencesStore(userDefaults: testUserDefaults)

    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.5)
    store1.save(prefs)

    let loaded = store2.load()

    XCTAssertEqual(loaded.weight(forTag: "sushi"), 2.5)
  }

  // MARK: - Empty Tags

  func testApplyRating_EmptyTags_OnlyAffectsCategory() {
    sut.applyRating(rating: 5, tags: [], category: "Japonês")

    let prefs = sut.load()

    XCTAssertTrue(prefs.tagWeights.isEmpty)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)
  }

  func testApplyRating_EmptyCategory_OnlyAffectsTags() {
    sut.applyRating(rating: 5, tags: ["sushi"], category: "")

    let prefs = sut.load()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.0)
    // Categoria vazia também é armazenada
    XCTAssertEqual(prefs.weight(forCategory: ""), 1.0)
  }
}

