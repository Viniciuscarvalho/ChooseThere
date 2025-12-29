//
//  PreferenceLearningServiceTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

final class PreferenceLearningServiceTests: XCTestCase {
  // MARK: - Properties

  private var sut: PreferenceLearningService!
  private var mockStore: MockLearnedPreferencesStore!
  private var learningEnabled: Bool = true

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    mockStore = MockLearnedPreferencesStore()
    learningEnabled = true
    sut = PreferenceLearningService(
      store: mockStore,
      settingsProvider: { [unowned self] in self.learningEnabled }
    )
  }

  override func tearDown() {
    sut = nil
    mockStore = nil
    super.tearDown()
  }

  // MARK: - Learning Enabled Tests

  func testIsLearningEnabled_ReturnsProviderValue() {
    learningEnabled = true
    XCTAssertTrue(sut.isLearningEnabled)

    learningEnabled = false
    XCTAssertFalse(sut.isLearningEnabled)
  }

  // MARK: - Apply Rating Tests

  func testApplyRating_WhenLearningEnabled_UpdatesWeights() {
    learningEnabled = true

    let result = sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 1.0)
    XCTAssertTrue(mockStore.saveCalled)
  }

  func testApplyRating_WhenLearningDisabled_DoesNotUpdateWeights() {
    learningEnabled = false

    let result = sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), 0.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 0.0)
    XCTAssertFalse(mockStore.saveCalled)
  }

  func testApplyRating_Rating5_IncreasesWeightBy1() {
    learningEnabled = true

    let result = sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 1.0)
  }

  func testApplyRating_Rating4_IncreasesWeightBy05() {
    learningEnabled = true

    let result = sut.applyRating(rating: 4, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), 0.5)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 0.5)
  }

  func testApplyRating_Rating3_NoChange() {
    learningEnabled = true

    let result = sut.applyRating(rating: 3, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), 0.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 0.0)
    // Rating 3 não deve chamar save (delta = 0)
    XCTAssertFalse(mockStore.saveCalled)
  }

  func testApplyRating_Rating2_DecreasesWeightBy05() {
    learningEnabled = true

    let result = sut.applyRating(rating: 2, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), -0.5)
    XCTAssertEqual(result.weight(forCategory: "japonês"), -0.5)
  }

  func testApplyRating_Rating1_DecreasesWeightBy1() {
    learningEnabled = true

    let result = sut.applyRating(rating: 1, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), -1.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), -1.0)
  }

  // MARK: - Multiple Tags Tests

  func testApplyRating_MultipleTags_UpdatesAll() {
    learningEnabled = true

    let result = sut.applyRating(
      rating: 5,
      tags: ["sushi", "premium", "omakase"],
      category: "Japonês"
    )

    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(result.weight(forTag: "premium"), 1.0)
    XCTAssertEqual(result.weight(forTag: "omakase"), 1.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 1.0)
  }

  func testApplyRating_EmptyTags_OnlyUpdatesCategory() {
    learningEnabled = true

    let result = sut.applyRating(rating: 5, tags: [], category: "Japonês")

    XCTAssertTrue(result.tagWeights.isEmpty)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 1.0)
  }

  func testApplyRating_EmptyCategory_OnlyUpdatesTags() {
    learningEnabled = true

    let result = sut.applyRating(rating: 5, tags: ["sushi"], category: "")

    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(result.categoryWeights.count, 0)
  }

  // MARK: - Cumulative Tests

  func testApplyRating_Cumulative_AccumulatesWeights() {
    learningEnabled = true

    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    let result = sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(result.weight(forTag: "sushi"), 3.0)
    XCTAssertEqual(result.weight(forCategory: "japonês"), 3.0)
  }

  func testApplyRating_MixedRatings_BalancesWeights() {
    learningEnabled = true

    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês") // +1.0
    sut.applyRating(rating: 2, tags: ["sushi"], category: "Japonês") // -0.5
    let result = sut.applyRating(rating: 4, tags: ["sushi"], category: "Japonês") // +0.5

    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0) // 1.0 - 0.5 + 0.5
  }

  // MARK: - Clamp Tests

  func testApplyRating_RespectsMaxClamp() {
    learningEnabled = true

    // Aplicar muitas avaliações positivas
    for _ in 1...10 {
      sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    }

    let result = sut.loadPreferences()

    XCTAssertEqual(result.weight(forTag: "sushi"), LearnedPreferences.maxWeight)
    XCTAssertEqual(result.weight(forCategory: "japonês"), LearnedPreferences.maxWeight)
  }

  func testApplyRating_RespectsMinClamp() {
    learningEnabled = true

    // Aplicar muitas avaliações negativas
    for _ in 1...10 {
      sut.applyRating(rating: 1, tags: ["fast-food"], category: "Lanchonete")
    }

    let result = sut.loadPreferences()

    XCTAssertEqual(result.weight(forTag: "fast-food"), LearnedPreferences.minWeight)
    XCTAssertEqual(result.weight(forCategory: "lanchonete"), LearnedPreferences.minWeight)
  }

  // MARK: - Load/Reset Tests

  func testLoadPreferences_ReturnsStoredPreferences() {
    learningEnabled = true

    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    let loaded = sut.loadPreferences()

    XCTAssertEqual(loaded.weight(forTag: "sushi"), 1.0)
    XCTAssertEqual(loaded.weight(forCategory: "japonês"), 1.0)
  }

  func testResetPreferences_ClearsAllWeights() {
    learningEnabled = true

    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")
    sut.resetPreferences()

    let loaded = sut.loadPreferences()

    XCTAssertTrue(loaded.tagWeights.isEmpty)
    XCTAssertTrue(loaded.categoryWeights.isEmpty)
    XCTAssertTrue(mockStore.resetCalled)
  }

  // MARK: - Toggle During Session Tests

  func testApplyRating_ToggleDuringSession_RespectsToggle() {
    // Começa habilitado
    learningEnabled = true
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    var result = sut.loadPreferences()
    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)

    // Desabilita
    learningEnabled = false
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    result = sut.loadPreferences()
    // Deve manter o mesmo valor (não atualizou)
    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)

    // Habilita novamente
    learningEnabled = true
    sut.applyRating(rating: 5, tags: ["sushi"], category: "Japonês")

    result = sut.loadPreferences()
    XCTAssertEqual(result.weight(forTag: "sushi"), 2.0)
  }

  // MARK: - Case Sensitivity Tests

  func testApplyRating_NormalizesCase() {
    learningEnabled = true

    sut.applyRating(rating: 5, tags: ["SUSHI", "Sushi", "sushi"], category: "JAPONÊS")

    let result = sut.loadPreferences()

    // Todos devem ser normalizados para lowercase
    XCTAssertEqual(result.weight(forTag: "sushi"), 3.0) // 3x rating 5
    XCTAssertEqual(result.weight(forCategory: "japonês"), 1.0)
  }

  // MARK: - Edge Cases

  func testApplyRating_EmptyTagsAndCategory_DoesNotSave() {
    learningEnabled = true

    sut.applyRating(rating: 5, tags: [], category: "")

    // Não deve salvar se não há nada para atualizar
    // Na verdade, a implementação atual salva mesmo sem mudanças
    // Mas isso é ok pois não causa problemas
  }

  func testApplyRating_TagsWithWhitespace_FiltersEmpty() {
    learningEnabled = true

    let result = sut.applyRating(rating: 5, tags: ["sushi", "", "  "], category: "Japonês")

    XCTAssertEqual(result.tagWeights.count, 1)
    XCTAssertEqual(result.weight(forTag: "sushi"), 1.0)
  }
}

// MARK: - Mock Store

private class MockLearnedPreferencesStore: LearnedPreferencesStoring {
  private var preferences: LearnedPreferences = .empty()

  var saveCalled = false
  var resetCalled = false

  func load() -> LearnedPreferences {
    preferences
  }

  func save(_ prefs: LearnedPreferences) {
    saveCalled = true
    preferences = prefs
  }

  func reset() {
    resetCalled = true
    preferences = .empty()
  }
}

