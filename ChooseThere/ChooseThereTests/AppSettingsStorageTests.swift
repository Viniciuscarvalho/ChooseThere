//
//  AppSettingsStorageTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import XCTest

@testable import ChooseThere

final class AppSettingsStorageTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Reset all settings before each test
    AppSettingsStorage.resetAll()
    AppSettingsStorage.hasCityOnboardingCompleted = false
  }

  override func tearDown() {
    // Clean up after each test
    AppSettingsStorage.resetAll()
    AppSettingsStorage.hasCityOnboardingCompleted = false
    super.tearDown()
  }

  // MARK: - Selected City

  func testSelectedCityKeyDefaultIsNil() {
    XCTAssertNil(AppSettingsStorage.selectedCityKey)
  }

  func testSelectedCityKeyCanBeSetAndRead() {
    AppSettingsStorage.selectedCityKey = "São Paulo|SP"

    XCTAssertEqual(AppSettingsStorage.selectedCityKey, "São Paulo|SP")
  }

  func testIsAnyCityModeReturnsTrueWhenNil() {
    AppSettingsStorage.selectedCityKey = nil

    XCTAssertTrue(AppSettingsStorage.isAnyCityMode)
  }

  func testIsAnyCityModeReturnsFalseWhenSet() {
    AppSettingsStorage.selectedCityKey = "São Paulo|SP"

    XCTAssertFalse(AppSettingsStorage.isAnyCityMode)
  }

  func testSetSelectedCityCreatesCorrectKey() {
    AppSettingsStorage.setSelectedCity(city: "Rio de Janeiro", state: "RJ")

    XCTAssertEqual(AppSettingsStorage.selectedCityKey, "Rio de Janeiro|RJ")
  }

  func testClearSelectedCitySetsNil() {
    AppSettingsStorage.selectedCityKey = "São Paulo|SP"
    AppSettingsStorage.clearSelectedCity()

    XCTAssertNil(AppSettingsStorage.selectedCityKey)
    XCTAssertTrue(AppSettingsStorage.isAnyCityMode)
  }

  func testParseSelectedCityReturnsTupleForValidKey() {
    AppSettingsStorage.selectedCityKey = "Curitiba|PR"

    let result = AppSettingsStorage.parseSelectedCity()

    XCTAssertEqual(result?.city, "Curitiba")
    XCTAssertEqual(result?.state, "PR")
  }

  func testParseSelectedCityReturnsNilForNilKey() {
    AppSettingsStorage.selectedCityKey = nil

    XCTAssertNil(AppSettingsStorage.parseSelectedCity())
  }

  func testParseSelectedCityHandlesCityWithPipe() {
    // Edge case: city name contains pipe (unlikely but should handle gracefully)
    AppSettingsStorage.selectedCityKey = "City|With|Pipe|SP"

    let result = AppSettingsStorage.parseSelectedCity()

    // Using maxSplits: 1, so first part is city, rest is state
    XCTAssertEqual(result?.city, "City")
    XCTAssertEqual(result?.state, "With|Pipe|SP")
  }

  // MARK: - Nearby Source

  func testNearbySourceDefaultIsLocalBase() {
    XCTAssertEqual(AppSettingsStorage.nearbySource, .localBase)
  }

  func testNearbySourceCanBeSetToAppleMaps() {
    AppSettingsStorage.nearbySource = .appleMaps

    XCTAssertEqual(AppSettingsStorage.nearbySource, .appleMaps)
  }

  func testNearbySourcePersists() {
    AppSettingsStorage.nearbySource = .appleMaps

    // Re-read to ensure it persists
    XCTAssertEqual(AppSettingsStorage.nearbySource, .appleMaps)
  }

  // MARK: - Nearby Radius

  func testNearbyRadiusDefaultIs3() {
    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, AppSettingsStorage.defaultRadiusKm)
    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, 3)
  }

  func testNearbyRadiusCanBeSet() {
    AppSettingsStorage.nearbyRadiusKm = 5

    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, 5)
  }

  func testNearbyRadiusClampsToMin() {
    AppSettingsStorage.nearbyRadiusKm = 0

    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, 1)
  }

  func testNearbyRadiusClampsToMax() {
    AppSettingsStorage.nearbyRadiusKm = 100

    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, 10)
  }

  // MARK: - Last Category

  func testNearbyLastCategoryDefaultIsNil() {
    XCTAssertNil(AppSettingsStorage.nearbyLastCategory)
  }

  func testNearbyLastCategoryCanBeSet() {
    AppSettingsStorage.nearbyLastCategory = "japanese"

    XCTAssertEqual(AppSettingsStorage.nearbyLastCategory, "japanese")
  }

  // MARK: - City Onboarding Completed

  func testHasCityOnboardingCompletedDefaultIsFalse() {
    XCTAssertFalse(AppSettingsStorage.hasCityOnboardingCompleted)
  }

  func testMarkCityOnboardingCompletedSetsTrue() {
    AppSettingsStorage.markCityOnboardingCompleted()

    XCTAssertTrue(AppSettingsStorage.hasCityOnboardingCompleted)
  }

  // MARK: - Reset

  func testResetAllClearsAllSettings() {
    AppSettingsStorage.selectedCityKey = "São Paulo|SP"
    AppSettingsStorage.nearbySource = .appleMaps
    AppSettingsStorage.nearbyRadiusKm = 10
    AppSettingsStorage.nearbyLastCategory = "bar"

    AppSettingsStorage.resetAll()

    XCTAssertNil(AppSettingsStorage.selectedCityKey)
    XCTAssertEqual(AppSettingsStorage.nearbySource, .localBase)
    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, 3)
    XCTAssertNil(AppSettingsStorage.nearbyLastCategory)
  }

  // MARK: - NearbySource Enum

  func testNearbySourceDisplayName() {
    XCTAssertEqual(NearbySource.localBase.displayName, "Minha base")
    XCTAssertEqual(NearbySource.appleMaps.displayName, "Apple Maps")
  }

  func testNearbySourceAllCases() {
    XCTAssertEqual(NearbySource.allCases.count, 2)
    XCTAssertTrue(NearbySource.allCases.contains(.localBase))
    XCTAssertTrue(NearbySource.allCases.contains(.appleMaps))
  }

  func testNearbySourceRawValue() {
    XCTAssertEqual(NearbySource.localBase.rawValue, "localBase")
    XCTAssertEqual(NearbySource.appleMaps.rawValue, "appleMaps")
  }

  func testNearbySourceIdentifiable() {
    XCTAssertEqual(NearbySource.localBase.id, "localBase")
    XCTAssertEqual(NearbySource.appleMaps.id, "appleMaps")
  }
}

