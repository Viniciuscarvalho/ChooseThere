//
//  NearbyRouletteServiceTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 01/01/26.
//

import CoreLocation
import Testing
@testable import ChooseThere

@Suite("NearbyRouletteService Tests")
struct NearbyRouletteServiceTests {
  
  // MARK: - Mock Dependencies
  
  final class MockNearbySearchService: NearbySearching {
    var placesToReturn: [NearbyPlace] = []
    var shouldThrowError: AppleMapsSearchError?
    
    func search(
      radiusKm: Int,
      category: String?,
      userCoordinate: CLLocationCoordinate2D,
      cityHint: String?
    ) async throws -> [NearbyPlace] {
      if let error = shouldThrowError {
        throw error
      }
      return placesToReturn
    }
    
    func searchWithoutCache(
      radiusKm: Int,
      category: String?,
      userCoordinate: CLLocationCoordinate2D,
      cityHint: String?
    ) async throws -> [NearbyPlace] {
      return try await search(radiusKm: radiusKm, category: category, userCoordinate: userCoordinate, cityHint: cityHint)
    }
  }
  
  final class MockRestaurantRepository: RestaurantRepository {
    var restaurants: [Restaurant] = []
    
    func fetchAll() throws -> [Restaurant] {
      return restaurants
    }
    
    func fetch(id: String) throws -> Restaurant? {
      return restaurants.first { $0.id == id }
    }
    
    func setFavorite(id: String, isFavorite: Bool) throws {}
    
    func updateApplePlaceData(id: String, lat: Double, lng: Double, applePlaceName: String?, applePlaceAddress: String?) throws {}
    
    func markApplePlaceUnresolved(id: String) throws {}
    
    func updateRatingSnapshot(id: String, average: Double, count: Int, lastVisitedAt: Date?) throws {}
    
    func fetchUnresolvedLocations() throws -> [Restaurant] { [] }
    
    func updateExternalLinks(id: String, tripAdvisorURL: URL?, iFoodURL: URL?, ride99URL: URL?, imageURL: URL?) throws {}
    
    func updateExternalLink(id: String, externalLink: URL?) throws {}
  }
  
  // MARK: - Test Data
  
  static let testCoordinate = CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333)
  
  static func makeNearbyPlace(
    name: String,
    latitude: Double = -23.5505,
    longitude: Double = -46.6333,
    categoryHint: String? = nil
  ) -> NearbyPlace {
    NearbyPlace.create(
      name: name,
      address: "Test Address, São Paulo, SP",
      latitude: latitude,
      longitude: longitude,
      categoryHint: categoryHint
    )
  }
  
  // MARK: - Tests
  
  @Test("Sorteio retorna resultado quando há lugares disponíveis")
  func drawReturnsResultWhenPlacesAvailable() async throws {
    let mockSearch = MockNearbySearchService()
    mockSearch.placesToReturn = [
      Self.makeNearbyPlace(name: "Sushi Bar", categoryHint: "Japonês"),
      Self.makeNearbyPlace(name: "Pizza Place", categoryHint: "Pizza")
    ]
    
    let mockRepo = MockRestaurantRepository()
    let service = NearbyRouletteService(
      appleMapsService: mockSearch,
      restaurantRepository: mockRepo
    )
    
    let context = PreferenceContext()
    let result = try await service.draw(
      context: context,
      userCoordinate: Self.testCoordinate,
      sessionExcludes: []
    )
    
    #expect(!result.restaurant.name.isEmpty)
    #expect(result.distanceMeters >= 0)
  }
  
  @Test("Sorteio lança erro quando não há resultados")
  func drawThrowsWhenNoResults() async throws {
    let mockSearch = MockNearbySearchService()
    mockSearch.shouldThrowError = .noResults
    
    let mockRepo = MockRestaurantRepository()
    let service = NearbyRouletteService(
      appleMapsService: mockSearch,
      restaurantRepository: mockRepo
    )
    
    let context = PreferenceContext()
    
    await #expect(throws: NearbyRouletteError.self) {
      try await service.draw(
        context: context,
        userCoordinate: Self.testCoordinate,
        sessionExcludes: []
      )
    }
  }
  
  @Test("Sorteio respeita raio máximo de 10km")
  func drawRespectsMaxRadius() async throws {
    let mockSearch = MockNearbySearchService()
    mockSearch.placesToReturn = [Self.makeNearbyPlace(name: "Test Restaurant")]
    
    let mockRepo = MockRestaurantRepository()
    let service = NearbyRouletteService(
      appleMapsService: mockSearch,
      restaurantRepository: mockRepo
    )
    
    // Contexto com raio maior que 10km deve ser limitado
    let context = PreferenceContext(radiusKm: 20)
    
    // Não deve lançar erro
    let result = try await service.draw(
      context: context,
      userCoordinate: Self.testCoordinate,
      sessionExcludes: []
    )
    
    #expect(!result.restaurant.name.isEmpty)
  }
  
  @Test("Sorteio usa restaurante local quando há match")
  func drawUsesLocalRestaurantWhenMatched() async throws {
    let mockSearch = MockNearbySearchService()
    mockSearch.placesToReturn = [
      Self.makeNearbyPlace(name: "Izakaya Matsu", latitude: -23.5505, longitude: -46.6333)
    ]
    
    let mockRepo = MockRestaurantRepository()
    mockRepo.restaurants = [
      Restaurant(
        id: "izakaya-matsu",
        name: "Izakaya Matsu",
        category: "Japonês",
        address: "Rua Test",
        city: "São Paulo",
        state: "SP",
        tags: ["japonês", "sushi", "izakaya"],
        notes: "",
        lat: -23.5505,
        lng: -46.6333,
        ratingAverage: 4.5,
        ratingCount: 10
      )
    ]
    
    let service = NearbyRouletteService(
      appleMapsService: mockSearch,
      restaurantRepository: mockRepo
    )
    
    let context = PreferenceContext()
    let result = try await service.draw(
      context: context,
      userCoordinate: Self.testCoordinate,
      sessionExcludes: []
    )
    
    #expect(result.isFromLocalBase)
    #expect(result.restaurant.id == "izakaya-matsu")
    #expect(result.restaurant.tags.contains("japonês"))
  }
  
  @Test("Sorteio cria candidato transitório quando não há match local")
  func drawCreatesTransitoryCandidateWhenNoLocalMatch() async throws {
    let mockSearch = MockNearbySearchService()
    mockSearch.placesToReturn = [
      Self.makeNearbyPlace(name: "New Restaurant", categoryHint: "Italiano")
    ]
    
    let mockRepo = MockRestaurantRepository()
    // Repo vazio - sem restaurantes locais
    
    let service = NearbyRouletteService(
      appleMapsService: mockSearch,
      restaurantRepository: mockRepo
    )
    
    let context = PreferenceContext()
    let result = try await service.draw(
      context: context,
      userCoordinate: Self.testCoordinate,
      sessionExcludes: []
    )
    
    #expect(!result.isFromLocalBase)
    #expect(result.restaurant.name == "New Restaurant")
  }
}

