//
//  NearbyModeViewModelTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import XCTest

@testable import ChooseThere

// MARK: - Mock LocationManager

@MainActor
final class MockLocationManager: LocationManaging {
  var status: LocationStatus = .authorizedWhenInUse
  var currentLocation: CLLocationCoordinate2D?
  var isLoading: Bool = false
  var lastError: Error?
  
  var mockLocation: CLLocationCoordinate2D?
  var requestPermissionCalled = false
  var openSettingsCalled = false
  var updateStatusCalled = false

  func requestPermission() {
    requestPermissionCalled = true
  }

  func getCurrentLocation() async -> CLLocationCoordinate2D? {
    if lastError != nil {
      return nil
    }
    return mockLocation
  }

  func updateStatus() {
    updateStatusCalled = true
  }

  func openSettings() {
    openSettingsCalled = true
  }
}

// MARK: - Mock AppleMapsNearbySearchService

final class MockAppleMapsNearbySearchService: NearbySearching {
  var mockPlaces: [NearbyPlace] = []
  var mockError: Error?
  var searchCalled = false
  var lastSearchParams: (radiusKm: Int, category: String?, cityHint: String?)?

  func search(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace] {
    searchCalled = true
    lastSearchParams = (radiusKm, category, cityHint)

    if let error = mockError {
      throw error
    }

    return mockPlaces
  }

  func searchWithoutCache(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace] {
    return try await search(
      radiusKm: radiusKm,
      category: category,
      userCoordinate: userCoordinate,
      cityHint: cityHint
    )
  }
}

// MARK: - Mock RestaurantRepository

final class MockRestaurantRepository: RestaurantRepository {
  var mockRestaurants: [Restaurant] = []
  var mockError: Error?

  func fetchAll() throws -> [Restaurant] {
    if let error = mockError {
      throw error
    }
    return mockRestaurants
  }

  func fetch(id: String) throws -> Restaurant? {
    return mockRestaurants.first { $0.id == id }
  }

  func setFavorite(id: String, isFavorite: Bool) throws {
    // No-op for tests
  }

  func updateApplePlaceData(id: String, lat: Double, lng: Double, applePlaceName: String?, applePlaceAddress: String?) throws {
    // No-op for tests
  }

  func markApplePlaceUnresolved(id: String) throws {
    // No-op for tests
  }

  func updateRatingSnapshot(id: String, average: Double, count: Int, lastVisitedAt: Date?) throws {
    // No-op for tests
  }

  func fetchUnresolvedLocations() throws -> [Restaurant] {
    return []
  }

  func updateExternalLinks(id: String, tripAdvisorURL: URL?, iFoodURL: URL?, ride99URL: URL?, imageURL: URL?) throws {
    // No-op for tests
  }
  
  func updateExternalLink(id: String, externalLink: URL?) throws {
    // No-op for tests
  }
}

// MARK: - Mock RestaurantRandomizer

final class MockRestaurantRandomizer: RestaurantRandomizerProtocol {
  var mockPickedRestaurant: Restaurant?
  var pickCalled = false

  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant? {
    pickCalled = true
    if let picked = mockPickedRestaurant {
      if excludeRestaurantIDs.contains(picked.id) {
        // Return another restaurant if the mocked one is excluded
        return restaurants.first { !excludeRestaurantIDs.contains($0.id) }
      }
      return picked
    }
    return restaurants.first { !excludeRestaurantIDs.contains($0.id) }
  }
  
  func pickWithRatingFallback(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant? {
    return pick(from: restaurants, context: context, excludeRestaurantIDs: excludeRestaurantIDs)
  }
}

// MARK: - NearbyModeViewModelTests

@MainActor
final class NearbyModeViewModelTests: XCTestCase {
  private var viewModel: NearbyModeViewModel!
  private var mockLocationManager: MockLocationManager!
  private var mockRepository: MockRestaurantRepository!
  private var mockAppleMapsService: MockAppleMapsNearbySearchService!
  private var mockRandomizer: MockRestaurantRandomizer!

  private let paulistaCoordinate = CLLocationCoordinate2D(
    latitude: -23.5632,
    longitude: -46.6541
  )

  override func setUp() async throws {
    try await super.setUp()

    // Reset app settings before each test
    AppSettingsStorage.resetAll()

    mockLocationManager = MockLocationManager()
    mockRepository = MockRestaurantRepository()
    mockAppleMapsService = MockAppleMapsNearbySearchService()
    mockRandomizer = MockRestaurantRandomizer()

    // Configure mocks with default values
    mockLocationManager.status = .authorizedWhenInUse
    mockLocationManager.mockLocation = paulistaCoordinate

    viewModel = createViewModel()
  }

  override func tearDown() async throws {
    viewModel = nil
    mockLocationManager = nil
    mockRepository = nil
    mockAppleMapsService = nil
    mockRandomizer = nil
    AppSettingsStorage.resetAll()
    try await super.tearDown()
  }

  private func createViewModel() -> NearbyModeViewModel {
    NearbyModeViewModel(
      locationManager: mockLocationManager,
      restaurantRepository: mockRepository,
      filterService: NearbyLocalFilterService(),
      appleMapsService: mockAppleMapsService,
      randomizer: mockRandomizer
    )
  }

  // MARK: - Initial State Tests

  func testInitialStateIsIdle() {
    XCTAssertEqual(viewModel.searchState, .idle)
    XCTAssertTrue(viewModel.nearbyRestaurants.isEmpty)
    XCTAssertTrue(viewModel.nearbyPlaces.isEmpty)
  }

  func testInitialSourceIsLocalBase() {
    XCTAssertEqual(viewModel.source, .localBase)
  }

  func testInitialRadiusFromSettings() {
    AppSettingsStorage.nearbyRadiusKm = 5
    let vm = createViewModel()

    XCTAssertEqual(vm.radiusKm, 5)
  }

  // MARK: - Source Toggle Tests

  func testSourceToggleResetsState() async {
    // Setup initial state with results
    mockRepository.mockRestaurants = [makeRestaurant(id: "a")]
    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState, .localResults([makeRestaurant(id: "a")]))

    // Toggle source
    viewModel.source = .appleMaps

    // State should reset to idle
    XCTAssertEqual(viewModel.searchState, .idle)
    XCTAssertTrue(viewModel.nearbyRestaurants.isEmpty)
  }

  func testSourceTogglePersistsToSettings() {
    viewModel.source = .appleMaps

    XCTAssertEqual(AppSettingsStorage.nearbySource, .appleMaps)
  }

  // MARK: - Permission Tests

  func testSearchWithoutPermissionShowsNoPermissionState() async {
    mockLocationManager.status = .notDetermined

    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState, .noPermission)
    XCTAssertTrue(mockLocationManager.requestPermissionCalled)
  }

  func testSearchWithDeniedPermissionShowsNoPermissionState() async {
    mockLocationManager.status = .denied

    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState, .noPermission)
  }

  func testHasLocationPermissionReturnsCorrectValue() {
    mockLocationManager.status = .authorizedWhenInUse
    XCTAssertTrue(viewModel.hasLocationPermission)

    mockLocationManager.status = .denied
    XCTAssertFalse(viewModel.hasLocationPermission)
  }

  func testCanRequestPermissionReturnsCorrectValue() {
    mockLocationManager.status = .notDetermined
    XCTAssertTrue(viewModel.canRequestPermission)

    mockLocationManager.status = .denied
    XCTAssertFalse(viewModel.canRequestPermission)
  }

  func testOpenSettingsCallsLocationManager() {
    viewModel.openSettings()

    XCTAssertTrue(mockLocationManager.openSettingsCalled)
  }

  // MARK: - Local Base Search Tests

  func testSearchLocalBaseReturnsFilteredResults() async {
    let restaurants = [
      makeRestaurant(id: "close", lat: -23.5640, lng: -46.6545), // ~100m
      makeRestaurant(id: "far", lat: -23.70, lng: -46.80)        // ~20km
    ]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState.resultCount, 1)
    XCTAssertEqual(viewModel.nearbyRestaurants.first?.id, "close")
  }

  func testSearchLocalBaseWithNoResultsShowsNoResultsState() async {
    let restaurants = [
      makeRestaurant(id: "far", lat: -23.70, lng: -46.80) // ~20km
    ]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState, .noResults)
  }

  func testSearchLocalBaseWithErrorShowsErrorState() async {
    mockRepository.mockError = NSError(domain: "test", code: 500)

    await viewModel.searchNearby()

    if case .error(let message) = viewModel.searchState {
      XCTAssertTrue(message.contains("Erro ao buscar restaurantes"))
    } else {
      XCTFail("Expected error state")
    }
  }

  func testSearchLocalBaseFiltersByCategory() async {
    let restaurants = [
      makeRestaurant(id: "japanese", category: "Japonês", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "italian", category: "Italiano", lat: -23.5640, lng: -46.6545)
    ]
    mockRepository.mockRestaurants = restaurants
    viewModel.selectedCategory = "japonês"

    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState.resultCount, 1)
    XCTAssertEqual(viewModel.nearbyRestaurants.first?.id, "japanese")
  }

  // MARK: - Apple Maps Search Tests

  func testSearchAppleMapsReturnsResults() async {
    viewModel.source = .appleMaps
    mockAppleMapsService.mockPlaces = [
      makeNearbyPlace(id: "place1"),
      makeNearbyPlace(id: "place2")
    ]

    await viewModel.searchNearby()

    XCTAssertTrue(mockAppleMapsService.searchCalled)
    XCTAssertEqual(viewModel.searchState.resultCount, 2)
    XCTAssertEqual(viewModel.nearbyPlaces.count, 2)
  }

  func testSearchAppleMapsWithNoResultsShowsNoResultsState() async {
    viewModel.source = .appleMaps
    mockAppleMapsService.mockPlaces = []
    mockAppleMapsService.mockError = AppleMapsSearchError.noResults

    await viewModel.searchNearby()

    XCTAssertEqual(viewModel.searchState, .noResults)
  }

  func testSearchAppleMapsWithNetworkErrorShowsErrorState() async {
    viewModel.source = .appleMaps
    mockAppleMapsService.mockError = AppleMapsSearchError.networkError

    await viewModel.searchNearby()

    if case .error(let message) = viewModel.searchState {
      XCTAssertTrue(message.contains("conexão") || message.contains("internet"))
    } else {
      XCTFail("Expected error state")
    }
  }

  func testSearchAppleMapsPassesCorrectParameters() async {
    viewModel.source = .appleMaps
    viewModel.radiusKm = 5
    viewModel.selectedCategory = "bar"
    mockAppleMapsService.mockPlaces = [makeNearbyPlace(id: "place1")]

    await viewModel.searchNearby()

    XCTAssertEqual(mockAppleMapsService.lastSearchParams?.radiusKm, 5)
    XCTAssertEqual(mockAppleMapsService.lastSearchParams?.category, "bar")
  }

  // MARK: - Draw Tests (Local Base)

  func testDrawReturnsRestaurantId() async {
    let restaurants = [makeRestaurant(id: "test")]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()
    let drawnId = viewModel.draw()

    XCTAssertEqual(drawnId, "test")
    XCTAssertEqual(viewModel.selectedRestaurant?.id, "test")
  }

  func testDrawExcludesPreviouslyDrawn() async {
    let restaurants = [
      makeRestaurant(id: "first", lat: -23.5640, lng: -46.6545),
      makeRestaurant(id: "second", lat: -23.5641, lng: -46.6546)
    ]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()

    let first = viewModel.draw()
    let second = viewModel.draw()

    XCTAssertNotEqual(first, second)
  }

  func testDrawReturnsNilWhenAppleMapsSource() async {
    viewModel.source = .appleMaps
    mockAppleMapsService.mockPlaces = [makeNearbyPlace(id: "place1")]

    await viewModel.searchNearby()
    let drawnId = viewModel.draw()

    XCTAssertNil(drawnId)
  }

  // MARK: - Draw Place Tests (Apple Maps)

  func testDrawPlaceReturnsPlace() async {
    viewModel.source = .appleMaps
    mockAppleMapsService.mockPlaces = [makeNearbyPlace(id: "place1")]

    await viewModel.searchNearby()
    let drawn = viewModel.drawPlace()

    XCTAssertEqual(drawn?.id, "place1")
    XCTAssertEqual(viewModel.selectedPlace?.id, "place1")
  }

  func testDrawPlaceExcludesPreviouslyDrawn() async {
    viewModel.source = .appleMaps
    mockAppleMapsService.mockPlaces = [
      makeNearbyPlace(id: "place1"),
      makeNearbyPlace(id: "place2")
    ]

    await viewModel.searchNearby()

    let first = viewModel.drawPlace()
    let second = viewModel.drawPlace()

    XCTAssertNotEqual(first?.id, second?.id)
  }

  func testDrawPlaceReturnsNilWhenLocalBaseSource() async {
    let restaurants = [makeRestaurant(id: "test")]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()
    let drawn = viewModel.drawPlace()

    XCTAssertNil(drawn)
  }

  // MARK: - ReRoll Tests

  func testReRollLimitedToMaxReRolls() async {
    let restaurants = (1...5).map { makeRestaurant(id: "r\($0)", lat: -23.5640 + Double($0) * 0.0001, lng: -46.6545) }
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()

    // Initial draw
    _ = viewModel.draw()

    // Should be able to reroll 3 times
    XCTAssertTrue(viewModel.canReRoll)
    _ = viewModel.reRoll()
    _ = viewModel.reRoll()
    _ = viewModel.reRoll()

    // Fourth reroll should fail
    XCTAssertFalse(viewModel.canReRoll)
    XCTAssertNil(viewModel.reRoll())
  }

  // MARK: - Grouping Logic Tests

  func testGroupedResults_emptyState_returnsEmptyDictionary() {
    // Given: searchState = .idle (initial state)
    // When: access groupedResults
    let result = viewModel.groupedResults

    // Then: should return empty dictionary
    XCTAssertTrue(result.isEmpty)
  }

  func testGroupedResults_singleRestaurant_groupsCorrectly() async {
    // Given: 1 restaurant at 0.5km (veryClose bracket)
    let restaurant = makeRestaurant(id: "close", lat: -23.5636, lng: -46.6545) // ~0.5km
    mockRepository.mockRestaurants = [restaurant]

    // When: search and access groupedResults
    await viewModel.searchNearby()

    // Then: should be in veryClose bracket
    let result = viewModel.groupedResults
    XCTAssertEqual(result[.veryClose]?.count, 1)
    XCTAssertNil(result[.close])
    XCTAssertNil(result[.medium])
    XCTAssertNil(result[.far])
  }

  func testGroupedResults_multipleBrackets_distributesProperly() async {
    // Given: restaurants at different distances
    let restaurants = [
      makeRestaurant(id: "veryClose", lat: -23.5636, lng: -46.6545),  // ~0.5km
      makeRestaurant(id: "close", lat: -23.5800, lng: -46.6600),       // ~2km
      makeRestaurant(id: "medium", lat: -23.6000, lng: -46.6800),      // ~5km
      makeRestaurant(id: "far", lat: -23.6500, lng: -46.7200)          // ~12km
    ]
    mockRepository.mockRestaurants = restaurants
    viewModel.radiusKm = 15 // Increase radius to include all

    // When: search and access groupedResults
    await viewModel.searchNearby()

    // Then: each bracket should have 1 restaurant
    let result = viewModel.groupedResults
    XCTAssertEqual(result[.veryClose]?.count ?? 0, 1)
    XCTAssertEqual(result[.close]?.count ?? 0, 1)
    XCTAssertEqual(result[.medium]?.count ?? 0, 1)
    XCTAssertEqual(result[.far]?.count ?? 0, 1)
  }

  func testGroupedResults_sortsByRatingWithinGroup() async {
    // Given: 3 restaurants in same bracket with different ratings
    let restaurants = [
      makeRestaurantWithRating(id: "mid", rating: 4.5, lat: -23.5636, lng: -46.6545),
      makeRestaurantWithRating(id: "low", rating: 3.0, lat: -23.5637, lng: -46.6546),
      makeRestaurantWithRating(id: "high", rating: 5.0, lat: -23.5638, lng: -46.6547)
    ]
    mockRepository.mockRestaurants = restaurants

    // When: search and access groupedResults
    await viewModel.searchNearby()

    // Then: order should be [5.0, 4.5, 3.0]
    if let items = viewModel.groupedResults[.veryClose] {
      XCTAssertEqual(items.count, 3)
      XCTAssertEqual(items[0].displayRating, 5.0)
      XCTAssertEqual(items[1].displayRating, 4.5)
      XCTAssertEqual(items[2].displayRating, 3.0)
    } else {
      XCTFail("Expected items in veryClose bracket")
    }
  }

  func testGroupedResults_sortsByNameWhenNoRating() async {
    // Given: 3 restaurants without ratings (alphabetical order expected)
    let restaurants = [
      makeRestaurant(id: "zara", lat: -23.5636, lng: -46.6545),
      makeRestaurant(id: "apple", lat: -23.5637, lng: -46.6546),
      makeRestaurant(id: "mango", lat: -23.5638, lng: -46.6547)
    ]
    // Override names for alphabetical test
    mockRepository.mockRestaurants = [
      Restaurant(id: "zara", name: "Zara", category: "Restaurante", address: "Test", city: "São Paulo", state: "SP", tags: [], notes: "", externalLink: nil, lat: -23.5636, lng: -46.6545, isFavorite: false, applePlaceResolved: true, ratingAverage: 0, ratingCount: 0),
      Restaurant(id: "apple", name: "Apple", category: "Restaurante", address: "Test", city: "São Paulo", state: "SP", tags: [], notes: "", externalLink: nil, lat: -23.5637, lng: -46.6546, isFavorite: false, applePlaceResolved: true, ratingAverage: 0, ratingCount: 0),
      Restaurant(id: "mango", name: "Mango", category: "Restaurante", address: "Test", city: "São Paulo", state: "SP", tags: [], notes: "", externalLink: nil, lat: -23.5638, lng: -46.6547, isFavorite: false, applePlaceResolved: true, ratingAverage: 0, ratingCount: 0)
    ]

    // When: search and access groupedResults
    await viewModel.searchNearby()

    // Then: order should be alphabetical [Apple, Mango, Zara]
    if let items = viewModel.groupedResults[.veryClose] {
      XCTAssertEqual(items.count, 3)
      XCTAssertEqual(items[0].displayName, "Apple")
      XCTAssertEqual(items[1].displayName, "Mango")
      XCTAssertEqual(items[2].displayName, "Zara")
    } else {
      XCTFail("Expected items in veryClose bracket")
    }
  }

  func testVisibleBrackets_onlyReturnsNonEmptyBrackets() async {
    // Given: items only in veryClose and far
    let restaurants = [
      makeRestaurant(id: "veryClose", lat: -23.5636, lng: -46.6545),  // ~0.5km
      makeRestaurant(id: "far", lat: -23.6500, lng: -46.7200)         // ~12km
    ]
    mockRepository.mockRestaurants = restaurants
    viewModel.radiusKm = 15

    // When: search and access visibleBrackets
    await viewModel.searchNearby()

    // Then: should contain only veryClose and far
    let brackets = viewModel.visibleBrackets
    XCTAssertTrue(brackets.contains(.veryClose))
    XCTAssertTrue(brackets.contains(.far))
    XCTAssertFalse(brackets.contains(.close))
    XCTAssertFalse(brackets.contains(.medium))
  }

  func testVisibleBrackets_ordersCorrectly() async {
    // Given: items in far, veryClose, medium (unnatural order in data)
    let restaurants = [
      makeRestaurant(id: "far", lat: -23.6500, lng: -46.7200),         // ~12km
      makeRestaurant(id: "veryClose", lat: -23.5636, lng: -46.6545),   // ~0.5km
      makeRestaurant(id: "medium", lat: -23.6000, lng: -46.6800)       // ~5km
    ]
    mockRepository.mockRestaurants = restaurants
    viewModel.radiusKm = 15

    // When: search and access visibleBrackets
    await viewModel.searchNearby()

    // Then: should return in correct order [veryClose, medium, far]
    let brackets = viewModel.visibleBrackets
    XCTAssertEqual(brackets.count, 3)
    XCTAssertEqual(brackets[0], .veryClose)
    XCTAssertEqual(brackets[1], .medium)
    XCTAssertEqual(brackets[2], .far)
  }

  // MARK: - Reset Session Tests

  func testResetSessionClearsDrawnIds() async {
    let restaurants = [makeRestaurant(id: "test")]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()
    _ = viewModel.draw()

    viewModel.resetSession()

    // Should be able to draw the same restaurant again
    let drawnAgain = viewModel.draw()
    XCTAssertEqual(drawnAgain, "test")
  }

  func testResetSessionClearsSelectedRestaurant() async {
    let restaurants = [makeRestaurant(id: "test")]
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()
    _ = viewModel.draw()

    XCTAssertNotNil(viewModel.selectedRestaurant)

    viewModel.resetSession()

    XCTAssertNil(viewModel.selectedRestaurant)
  }

  func testResetSessionResetsReRollCount() async {
    let restaurants = (1...5).map { makeRestaurant(id: "r\($0)", lat: -23.5640 + Double($0) * 0.0001, lng: -46.6545) }
    mockRepository.mockRestaurants = restaurants

    await viewModel.searchNearby()
    _ = viewModel.draw()
    _ = viewModel.reRoll()
    _ = viewModel.reRoll()

    viewModel.resetSession()

    XCTAssertTrue(viewModel.canReRoll)
  }

  // MARK: - Radius and Category Persistence Tests

  func testRadiusChangesPersistToSettings() {
    viewModel.radiusKm = 7

    XCTAssertEqual(AppSettingsStorage.nearbyRadiusKm, 7)
  }

  func testCategoryChangesPersistToSettings() {
    viewModel.selectedCategory = "italian"

    XCTAssertEqual(AppSettingsStorage.nearbyLastCategory, "italian")
  }

  // MARK: - Location Error Tests

  func testSearchWithLocationErrorShowsErrorState() async {
    mockLocationManager.mockLocation = nil

    await viewModel.searchNearby()

    if case .error(let message) = viewModel.searchState {
      XCTAssertTrue(message.contains("localização"))
    } else {
      XCTFail("Expected error state")
    }
  }

  // MARK: - Helpers

  private func makeRestaurant(
    id: String,
    category: String = "Restaurante",
    lat: Double = -23.5640,
    lng: Double = -46.6545
  ) -> Restaurant {
    Restaurant(
      id: id,
      name: "Test \(id)",
      category: category,
      address: "Test Address",
      city: "São Paulo",
      state: "SP",
      tags: [],
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

  private func makeRestaurantWithRating(
    id: String,
    rating: Double,
    lat: Double = -23.5640,
    lng: Double = -46.6545
  ) -> Restaurant {
    Restaurant(
      id: id,
      name: "Test \(id)",
      category: "Restaurante",
      address: "Test Address",
      city: "São Paulo",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: lat,
      lng: lng,
      isFavorite: false,
      applePlaceResolved: true,
      applePlaceResolvedAt: nil,
      applePlaceName: nil,
      applePlaceAddress: nil,
      ratingAverage: rating,
      ratingCount: 10,
      ratingLastVisitedAt: nil
    )
  }

  private func makeNearbyPlace(id: String) -> NearbyPlace {
    NearbyPlace.create(
      name: "Place \(id)",
      address: "Address \(id)",
      latitude: -23.55,
      longitude: -46.63,
      categoryHint: "Restaurant"
    )
  }
}

// MARK: - NearbySearchState Tests

final class NearbySearchStateTests: XCTestCase {
  func testIsLoadingReturnsTrueOnlyForLoadingState() {
    XCTAssertTrue(NearbySearchState.loading.isLoading)
    XCTAssertFalse(NearbySearchState.idle.isLoading)
    XCTAssertFalse(NearbySearchState.noResults.isLoading)
  }

  func testHasResultsReturnsCorrectValue() {
    let restaurant = makeTestRestaurant()
    let place = NearbyPlace.create(
      name: "Test",
      latitude: -23.55,
      longitude: -46.63
    )

    XCTAssertTrue(NearbySearchState.localResults([restaurant]).hasResults)
    XCTAssertTrue(NearbySearchState.appleMapsResults([place]).hasResults)
    XCTAssertFalse(NearbySearchState.localResults([]).hasResults)
    XCTAssertFalse(NearbySearchState.idle.hasResults)
  }

  func testResultCountReturnsCorrectValue() {
    let restaurants = [makeTestRestaurant(), makeTestRestaurant()]
    let places = [
      NearbyPlace.create(name: "A", latitude: -23.55, longitude: -46.63),
      NearbyPlace.create(name: "B", latitude: -23.56, longitude: -46.64),
      NearbyPlace.create(name: "C", latitude: -23.57, longitude: -46.65)
    ]

    XCTAssertEqual(NearbySearchState.localResults(restaurants).resultCount, 2)
    XCTAssertEqual(NearbySearchState.appleMapsResults(places).resultCount, 3)
    XCTAssertEqual(NearbySearchState.idle.resultCount, 0)
  }

  func testEquality() {
    XCTAssertEqual(NearbySearchState.idle, NearbySearchState.idle)
    XCTAssertEqual(NearbySearchState.loading, NearbySearchState.loading)
    XCTAssertEqual(NearbySearchState.error("test"), NearbySearchState.error("test"))
    XCTAssertNotEqual(NearbySearchState.error("a"), NearbySearchState.error("b"))
    XCTAssertNotEqual(NearbySearchState.idle, NearbySearchState.loading)
  }

  private func makeTestRestaurant() -> Restaurant {
    Restaurant(
      id: UUID().uuidString,
      name: "Test",
      category: "Test",
      address: "Test",
      city: "SP",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: -23.55,
      lng: -46.63,
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

