//
//  RestaurantRatingAggregatorTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import XCTest
@testable import ChooseThere

// MARK: - Mock Repositories

final class MockVisitRepository: VisitRepository {
  var visits: [Visit] = []
  var error: Error?
  
  func add(_ visit: Visit) throws {
    if let error = error { throw error }
    visits.append(visit)
  }
  
  func update(_ visit: Visit) throws {
    if let error = error { throw error }
    if let index = visits.firstIndex(where: { $0.id == visit.id }) {
      visits[index] = visit
    }
  }
  
  func fetchAll() throws -> [Visit] {
    if let error = error { throw error }
    return visits
  }
  
  func fetchVisits(for restaurantId: String) throws -> [Visit] {
    if let error = error { throw error }
    return visits.filter { $0.restaurantId == restaurantId }
  }
}

final class MockRatingRepository: RestaurantRepository {
  var restaurants: [Restaurant] = []
  var ratingSnapshots: [String: (average: Double, count: Int, lastVisitedAt: Date?)] = [:]
  var error: Error?
  
  func fetchAll() throws -> [Restaurant] {
    if let error = error { throw error }
    return restaurants
  }
  
  func fetch(id: String) throws -> Restaurant? {
    if let error = error { throw error }
    return restaurants.first { $0.id == id }
  }
  
  func setFavorite(id: String, isFavorite: Bool) throws {
    if let error = error { throw error }
    if let index = restaurants.firstIndex(where: { $0.id == id }) {
      restaurants[index].isFavorite = isFavorite
    }
  }
  
  func updateApplePlaceData(id: String, lat: Double, lng: Double, applePlaceName: String?, applePlaceAddress: String?) throws {
    if let error = error { throw error }
  }
  
  func markApplePlaceUnresolved(id: String) throws {
    if let error = error { throw error }
  }
  
  func updateRatingSnapshot(id: String, average: Double, count: Int, lastVisitedAt: Date?) throws {
    if let error = error { throw error }
    ratingSnapshots[id] = (average: average, count: count, lastVisitedAt: lastVisitedAt)
  }
  
  func fetchUnresolvedLocations() throws -> [Restaurant] {
    if let error = error { throw error }
    return restaurants.filter { !$0.applePlaceResolved }
  }
  
  func updateExternalLinks(id: String, tripAdvisorURL: URL?, iFoodURL: URL?, ride99URL: URL?, imageURL: URL?) throws {
    if let error = error { throw error }
    // No-op for tests
  }
  
  func updateExternalLink(id: String, externalLink: URL?) throws {
    if let error = error { throw error }
    // No-op for tests
  }
}

// MARK: - Test Fixtures

extension Visit {
  static func fixture(
    id: UUID = UUID(),
    restaurantId: String = "test-restaurant",
    dateVisited: Date = Date(),
    rating: Int = 4,
    tags: [String] = [],
    note: String? = nil,
    isMatch: Bool = true,
    wouldReturn: Bool = true
  ) -> Visit {
    Visit(
      id: id,
      restaurantId: restaurantId,
      dateVisited: dateVisited,
      rating: rating,
      tags: tags,
      note: note,
      isMatch: isMatch,
      wouldReturn: wouldReturn
    )
  }
}

// MARK: - Tests

@MainActor
final class RestaurantRatingAggregatorTests: XCTestCase {
  
  var visitRepository: MockVisitRepository!
  var restaurantRepository: MockRatingRepository!
  var aggregator: RestaurantRatingAggregator!
  
  override func setUp() {
    super.setUp()
    visitRepository = MockVisitRepository()
    restaurantRepository = MockRatingRepository()
    aggregator = RestaurantRatingAggregator(
      visitRepository: visitRepository,
      restaurantRepository: restaurantRepository
    )
  }
  
  override func tearDown() {
    visitRepository = nil
    restaurantRepository = nil
    aggregator = nil
    super.tearDown()
  }
  
  // MARK: - Compute Tests
  
  func testComputeWithNoVisitsReturnsEmpty() {
    // Given: no visits
    visitRepository.visits = []
    
    // When
    let result = aggregator.compute(for: "test-restaurant")
    
    // Then
    XCTAssertEqual(result.average, 0)
    XCTAssertEqual(result.count, 0)
    XCTAssertNil(result.lastVisitedAt)
    XCTAssertFalse(result.hasRatings)
  }
  
  func testComputeWithSingleVisitReturnsCorrectValues() {
    // Given
    let date = Date()
    visitRepository.visits = [
      .fixture(restaurantId: "test-restaurant", dateVisited: date, rating: 5)
    ]
    
    // When
    let result = aggregator.compute(for: "test-restaurant")
    
    // Then
    XCTAssertEqual(result.average, 5.0)
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result.lastVisitedAt, date)
    XCTAssertTrue(result.hasRatings)
  }
  
  func testComputeWithMultipleVisitsReturnsCorrectAverage() {
    // Given
    visitRepository.visits = [
      .fixture(restaurantId: "test-restaurant", rating: 5),
      .fixture(restaurantId: "test-restaurant", rating: 3),
      .fixture(restaurantId: "test-restaurant", rating: 4)
    ]
    
    // When
    let result = aggregator.compute(for: "test-restaurant")
    
    // Then
    XCTAssertEqual(result.average, 4.0, accuracy: 0.01) // (5 + 3 + 4) / 3 = 4.0
    XCTAssertEqual(result.count, 3)
  }
  
  func testComputeReturnsLastVisitedDate() {
    // Given
    let oldDate = Date().addingTimeInterval(-86400 * 30) // 30 days ago
    let recentDate = Date()
    visitRepository.visits = [
      .fixture(restaurantId: "test-restaurant", dateVisited: oldDate, rating: 3),
      .fixture(restaurantId: "test-restaurant", dateVisited: recentDate, rating: 5)
    ]
    
    // When
    let result = aggregator.compute(for: "test-restaurant")
    
    // Then
    XCTAssertEqual(result.lastVisitedAt, recentDate)
  }
  
  func testComputeOnlyIncludesVisitsForSpecifiedRestaurant() {
    // Given
    visitRepository.visits = [
      .fixture(restaurantId: "restaurant-a", rating: 5),
      .fixture(restaurantId: "restaurant-b", rating: 1),
      .fixture(restaurantId: "restaurant-a", rating: 5)
    ]
    
    // When
    let result = aggregator.compute(for: "restaurant-a")
    
    // Then
    XCTAssertEqual(result.average, 5.0)
    XCTAssertEqual(result.count, 2)
  }
  
  func testComputeWithRepositoryErrorReturnsEmpty() {
    // Given
    visitRepository.error = NSError(domain: "test", code: 1)
    
    // When
    let result = aggregator.compute(for: "test-restaurant")
    
    // Then
    XCTAssertEqual(result, RatingAggregation.empty)
  }
  
  // MARK: - Update Snapshot Tests
  
  func testUpdateSnapshotPersistsToRepository() {
    // Given
    let date = Date()
    visitRepository.visits = [
      .fixture(restaurantId: "test-restaurant", dateVisited: date, rating: 4)
    ]
    
    // When
    let result = aggregator.updateSnapshot(for: "test-restaurant")
    
    // Then
    XCTAssertEqual(result.average, 4.0)
    XCTAssertEqual(result.count, 1)
    
    let snapshot = restaurantRepository.ratingSnapshots["test-restaurant"]
    XCTAssertNotNil(snapshot)
    XCTAssertEqual(snapshot?.average, 4.0)
    XCTAssertEqual(snapshot?.count, 1)
    XCTAssertEqual(snapshot?.lastVisitedAt, date)
  }
  
  // MARK: - RatingAggregation Struct Tests
  
  func testRatingAggregationEquality() {
    let a = RatingAggregation(average: 4.5, count: 10, lastVisitedAt: nil)
    let b = RatingAggregation(average: 4.5, count: 10, lastVisitedAt: nil)
    
    XCTAssertEqual(a, b)
  }
  
  func testRatingAggregationEmpty() {
    let empty = RatingAggregation.empty
    
    XCTAssertEqual(empty.average, 0)
    XCTAssertEqual(empty.count, 0)
    XCTAssertNil(empty.lastVisitedAt)
    XCTAssertFalse(empty.hasRatings)
  }
}

