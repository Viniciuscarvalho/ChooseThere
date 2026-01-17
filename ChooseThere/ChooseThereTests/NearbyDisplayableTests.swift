//
//  NearbyDisplayableTests.swift
//  ChooseThereTests
//
//  Created by Claude on 2026-01-17.
//

import XCTest

@testable import ChooseThere

final class NearbyDisplayableTests: XCTestCase {

  // MARK: - Restaurant Conformance Tests

  func testRestaurant_conformsToNearbyDisplayable() {
    let restaurant = makeRestaurant()

    // Verify all protocol properties are accessible
    XCTAssertNotNil(restaurant.displayId)
    XCTAssertNotNil(restaurant.displayName)
    XCTAssertNotNil(restaurant.displayCategory)
  }

  func testRestaurant_displayId_equalsId() {
    let restaurant = makeRestaurant(id: "test-123")

    XCTAssertEqual(restaurant.displayId, "test-123")
  }

  func testRestaurant_displayName_equalsName() {
    let restaurant = makeRestaurant(name: "Test Restaurant")

    XCTAssertEqual(restaurant.displayName, "Test Restaurant")
  }

  func testRestaurant_displayCategory_equalsCategory() {
    let restaurant = makeRestaurant(category: "Japonês")

    XCTAssertEqual(restaurant.displayCategory, "Japonês")
  }

  func testRestaurant_dataSource_isLocalBase() {
    let restaurant = makeRestaurant()

    XCTAssertEqual(restaurant.dataSource, .localBase)
  }

  func testRestaurant_displayRating_returnsRatingWhenHasRatings() {
    let restaurant = makeRestaurant(ratingAverage: 4.5, ratingCount: 10)

    XCTAssertEqual(restaurant.displayRating, 4.5)
  }

  func testRestaurant_displayRating_returnsNilWhenNoRatings() {
    let restaurant = makeRestaurant(ratingAverage: 0, ratingCount: 0)

    XCTAssertNil(restaurant.displayRating)
  }

  func testRestaurant_displayAddress_equalsAddress() {
    let restaurant = makeRestaurant(address: "Rua Augusta, 123")

    XCTAssertEqual(restaurant.displayAddress, "Rua Augusta, 123")
  }

  func testRestaurant_displayImageURL_returnsImageURLWhenSet() {
    let url = URL(string: "https://example.com/image.jpg")!
    let restaurant = makeRestaurant(imageURL: url)

    XCTAssertEqual(restaurant.displayImageURL, url)
  }

  func testRestaurant_displayImageURL_returnsNilWhenNotSet() {
    let restaurant = makeRestaurant(imageURL: nil)

    XCTAssertNil(restaurant.displayImageURL)
  }

  func testRestaurant_externalActions_includesTripAdvisorWhenSet() {
    let restaurant = makeRestaurant(tripAdvisorURL: URL(string: "https://tripadvisor.com/test"))

    XCTAssertTrue(restaurant.externalActions.contains(.tripAdvisor))
  }

  func testRestaurant_externalActions_includesIFoodWhenSet() {
    let restaurant = makeRestaurant(iFoodURL: URL(string: "https://ifood.com.br/test"))

    XCTAssertTrue(restaurant.externalActions.contains(.ifood))
  }

  func testRestaurant_externalActions_includesRide99WhenSet() {
    let restaurant = makeRestaurant(ride99URL: URL(string: "https://99app.com/test"))

    XCTAssertTrue(restaurant.externalActions.contains(.ride99))
  }

  func testRestaurant_externalActions_alwaysIncludesMaps() {
    let restaurant = makeRestaurant()

    XCTAssertTrue(restaurant.externalActions.contains(.maps))
  }

  func testRestaurant_externalActions_excludesMissingLinks() {
    let restaurant = makeRestaurant(
      tripAdvisorURL: nil,
      iFoodURL: nil,
      ride99URL: nil
    )

    XCTAssertFalse(restaurant.externalActions.contains(.tripAdvisor))
    XCTAssertFalse(restaurant.externalActions.contains(.ifood))
    XCTAssertFalse(restaurant.externalActions.contains(.ride99))
    // Maps should always be present
    XCTAssertTrue(restaurant.externalActions.contains(.maps))
  }

  // MARK: - NearbyPlace Conformance Tests

  func testNearbyPlace_conformsToNearbyDisplayable() {
    let place = makeNearbyPlace()

    // Verify all protocol properties are accessible
    XCTAssertNotNil(place.displayId)
    XCTAssertNotNil(place.displayName)
    XCTAssertNotNil(place.displayCategory)
  }

  func testNearbyPlace_displayId_isNotEmpty() {
    let place = makeNearbyPlace()

    XCTAssertFalse(place.displayId.isEmpty)
  }

  func testNearbyPlace_displayName_equalsName() {
    let place = makeNearbyPlace(name: "Test Place")

    XCTAssertEqual(place.displayName, "Test Place")
  }

  func testNearbyPlace_displayCategory_equalsCategoryHintWhenSet() {
    let place = makeNearbyPlace(categoryHint: "Café")

    XCTAssertEqual(place.displayCategory, "Café")
  }

  func testNearbyPlace_displayCategory_returnsDefaultWhenCategoryHintNil() {
    let place = NearbyPlace.create(
      name: "Test",
      latitude: -23.55,
      longitude: -46.63
    )

    XCTAssertEqual(place.displayCategory, "Restaurante")
  }

  func testNearbyPlace_dataSource_isAppleMaps() {
    let place = makeNearbyPlace()

    XCTAssertEqual(place.dataSource, .appleMaps)
  }

  func testNearbyPlace_displayRating_isAlwaysNil() {
    let place = makeNearbyPlace()

    XCTAssertNil(place.displayRating)
  }

  func testNearbyPlace_displayImageURL_isAlwaysNil() {
    let place = makeNearbyPlace()

    XCTAssertNil(place.displayImageURL)
  }

  func testNearbyPlace_displayAddress_equalsAddress() {
    let place = makeNearbyPlace(address: "Av Paulista, 1000")

    XCTAssertEqual(place.displayAddress, "Av Paulista, 1000")
  }

  func testNearbyPlace_externalActions_onlyContainsMaps() {
    let place = makeNearbyPlace()

    XCTAssertEqual(place.externalActions.count, 1)
    XCTAssertTrue(place.externalActions.contains(.maps))
  }

  // MARK: - DataSource Tests

  func testDataSource_localBase_hasCorrectBadgeIcon() {
    XCTAssertEqual(DataSource.localBase.badgeIcon, "checkmark.seal.fill")
  }

  func testDataSource_appleMaps_hasCorrectBadgeIcon() {
    XCTAssertEqual(DataSource.appleMaps.badgeIcon, "apple.logo")
  }

  func testDataSource_localBase_hasCorrectDisplayName() {
    XCTAssertEqual(DataSource.localBase.displayName, "Minha Base")
  }

  func testDataSource_appleMaps_hasCorrectDisplayName() {
    XCTAssertEqual(DataSource.appleMaps.displayName, "Apple Maps")
  }

  func testDataSource_localBase_hasTooltipText() {
    XCTAssertFalse(DataSource.localBase.tooltipText.isEmpty)
  }

  func testDataSource_appleMaps_hasTooltipText() {
    XCTAssertFalse(DataSource.appleMaps.tooltipText.isEmpty)
  }

  // MARK: - ExternalAction Tests

  func testExternalAction_allCases_containsExpectedActions() {
    let allCases = ExternalAction.allCases
    XCTAssertTrue(allCases.contains(.tripAdvisor))
    XCTAssertTrue(allCases.contains(.ifood))
    XCTAssertTrue(allCases.contains(.ride99))
    XCTAssertTrue(allCases.contains(.maps))
  }

  func testExternalAction_displayNames_areNotEmpty() {
    for action in ExternalAction.allCases {
      XCTAssertFalse(action.displayName.isEmpty, "Display name for \(action) should not be empty")
    }
  }

  func testExternalAction_icons_areNotEmpty() {
    for action in ExternalAction.allCases {
      XCTAssertFalse(action.icon.isEmpty, "Icon for \(action) should not be empty")
    }
  }

  func testExternalAction_accessibilityLabels_areNotEmpty() {
    for action in ExternalAction.allCases {
      XCTAssertFalse(action.accessibilityLabel.isEmpty, "Accessibility label for \(action) should not be empty")
    }
  }

  // MARK: - Helpers

  private func makeRestaurant(
    id: String = "test-id",
    name: String = "Test Restaurant",
    category: String = "Restaurante",
    address: String = "Test Address",
    ratingAverage: Double = 0,
    ratingCount: Int = 0,
    tripAdvisorURL: URL? = nil,
    iFoodURL: URL? = nil,
    ride99URL: URL? = nil,
    imageURL: URL? = nil
  ) -> Restaurant {
    Restaurant(
      id: id,
      name: name,
      category: category,
      address: address,
      city: "São Paulo",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: -23.55,
      lng: -46.63,
      isFavorite: false,
      applePlaceResolved: true,
      ratingAverage: ratingAverage,
      ratingCount: ratingCount,
      tripAdvisorURL: tripAdvisorURL,
      iFoodURL: iFoodURL,
      ride99URL: ride99URL,
      imageURL: imageURL
    )
  }

  private func makeNearbyPlace(
    name: String = "Test Place",
    address: String = "Test Address",
    categoryHint: String = "Restaurante"
  ) -> NearbyPlace {
    NearbyPlace.create(
      name: name,
      address: address,
      latitude: -23.55,
      longitude: -46.63,
      categoryHint: categoryHint
    )
  }
}
