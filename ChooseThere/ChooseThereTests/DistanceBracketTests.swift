//
//  DistanceBracketTests.swift
//  ChooseThereTests
//
//  Created by Claude on 2026-01-17.
//

import XCTest

@testable import ChooseThere

final class DistanceBracketTests: XCTestCase {

  // MARK: - VeryClose Bracket Tests

  func testDistanceBracket_veryClose_containsZero() {
    XCTAssertTrue(DistanceBracket.veryClose.contains(distanceKm: 0.0))
  }

  func testDistanceBracket_veryClose_containsMiddleValue() {
    XCTAssertTrue(DistanceBracket.veryClose.contains(distanceKm: 0.5))
  }

  func testDistanceBracket_veryClose_containsJustUnderBoundary() {
    XCTAssertTrue(DistanceBracket.veryClose.contains(distanceKm: 0.999))
  }

  func testDistanceBracket_veryClose_doesNotContainBoundary() {
    XCTAssertFalse(DistanceBracket.veryClose.contains(distanceKm: 1.0))
  }

  // MARK: - Close Bracket Tests

  func testDistanceBracket_close_doesNotContainJustUnderLowerBound() {
    XCTAssertFalse(DistanceBracket.close.contains(distanceKm: 0.999))
  }

  func testDistanceBracket_close_containsLowerBound() {
    XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 1.0))
  }

  func testDistanceBracket_close_containsMiddleValue() {
    XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 2.5))
  }

  func testDistanceBracket_close_containsJustUnderUpperBound() {
    XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 2.999))
  }

  func testDistanceBracket_close_doesNotContainUpperBound() {
    XCTAssertFalse(DistanceBracket.close.contains(distanceKm: 3.0))
  }

  // MARK: - Medium Bracket Tests

  func testDistanceBracket_medium_doesNotContainJustUnderLowerBound() {
    XCTAssertFalse(DistanceBracket.medium.contains(distanceKm: 2.999))
  }

  func testDistanceBracket_medium_containsLowerBound() {
    XCTAssertTrue(DistanceBracket.medium.contains(distanceKm: 3.0))
  }

  func testDistanceBracket_medium_containsMiddleValue() {
    XCTAssertTrue(DistanceBracket.medium.contains(distanceKm: 5.0))
  }

  func testDistanceBracket_medium_containsJustUnderUpperBound() {
    XCTAssertTrue(DistanceBracket.medium.contains(distanceKm: 6.999))
  }

  func testDistanceBracket_medium_doesNotContainUpperBound() {
    XCTAssertFalse(DistanceBracket.medium.contains(distanceKm: 7.0))
  }

  // MARK: - Far Bracket Tests

  func testDistanceBracket_far_doesNotContainJustUnderLowerBound() {
    XCTAssertFalse(DistanceBracket.far.contains(distanceKm: 6.999))
  }

  func testDistanceBracket_far_containsLowerBound() {
    XCTAssertTrue(DistanceBracket.far.contains(distanceKm: 7.0))
  }

  func testDistanceBracket_far_containsLargeValue() {
    XCTAssertTrue(DistanceBracket.far.contains(distanceKm: 100.0))
  }

  func testDistanceBracket_far_containsVeryLargeValue() {
    XCTAssertTrue(DistanceBracket.far.contains(distanceKm: 1000.0))
  }

  // MARK: - Display Name Tests

  func testDistanceBracket_displayNames_areInPortuguese() {
    XCTAssertEqual(DistanceBracket.veryClose.displayName, "Pertinho")
    XCTAssertEqual(DistanceBracket.close.displayName, "Perto")
    XCTAssertEqual(DistanceBracket.medium.displayName, "Média distância")
    XCTAssertEqual(DistanceBracket.far.displayName, "Mais longe")
  }

  // MARK: - AllCases Tests

  func testDistanceBracket_allCases_containsAllBrackets() {
    let allCases = DistanceBracket.allCases
    XCTAssertEqual(allCases.count, 4)
    XCTAssertTrue(allCases.contains(.veryClose))
    XCTAssertTrue(allCases.contains(.close))
    XCTAssertTrue(allCases.contains(.medium))
    XCTAssertTrue(allCases.contains(.far))
  }

  func testDistanceBracket_allCases_orderedByProximity() {
    let allCases = DistanceBracket.allCases
    XCTAssertEqual(allCases[0], .veryClose)
    XCTAssertEqual(allCases[1], .close)
    XCTAssertEqual(allCases[2], .medium)
    XCTAssertEqual(allCases[3], .far)
  }

  // MARK: - Edge Cases

  func testDistanceBracket_negativeValue_notContainedInAnyBracket() {
    // Negative distances should not be in veryClose
    // The implementation should handle this gracefully
    XCTAssertFalse(DistanceBracket.veryClose.contains(distanceKm: -1.0))
  }

  func testDistanceBracket_exactBoundaries_exclusiveUpperBound() {
    // Test that upper bounds are exclusive
    // 1.0 should be in close, not veryClose
    XCTAssertFalse(DistanceBracket.veryClose.contains(distanceKm: 1.0))
    XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 1.0))

    // 3.0 should be in medium, not close
    XCTAssertFalse(DistanceBracket.close.contains(distanceKm: 3.0))
    XCTAssertTrue(DistanceBracket.medium.contains(distanceKm: 3.0))

    // 7.0 should be in far, not medium
    XCTAssertFalse(DistanceBracket.medium.contains(distanceKm: 7.0))
    XCTAssertTrue(DistanceBracket.far.contains(distanceKm: 7.0))
  }

  // MARK: - Hashable/Equatable Tests

  func testDistanceBracket_isHashable() {
    var set = Set<DistanceBracket>()
    set.insert(.veryClose)
    set.insert(.close)
    set.insert(.medium)
    set.insert(.far)
    XCTAssertEqual(set.count, 4)
  }

  func testDistanceBracket_isEquatable() {
    XCTAssertEqual(DistanceBracket.veryClose, DistanceBracket.veryClose)
    XCTAssertNotEqual(DistanceBracket.veryClose, DistanceBracket.close)
  }
}
