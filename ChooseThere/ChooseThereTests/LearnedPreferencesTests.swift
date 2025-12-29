//
//  LearnedPreferencesTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

final class LearnedPreferencesTests: XCTestCase {
  // MARK: - Empty Initialization

  func testEmpty_ReturnsEmptyPreferences() {
    let prefs = LearnedPreferences.empty()

    XCTAssertEqual(prefs.version, LearnedPreferences.currentVersion)
    XCTAssertTrue(prefs.tagWeights.isEmpty)
    XCTAssertTrue(prefs.categoryWeights.isEmpty)
    XCTAssertFalse(prefs.hasLearnedPreferences)
    XCTAssertEqual(prefs.totalWeightsCount, 0)
  }

  // MARK: - Weight Access

  func testWeight_ForNonExistentTag_ReturnsDefault() {
    let prefs = LearnedPreferences.empty()

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 0.0)
    XCTAssertEqual(prefs.weight(forTag: "pizza"), 0.0)
  }

  func testWeight_ForNonExistentCategory_ReturnsDefault() {
    let prefs = LearnedPreferences.empty()

    XCTAssertEqual(prefs.weight(forCategory: "Japonês"), 0.0)
    XCTAssertEqual(prefs.weight(forCategory: "Italiano"), 0.0)
  }

  func testWeight_ForExistingTag_ReturnsWeight() {
    var prefs = LearnedPreferences.empty()
    prefs.tagWeights["sushi"] = 2.5

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 2.5)
  }

  func testWeight_ForExistingCategory_ReturnsWeight() {
    var prefs = LearnedPreferences.empty()
    prefs.categoryWeights["japonês"] = 3.0

    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 3.0)
  }

  func testWeight_IsCaseInsensitive() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "Sushi", weight: 2.0)
    prefs.setWeight(forCategory: "JAPONÊS", weight: 3.0)

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 2.0)
    XCTAssertEqual(prefs.weight(forTag: "SUSHI"), 2.0)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 3.0)
    XCTAssertEqual(prefs.weight(forCategory: "Japonês"), 3.0)
  }

  // MARK: - Weight Update

  func testUpdateWeight_ForTag_AddsToExisting() {
    var prefs = LearnedPreferences.empty()
    prefs.updateWeight(forTag: "sushi", delta: 1.0)
    prefs.updateWeight(forTag: "sushi", delta: 0.5)

    XCTAssertEqual(prefs.weight(forTag: "sushi"), 1.5)
  }

  func testUpdateWeight_ForCategory_AddsToExisting() {
    var prefs = LearnedPreferences.empty()
    prefs.updateWeight(forCategory: "japonês", delta: 2.0)
    prefs.updateWeight(forCategory: "japonês", delta: -1.0)

    XCTAssertEqual(prefs.weight(forCategory: "japonês"), 1.0)
  }

  func testUpdateWeight_ClampsToMaxWeight() {
    var prefs = LearnedPreferences.empty()
    prefs.updateWeight(forTag: "sushi", delta: 10.0)

    XCTAssertEqual(prefs.weight(forTag: "sushi"), LearnedPreferences.maxWeight)
  }

  func testUpdateWeight_ClampsToMinWeight() {
    var prefs = LearnedPreferences.empty()
    prefs.updateWeight(forTag: "sushi", delta: -10.0)

    XCTAssertEqual(prefs.weight(forTag: "sushi"), LearnedPreferences.minWeight)
  }

  func testSetWeight_AppliesClamp() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 100.0)
    prefs.setWeight(forCategory: "japonês", weight: -100.0)

    XCTAssertEqual(prefs.weight(forTag: "sushi"), LearnedPreferences.maxWeight)
    XCTAssertEqual(prefs.weight(forCategory: "japonês"), LearnedPreferences.minWeight)
  }

  func testUpdateWeight_UpdatesTimestamp() {
    var prefs = LearnedPreferences.empty()
    let initialDate = prefs.updatedAt

    // Pequeno delay para garantir timestamp diferente
    Thread.sleep(forTimeInterval: 0.01)

    prefs.updateWeight(forTag: "sushi", delta: 1.0)

    XCTAssertGreaterThan(prefs.updatedAt, initialDate)
  }

  // MARK: - Match Score

  func testMatchScore_EmptyPreferences_ReturnsZero() {
    let prefs = LearnedPreferences.empty()
    let score = prefs.matchScore(tags: ["sushi", "premium"], category: "Japonês")

    XCTAssertEqual(score, 0.0)
  }

  func testMatchScore_WithTagWeights_SumsAll() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.0)
    prefs.setWeight(forTag: "premium", weight: 1.0)

    let score = prefs.matchScore(tags: ["sushi", "premium"], category: "")

    XCTAssertEqual(score, 3.0)
  }

  func testMatchScore_WithCategoryWeight_Adds() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forCategory: "japonês", weight: 3.0)

    let score = prefs.matchScore(tags: [], category: "Japonês")

    XCTAssertEqual(score, 3.0)
  }

  func testMatchScore_CombinesTagsAndCategory() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.0)
    prefs.setWeight(forCategory: "japonês", weight: 1.0)

    let score = prefs.matchScore(tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(score, 3.0)
  }

  func testMatchScore_CanBeNegative() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "fast-food", weight: -3.0)
    prefs.setWeight(forCategory: "hambúrguer", weight: -2.0)

    let score = prefs.matchScore(tags: ["fast-food"], category: "Hambúrguer")

    XCTAssertEqual(score, -5.0)
  }

  // MARK: - Sorting Weight

  func testSortingWeight_EmptyPreferences_ReturnsOne() {
    let prefs = LearnedPreferences.empty()
    let weight = prefs.sortingWeight(tags: ["sushi"], category: "Japonês")

    XCTAssertEqual(weight, 1.0)
  }

  func testSortingWeight_PositiveScore_IncreasesWeight() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 2.0)

    let weight = prefs.sortingWeight(tags: ["sushi"], category: "")

    XCTAssertEqual(weight, 3.0) // 1.0 + 2.0
  }

  func testSortingWeight_NegativeScore_DecreasesWeight() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "fast-food", weight: -0.5)

    let weight = prefs.sortingWeight(tags: ["fast-food"], category: "")

    XCTAssertEqual(weight, 0.5) // 1.0 + (-0.5)
  }

  func testSortingWeight_NeverBelowMinimum() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "fast-food", weight: -5.0)

    let weight = prefs.sortingWeight(tags: ["fast-food"], category: "")

    // 1.0 + (-5.0) = -4.0, mas o mínimo é 0.1
    XCTAssertEqual(weight, 0.1)
  }

  // MARK: - Rating Delta

  func testWeightDelta_Rating5_ReturnsPositiveOne() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: 5), 1.0)
  }

  func testWeightDelta_Rating4_ReturnsHalf() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: 4), 0.5)
  }

  func testWeightDelta_Rating3_ReturnsZero() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: 3), 0.0)
  }

  func testWeightDelta_Rating2_ReturnsNegativeHalf() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: 2), -0.5)
  }

  func testWeightDelta_Rating1_ReturnsNegativeOne() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: 1), -1.0)
  }

  func testWeightDelta_OutOfRangeHigh_ClampsToPositive() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: 10), 1.0)
  }

  func testWeightDelta_OutOfRangeLow_ClampsToNegative() {
    XCTAssertEqual(LearnedPreferences.weightDelta(forRating: -5), -1.0)
  }

  // MARK: - Codable

  func testEncodeDecode_Roundtrip() throws {
    var original = LearnedPreferences.empty()
    original.setWeight(forTag: "sushi", weight: 2.5)
    original.setWeight(forCategory: "japonês", weight: 3.0)

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(LearnedPreferences.self, from: data)

    XCTAssertEqual(decoded.version, original.version)
    XCTAssertEqual(decoded.tagWeights, original.tagWeights)
    XCTAssertEqual(decoded.categoryWeights, original.categoryWeights)
  }

  // MARK: - Equatable

  func testEquatable_SameValues_AreEqual() {
    let prefs1 = LearnedPreferences(
      tagWeights: ["sushi": 2.0],
      categoryWeights: ["japonês": 3.0],
      updatedAt: Date(timeIntervalSince1970: 0)
    )
    let prefs2 = LearnedPreferences(
      tagWeights: ["sushi": 2.0],
      categoryWeights: ["japonês": 3.0],
      updatedAt: Date(timeIntervalSince1970: 0)
    )

    XCTAssertEqual(prefs1, prefs2)
  }

  func testEquatable_DifferentValues_AreNotEqual() {
    let prefs1 = LearnedPreferences(tagWeights: ["sushi": 2.0])
    let prefs2 = LearnedPreferences(tagWeights: ["pizza": 2.0])

    XCTAssertNotEqual(prefs1, prefs2)
  }

  // MARK: - Has Learned Preferences

  func testHasLearnedPreferences_Empty_ReturnsFalse() {
    let prefs = LearnedPreferences.empty()
    XCTAssertFalse(prefs.hasLearnedPreferences)
  }

  func testHasLearnedPreferences_WithTagWeight_ReturnsTrue() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 1.0)

    XCTAssertTrue(prefs.hasLearnedPreferences)
  }

  func testHasLearnedPreferences_WithCategoryWeight_ReturnsTrue() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forCategory: "japonês", weight: 1.0)

    XCTAssertTrue(prefs.hasLearnedPreferences)
  }

  // MARK: - Clamp Weight

  func testClampWeight_WithinRange_ReturnsValue() {
    XCTAssertEqual(LearnedPreferences.clampWeight(2.5), 2.5)
    XCTAssertEqual(LearnedPreferences.clampWeight(-2.5), -2.5)
    XCTAssertEqual(LearnedPreferences.clampWeight(0.0), 0.0)
  }

  func testClampWeight_AboveMax_ReturnsMax() {
    XCTAssertEqual(LearnedPreferences.clampWeight(10.0), LearnedPreferences.maxWeight)
    XCTAssertEqual(LearnedPreferences.clampWeight(100.0), LearnedPreferences.maxWeight)
  }

  func testClampWeight_BelowMin_ReturnsMin() {
    XCTAssertEqual(LearnedPreferences.clampWeight(-10.0), LearnedPreferences.minWeight)
    XCTAssertEqual(LearnedPreferences.clampWeight(-100.0), LearnedPreferences.minWeight)
  }
}

