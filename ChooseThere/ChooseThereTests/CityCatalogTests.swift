//
//  CityCatalogTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import XCTest

@testable import ChooseThere

final class CityCatalogTests: XCTestCase {

  // MARK: - Extract Cities from Restaurants

  func testExtractCitiesReturnsAnyCityFirst() {
    let restaurants = [
      Restaurant.fixture(id: "a", city: "São Paulo", state: "SP"),
      Restaurant.fixture(id: "b", city: "Rio de Janeiro", state: "RJ")
    ]

    let result = CityCatalog.extractCities(from: restaurants)

    XCTAssertFalse(result.isEmpty)
    XCTAssertTrue(result[0].isAnyCity)
    XCTAssertEqual(result[0].displayName, "Qualquer lugar (Perto de mim)")
  }

  func testExtractCitiesReturnsUniqueCities() {
    let restaurants = [
      Restaurant.fixture(id: "a", city: "São Paulo", state: "SP"),
      Restaurant.fixture(id: "b", city: "São Paulo", state: "SP"),
      Restaurant.fixture(id: "c", city: "Rio de Janeiro", state: "RJ")
    ]

    let result = CityCatalog.extractCities(from: restaurants)

    // AnyCity + 2 cidades únicas
    XCTAssertEqual(result.count, 3)
  }

  func testExtractCitiesIsSortedByCityName() {
    let restaurants = [
      Restaurant.fixture(id: "a", city: "Curitiba", state: "PR"),
      Restaurant.fixture(id: "b", city: "São Paulo", state: "SP"),
      Restaurant.fixture(id: "c", city: "Belo Horizonte", state: "MG")
    ]

    let result = CityCatalog.extractCities(from: restaurants)

    // Skip AnyCity (index 0)
    XCTAssertEqual(result[1].city, "Belo Horizonte")
    XCTAssertEqual(result[2].city, "Curitiba")
    XCTAssertEqual(result[3].city, "São Paulo")
  }

  func testExtractCitiesIgnoresEmptyValues() {
    let restaurants = [
      Restaurant.fixture(id: "a", city: "São Paulo", state: "SP"),
      Restaurant.fixture(id: "b", city: "", state: "RJ"),
      Restaurant.fixture(id: "c", city: "Rio de Janeiro", state: "")
    ]

    let result = CityCatalog.extractCities(from: restaurants)

    // Apenas AnyCity + São Paulo (entradas com city ou state vazios são ignoradas)
    XCTAssertEqual(result.count, 2)
    XCTAssertEqual(result[1].city, "São Paulo")
  }

  func testExtractCitiesFromEmptyListReturnsOnlyAnyCity() {
    let result = CityCatalog.extractCities(from: [])

    XCTAssertEqual(result.count, 1)
    XCTAssertTrue(result[0].isAnyCity)
  }

  func testExtractCitiesTrimsWhitespace() {
    let restaurants = [
      Restaurant.fixture(id: "a", city: "  São Paulo  ", state: " SP ")
    ]

    let result = CityCatalog.extractCities(from: restaurants)

    XCTAssertEqual(result[1].city, "São Paulo")
    XCTAssertEqual(result[1].state, "SP")
  }

  // MARK: - CityOption

  func testCityOptionDisplayName() {
    let option = CityOption(city: "São Paulo", state: "SP")

    XCTAssertEqual(option.displayName, "São Paulo, SP")
    XCTAssertEqual(option.id, "São Paulo|SP")
    XCTAssertFalse(option.isAnyCity)
  }

  func testAnyCityOption() {
    let anyCity = CityOption.anyCity

    XCTAssertNil(anyCity.id)
    XCTAssertTrue(anyCity.isAnyCity)
    XCTAssertEqual(anyCity.displayName, "Qualquer lugar (Perto de mim)")
  }

  // MARK: - Find Option

  func testFindOptionReturnsMatchingOption() {
    let options = [
      CityOption.anyCity,
      CityOption(city: "São Paulo", state: "SP"),
      CityOption(city: "Rio de Janeiro", state: "RJ")
    ]

    let result = CityCatalog.findOption(for: "São Paulo|SP", in: options)

    XCTAssertEqual(result.city, "São Paulo")
    XCTAssertEqual(result.state, "SP")
  }

  func testFindOptionReturnsAnyCityForNilKey() {
    let options = [
      CityOption.anyCity,
      CityOption(city: "São Paulo", state: "SP")
    ]

    let result = CityCatalog.findOption(for: nil, in: options)

    XCTAssertTrue(result.isAnyCity)
  }

  func testFindOptionReturnsAnyCityForUnknownKey() {
    let options = [
      CityOption.anyCity,
      CityOption(city: "São Paulo", state: "SP")
    ]

    let result = CityCatalog.findOption(for: "Unknown|XX", in: options)

    XCTAssertTrue(result.isAnyCity)
  }
}

// MARK: - Restaurant Fixture Extension (city/state)

extension Restaurant {
  static func fixture(
    id: String,
    city: String,
    state: String
  ) -> Restaurant {
    Restaurant(
      id: id,
      name: "Test Restaurant",
      category: "restaurant",
      address: "Test Address",
      city: city,
      state: state,
      tags: [],
      notes: "",
      externalLink: nil,
      lat: -23.55,
      lng: -46.63,
      isFavorite: false,
      applePlaceResolved: false,
      applePlaceResolvedAt: nil,
      applePlaceName: nil,
      applePlaceAddress: nil,
      ratingAverage: 0,
      ratingCount: 0,
      ratingLastVisitedAt: nil
    )
  }
}

