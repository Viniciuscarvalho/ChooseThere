//
//  NearbyLocalFilterServiceTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import XCTest

@testable import ChooseThere

final class NearbyLocalFilterServiceTests: XCTestCase {
  private var service: NearbyLocalFilterService!

  // Coordenada de referência: Av. Paulista, São Paulo
  private let paulistaCoordinate = CLLocationCoordinate2D(
    latitude: -23.5632,
    longitude: -46.6541
  )

  override func setUp() {
    super.setUp()
    service = NearbyLocalFilterService()
  }

  // MARK: - Distance Filter Tests

  func testFilterByRadiusExcludesFarRestaurants() {
    let restaurants = [
      // ~1km da Paulista
      makeRestaurant(id: "close", lat: -23.5650, lng: -46.6550),
      // ~15km da Paulista (zona sul)
      makeRestaurant(id: "far", lat: -23.65, lng: -46.70)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 3
    )

    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.first?.id, "close")
  }

  func testFilterByRadiusIncludesRestaurantsWithinRadius() {
    let restaurants = [
      makeRestaurant(id: "a", lat: -23.5640, lng: -46.6545), // ~100m
      makeRestaurant(id: "b", lat: -23.5700, lng: -46.6600), // ~1km
      makeRestaurant(id: "c", lat: -23.5800, lng: -46.6700)  // ~2km
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5
    )

    XCTAssertEqual(result.count, 3)
  }

  func testFilterReturnsEmptyForNoRestaurantsInRadius() {
    let restaurants = [
      makeRestaurant(id: "far1", lat: -23.70, lng: -46.80),
      makeRestaurant(id: "far2", lat: -23.75, lng: -46.85)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 1
    )

    XCTAssertTrue(result.isEmpty)
  }

  func testFilterSortsByDistance() {
    let restaurants = [
      makeRestaurant(id: "medium", lat: -23.5700, lng: -46.6600), // ~1km
      makeRestaurant(id: "close", lat: -23.5635, lng: -46.6545),  // ~50m
      makeRestaurant(id: "far", lat: -23.5800, lng: -46.6700)     // ~2km
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5
    )

    XCTAssertEqual(result.count, 3)
    XCTAssertEqual(result[0].id, "close")
    XCTAssertEqual(result[1].id, "medium")
    XCTAssertEqual(result[2].id, "far")
  }

  // MARK: - Category Filter Tests

  func testFilterByCategoryIncludesMatchingRestaurants() {
    let restaurants = [
      makeRestaurant(id: "japanese1", category: "Japonês", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "italian", category: "Italiano", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "japanese2", category: "Comida Japonesa", lat: -23.5640, lng: -46.6545)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5,
      category: "japonês"
    )

    XCTAssertEqual(result.count, 2)
    XCTAssertTrue(result.contains { $0.id == "japanese1" })
    XCTAssertTrue(result.contains { $0.id == "japanese2" })
  }

  func testFilterByCategoryIsCaseInsensitive() {
    let restaurants = [
      makeRestaurant(id: "a", category: "JAPONÊS", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "b", category: "japonês", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "c", category: "Japonês", lat: -23.5640, lng: -46.6545)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5,
      category: "JaPonÊS"
    )

    XCTAssertEqual(result.count, 3)
  }

  func testFilterByCategoryAlsoMatchesTags() {
    let restaurants = [
      makeRestaurant(id: "a", category: "Bar", tags: ["sushi", "japonês"], lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "b", category: "Restaurante", tags: ["italiano"], lat: -23.5640, lng: -46.6545)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5,
      category: "sushi"
    )

    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.first?.id, "a")
  }

  func testFilterWithNilCategoryIncludesAll() {
    let restaurants = [
      makeRestaurant(id: "a", category: "Japonês", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "b", category: "Italiano", lat: -23.5640, lng: -46.6545)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5,
      category: nil
    )

    XCTAssertEqual(result.count, 2)
  }

  func testFilterWithEmptyCategoryIncludesAll() {
    let restaurants = [
      makeRestaurant(id: "a", category: "Japonês", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "b", category: "Italiano", lat: -23.5640, lng: -46.6545)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 5,
      category: ""
    )

    XCTAssertEqual(result.count, 2)
  }

  // MARK: - Combined Filters Tests

  func testFilterCombinesRadiusAndCategory() {
    let restaurants = [
      makeRestaurant(id: "close-japanese", category: "Japonês", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "close-italian", category: "Italiano", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "far-japanese", category: "Japonês", lat: -23.70, lng: -46.80)
    ]

    let result = service.filter(
      restaurants: restaurants,
      userCoordinate: paulistaCoordinate,
      radiusKm: 3,
      category: "japonês"
    )

    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.first?.id, "close-japanese")
  }

  // MARK: - Distance Calculation Tests

  func testDistanceCalculation() {
    let restaurant = makeRestaurant(id: "test", lat: -23.5700, lng: -46.6600)

    let distance = service.distance(to: restaurant, from: paulistaCoordinate)

    // Should be approximately 1km (allowing for some variance)
    XCTAssertGreaterThan(distance, 500)
    XCTAssertLessThan(distance, 1500)
  }

  // MARK: - Format Distance Tests

  func testFormatDistanceMeters() {
    XCTAssertEqual(NearbyLocalFilterService.formatDistance(100), "100 m")
    XCTAssertEqual(NearbyLocalFilterService.formatDistance(500), "500 m")
    XCTAssertEqual(NearbyLocalFilterService.formatDistance(999), "999 m")
  }

  func testFormatDistanceKilometers() {
    XCTAssertEqual(NearbyLocalFilterService.formatDistance(1000), "1.0 km")
    XCTAssertEqual(NearbyLocalFilterService.formatDistance(1500), "1.5 km")
    XCTAssertEqual(NearbyLocalFilterService.formatDistance(2300), "2.3 km")
  }

  // MARK: - Helpers

  private func makeRestaurant(
    id: String,
    category: String = "Restaurante",
    tags: [String] = [],
    lat: Double,
    lng: Double
  ) -> Restaurant {
    Restaurant(
      id: id,
      name: "Test \(id)",
      category: category,
      address: "Test Address",
      city: "São Paulo",
      state: "SP",
      tags: tags,
      notes: "",
      externalLink: nil,
      lat: lat,
      lng: lng,
      isFavorite: false,
      applePlaceResolved: true,
      applePlaceResolvedAt: nil,
      applePlaceName: nil,
      applePlaceAddress: nil,
      ratingAverage: 0,
      ratingCount: 0,
      ratingLastVisitedAt: nil
    )
  }
}

