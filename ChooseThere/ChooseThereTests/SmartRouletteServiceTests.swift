//
//  SmartRouletteServiceTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

final class SmartRouletteServiceTests: XCTestCase {
  // MARK: - Properties

  private var sut: SmartRouletteService!
  private var mockRandomizer: MockRandomizer!
  private var mockHistoryProvider: MockRecentHistory!
  private var mockPrefsStore: MockPrefsStore!
  private var learningEnabled: Bool = true
  private var avoidRepeatsLimit: Int = 10

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    mockRandomizer = MockRandomizer()
    mockHistoryProvider = MockRecentHistory()
    mockPrefsStore = MockPrefsStore()
    learningEnabled = true
    avoidRepeatsLimit = 10

    sut = SmartRouletteService(
      randomizer: mockRandomizer,
      recentHistoryProvider: mockHistoryProvider,
      preferencesStore: mockPrefsStore,
      settingsProvider: .init(
        isLearningEnabled: { [unowned self] in self.learningEnabled },
        avoidRepeatsLimit: { [unowned self] in self.avoidRepeatsLimit }
      )
    )
  }

  override func tearDown() {
    sut = nil
    mockRandomizer = nil
    mockHistoryProvider = nil
    mockPrefsStore = nil
    super.tearDown()
  }

  // MARK: - Helper

  private func makeRestaurant(id: String) -> Restaurant {
    Restaurant.fixture(id: id)
  }

  // MARK: - Basic Tests

  func testPick_EmptyList_ReturnsNil() {
    let result = sut.pick(from: [], context: PreferenceContext(), sessionExcludes: [])

    XCTAssertNil(result)
    XCTAssertEqual(mockRandomizer.pickCallCount, 1)
  }

  func testPick_SingleRestaurant_ReturnsThatRestaurant() {
    let restaurants = [makeRestaurant(id: "only-one")]
    mockRandomizer.pickResult = restaurants.first

    let result = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    XCTAssertEqual(result?.id, "only-one")
  }

  // MARK: - Learning Preferences Tests

  func testPick_LearningEnabled_PassesPreferencesToRandomizer() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 3.0)
    mockPrefsStore.preferences = prefs
    learningEnabled = true

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = restaurants.first

    _ = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    XCTAssertNotNil(mockRandomizer.lastContext?.learnedPreferences)
    XCTAssertEqual(mockRandomizer.lastContext?.learnedPreferences?.weight(forTag: "sushi"), 3.0)
  }

  func testPick_LearningDisabled_DoesNotPassPreferences() {
    var prefs = LearnedPreferences.empty()
    prefs.setWeight(forTag: "sushi", weight: 3.0)
    mockPrefsStore.preferences = prefs
    learningEnabled = false

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = restaurants.first

    _ = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    XCTAssertNil(mockRandomizer.lastContext?.learnedPreferences)
  }

  // MARK: - Anti-Repetition Tests

  func testPick_AvoidRepeatsEnabled_ExcludesRecentRestaurants() {
    mockHistoryProvider.recentIDs = ["recent-1", "recent-2"]
    avoidRepeatsLimit = 10

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = restaurants.first

    _ = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    let excludes = mockRandomizer.lastExcludeIDs
    XCTAssertTrue(excludes.contains("recent-1"))
    XCTAssertTrue(excludes.contains("recent-2"))
  }

  func testPick_AvoidRepeatsDisabled_DoesNotExcludeRecent() {
    mockHistoryProvider.recentIDs = ["recent-1", "recent-2"]
    avoidRepeatsLimit = 0

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = restaurants.first

    _ = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    let excludes = mockRandomizer.lastExcludeIDs
    XCTAssertFalse(excludes.contains("recent-1"))
    XCTAssertFalse(excludes.contains("recent-2"))
  }

  func testPick_CombinesSessionAndHistoryExcludes() {
    mockHistoryProvider.recentIDs = ["history-1"]
    avoidRepeatsLimit = 10

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = restaurants.first

    _ = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: ["session-1"])

    let excludes = mockRandomizer.lastExcludeIDs
    XCTAssertTrue(excludes.contains("history-1"))
    XCTAssertTrue(excludes.contains("session-1"))
  }

  // MARK: - Fallback Tests

  func testPick_AllExcluded_FallsBackToSessionOnly() {
    mockHistoryProvider.recentIDs = ["a", "b", "c"]
    avoidRepeatsLimit = 10

    let restaurants = [
      makeRestaurant(id: "a"),
      makeRestaurant(id: "b")
    ]

    // Primeiro pick com todas as exclusões retorna nil
    // Segundo pick (fallback) sem history retorna resultado
    mockRandomizer.pickResults = [nil, restaurants.first]

    let result = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    // Deve ter tentado 2x: uma com todas exclusões, outra com fallback
    XCTAssertEqual(mockRandomizer.pickCallCount, 2)
    XCTAssertNotNil(result)
  }

  func testPick_AllExcludedEvenWithFallback_ReturnsNilOrFinalFallback() {
    mockHistoryProvider.recentIDs = ["a"]
    avoidRepeatsLimit = 10

    let restaurants = [makeRestaurant(id: "a")]

    // Todos os picks retornam nil exceto o último (sem exclusões)
    mockRandomizer.pickResults = [nil, nil, restaurants.first]

    let result = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: ["a"])

    // Deve tentar: 1) todas exclusões, 2) só sessão, 3) sem exclusões
    XCTAssertEqual(mockRandomizer.pickCallCount, 3)
    XCTAssertNotNil(result)
  }

  func testPick_FallbackWithAvoidRepeatsZero_NoExtraAttempts() {
    avoidRepeatsLimit = 0

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = nil

    _ = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: ["a"])

    // Com avoidRepeats = 0, não há fallback intermediário
    // Apenas: 1) com sessionExcludes, 2) sem exclusões (fallback final)
    XCTAssertEqual(mockRandomizer.pickCallCount, 2)
  }

  // MARK: - History Provider Error

  func testPick_HistoryProviderThrows_ContinuesWithoutHistory() {
    mockHistoryProvider.shouldThrow = true
    avoidRepeatsLimit = 10

    let restaurants = [makeRestaurant(id: "a")]
    mockRandomizer.pickResult = restaurants.first

    let result = sut.pick(from: restaurants, context: PreferenceContext(), sessionExcludes: [])

    // Deve ter conseguido fazer pick mesmo com erro no history
    XCTAssertNotNil(result)
    // Exclusões devem ser vazias (sem histórico)
    XCTAssertTrue(mockRandomizer.lastExcludeIDs.isEmpty)
  }

  // MARK: - Available Candidates Count

  func testAvailableCandidatesCount_AllAvailable() {
    mockHistoryProvider.recentIDs = []
    avoidRepeatsLimit = 10

    let restaurants = [
      makeRestaurant(id: "a"),
      makeRestaurant(id: "b"),
      makeRestaurant(id: "c")
    ]

    let count = sut.availableCandidatesCount(
      from: restaurants,
      context: PreferenceContext(),
      sessionExcludes: []
    )

    XCTAssertEqual(count, 3)
  }

  func testAvailableCandidatesCount_SomeExcluded() {
    mockHistoryProvider.recentIDs = ["a"]
    avoidRepeatsLimit = 10

    let restaurants = [
      makeRestaurant(id: "a"),
      makeRestaurant(id: "b"),
      makeRestaurant(id: "c")
    ]

    let count = sut.availableCandidatesCount(
      from: restaurants,
      context: PreferenceContext(),
      sessionExcludes: ["b"]
    )

    // a excluído por histórico, b excluído por sessão, apenas c disponível
    XCTAssertEqual(count, 1)
  }

  func testWouldUseFallback_NoCandidates_ReturnsTrue() {
    mockHistoryProvider.recentIDs = ["a", "b"]
    avoidRepeatsLimit = 10

    let restaurants = [
      makeRestaurant(id: "a"),
      makeRestaurant(id: "b")
    ]

    let result = sut.wouldUseFallback(
      from: restaurants,
      context: PreferenceContext(),
      sessionExcludes: []
    )

    XCTAssertTrue(result)
  }

  func testWouldUseFallback_HasCandidates_ReturnsFalse() {
    mockHistoryProvider.recentIDs = ["a"]
    avoidRepeatsLimit = 10

    let restaurants = [
      makeRestaurant(id: "a"),
      makeRestaurant(id: "b"),
      makeRestaurant(id: "c")
    ]

    let result = sut.wouldUseFallback(
      from: restaurants,
      context: PreferenceContext(),
      sessionExcludes: []
    )

    XCTAssertFalse(result)
  }
}

// MARK: - Mocks

private class MockRandomizer: RestaurantRandomizerProtocol {
  var pickCallCount = 0
  var pickResult: Restaurant?
  var pickResults: [Restaurant?] = []
  var lastContext: PreferenceContext?
  var lastExcludeIDs: Set<String> = []

  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant? {
    pickCallCount += 1
    lastContext = context
    lastExcludeIDs = excludeRestaurantIDs

    if !pickResults.isEmpty {
      return pickResults.removeFirst()
    }
    return pickResult
  }
}

private class MockRecentHistory: RecentHistoryProviding {
  var recentIDs: [String] = []
  var shouldThrow = false

  func recentRestaurantIDs(limit: Int) throws -> [String] {
    if shouldThrow { throw NSError(domain: "MockError", code: 1) }
    return Array(recentIDs.prefix(limit))
  }
}

private class MockPrefsStore: LearnedPreferencesStoring {
  var preferences = LearnedPreferences.empty()
  var saveCalled = false
  var resetCalled = false

  func load() -> LearnedPreferences { preferences }
  func save(_ prefs: LearnedPreferences) { saveCalled = true; preferences = prefs }
  func reset() { resetCalled = true; preferences = .empty() }
}

// MARK: - Restaurant Fixture

private extension Restaurant {
  static func fixture(id: String) -> Restaurant {
    Restaurant(
      id: id,
      name: "Test \(id)",
      category: "Test",
      address: "Address",
      city: "City",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: 0,
      lng: 0,
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

