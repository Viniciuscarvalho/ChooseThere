//
//  RecentHistoryServiceTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

final class RecentHistoryServiceTests: XCTestCase {
  // MARK: - Properties

  private var sut: RecentHistoryService!
  private var mockRepository: MockHistoryVisitRepository!

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    mockRepository = MockHistoryVisitRepository()
    sut = RecentHistoryService(visitRepository: mockRepository)
  }

  override func tearDown() {
    sut = nil
    mockRepository = nil
    super.tearDown()
  }

  // MARK: - Tests

  func testRecentRestaurantIDs_EmptyRepository_ReturnsEmpty() throws {
    mockRepository.visits = []

    let result = try sut.recentRestaurantIDs(limit: 10)

    XCTAssertTrue(result.isEmpty)
  }

  func testRecentRestaurantIDs_LimitZero_ReturnsEmpty() throws {
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "a")
    ]

    let result = try sut.recentRestaurantIDs(limit: 0)

    XCTAssertTrue(result.isEmpty)
  }

  func testRecentRestaurantIDs_LimitNegative_ReturnsEmpty() throws {
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "a")
    ]

    let result = try sut.recentRestaurantIDs(limit: -5)

    XCTAssertTrue(result.isEmpty)
  }

  func testRecentRestaurantIDs_SingleVisit_ReturnsThatID() throws {
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "restaurant-1")
    ]

    let result = try sut.recentRestaurantIDs(limit: 10)

    XCTAssertEqual(result, ["restaurant-1"])
  }

  func testRecentRestaurantIDs_MultipleVisits_ReturnsInOrder() throws {
    // Visitas ordenadas do mais recente ao mais antigo
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "recent"),
      Visit.historyFixture(restaurantId: "middle"),
      Visit.historyFixture(restaurantId: "old")
    ]

    let result = try sut.recentRestaurantIDs(limit: 10)

    XCTAssertEqual(result, ["recent", "middle", "old"])
  }

  func testRecentRestaurantIDs_DuplicateVisits_ReturnsUniqueIDs() throws {
    // Mesmo restaurante visitado múltiplas vezes
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "a"), // Mais recente
      Visit.historyFixture(restaurantId: "b"),
      Visit.historyFixture(restaurantId: "a"), // Duplicado (mais antigo)
      Visit.historyFixture(restaurantId: "c")
    ]

    let result = try sut.recentRestaurantIDs(limit: 10)

    // "a" deve aparecer apenas uma vez (na posição mais recente)
    XCTAssertEqual(result, ["a", "b", "c"])
  }

  func testRecentRestaurantIDs_LimitLessThanTotal_RespectsLimit() throws {
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "1"),
      Visit.historyFixture(restaurantId: "2"),
      Visit.historyFixture(restaurantId: "3"),
      Visit.historyFixture(restaurantId: "4"),
      Visit.historyFixture(restaurantId: "5")
    ]

    let result = try sut.recentRestaurantIDs(limit: 3)

    XCTAssertEqual(result.count, 3)
    XCTAssertEqual(result, ["1", "2", "3"])
  }

  func testRecentRestaurantIDs_LimitMoreThanTotal_ReturnsAll() throws {
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "1"),
      Visit.historyFixture(restaurantId: "2")
    ]

    let result = try sut.recentRestaurantIDs(limit: 100)

    XCTAssertEqual(result.count, 2)
    XCTAssertEqual(result, ["1", "2"])
  }

  func testRecentRestaurantIDs_LimitExactlyTotal_ReturnsAll() throws {
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "1"),
      Visit.historyFixture(restaurantId: "2"),
      Visit.historyFixture(restaurantId: "3")
    ]

    let result = try sut.recentRestaurantIDs(limit: 3)

    XCTAssertEqual(result.count, 3)
  }

  func testRecentRestaurantIDs_DuplicatesCountedOnce_LimitApplied() throws {
    // 5 visitas mas apenas 3 restaurantes únicos
    mockRepository.visits = [
      Visit.historyFixture(restaurantId: "a"),
      Visit.historyFixture(restaurantId: "a"),
      Visit.historyFixture(restaurantId: "b"),
      Visit.historyFixture(restaurantId: "b"),
      Visit.historyFixture(restaurantId: "c")
    ]

    // Limit 2 deve retornar apenas os 2 primeiros únicos
    let result = try sut.recentRestaurantIDs(limit: 2)

    XCTAssertEqual(result, ["a", "b"])
  }

  func testRecentRestaurantIDs_RepositoryThrows_PropagatesError() throws {
    mockRepository.shouldThrow = true

    XCTAssertThrowsError(try sut.recentRestaurantIDs(limit: 10))
  }
}

// MARK: - Mock Visit Repository

private class MockHistoryVisitRepository: VisitRepository {
  var visits: [Visit] = []
  var shouldThrow = false

  func add(_ visit: Visit) throws {
    if shouldThrow { throw MockError.generic }
    visits.insert(visit, at: 0) // Mais recente primeiro
  }

  func update(_ visit: Visit) throws {
    if shouldThrow { throw MockError.generic }
  }

  func fetchAll() throws -> [Visit] {
    if shouldThrow { throw MockError.generic }
    return visits
  }

  func fetchVisits(for restaurantId: String) throws -> [Visit] {
    if shouldThrow { throw MockError.generic }
    return visits.filter { $0.restaurantId == restaurantId }
  }

  enum MockError: Error {
    case generic
  }
}

// MARK: - Visit Fixture

private extension Visit {
  static func historyFixture(
    id: UUID = UUID(),
    restaurantId: String,
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

