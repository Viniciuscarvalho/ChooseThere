//
//  NearbyCacheStoreTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import XCTest
@testable import ChooseThere

final class NearbyCacheStoreTests: XCTestCase {
  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    // Limpar cache antes de cada teste
    NearbyCacheStore.clear()
  }

  override func tearDown() {
    // Limpar cache após cada teste
    NearbyCacheStore.clear()
    super.tearDown()
  }

  // MARK: - Helper Methods

  private func createTestPlaces() -> [NearbyPlace] {
    [
      NearbyPlace.create(
        name: "Restaurante Teste 1",
        address: "Rua Teste, 100",
        latitude: -23.5505,
        longitude: -46.6333,
        categoryHint: "Restaurante"
      ),
      NearbyPlace.create(
        name: "Restaurante Teste 2",
        address: "Av. Teste, 200",
        latitude: -23.5510,
        longitude: -46.6340,
        categoryHint: "Café"
      )
    ]
  }

  private func createCacheKey(
    category: String? = nil,
    radiusKm: Int = 3,
    cityHint: String? = nil,
    latitude: Double = -23.5505,
    longitude: Double = -46.6333
  ) -> NearbyCacheKey {
    NearbyCacheKey.make(
      category: category,
      radiusKm: radiusKm,
      cityHint: cityHint,
      latitude: latitude,
      longitude: longitude
    )
  }

  private func encodePlaces(_ places: [NearbyPlace]) -> Data {
    try! JSONEncoder().encode(places)
  }

  // MARK: - Cache Key Tests

  func testCacheKeyCreation() {
    let key = createCacheKey(category: "japonês", radiusKm: 5)

    XCTAssertEqual(key.source, "appleMaps")
    XCTAssertEqual(key.category, "japonês")
    XCTAssertEqual(key.radiusKm, 5)
  }

  func testCacheKeyLocationBucket() {
    // Coordenadas próximas devem gerar o mesmo bucket
    let key1 = createCacheKey(latitude: -23.5505, longitude: -46.6333)
    let key2 = createCacheKey(latitude: -23.5508, longitude: -46.6331)

    // Arredondamento com 2 casas decimais: -23.55 | -46.63
    XCTAssertEqual(key1.locationBucket, key2.locationBucket)
  }

  func testCacheKeyDifferentLocationBuckets() {
    // Coordenadas distantes devem gerar buckets diferentes
    let key1 = createCacheKey(latitude: -23.5505, longitude: -46.6333)
    let key2 = createCacheKey(latitude: -23.5605, longitude: -46.6433)

    XCTAssertNotEqual(key1.locationBucket, key2.locationBucket)
  }

  func testCacheKeyEquality() {
    let key1 = createCacheKey(category: "bar", radiusKm: 3)
    let key2 = createCacheKey(category: "bar", radiusKm: 3)

    XCTAssertEqual(key1, key2)
    XCTAssertEqual(key1.hashValue, key2.hashValue)
  }

  func testCacheKeyDifferentCategories() {
    let key1 = createCacheKey(category: "bar")
    let key2 = createCacheKey(category: "café")

    XCTAssertNotEqual(key1, key2)
  }

  func testCacheKeyDifferentRadius() {
    let key1 = createCacheKey(radiusKm: 3)
    let key2 = createCacheKey(radiusKm: 5)

    XCTAssertNotEqual(key1, key2)
  }

  // MARK: - Cache Set/Get Tests

  func testCacheSetAndGet() {
    let key = createCacheKey()
    let places = createTestPlaces()
    let data = encodePlaces(places)

    NearbyCacheStore.set(data, for: key)
    let retrieved = NearbyCacheStore.get(for: key)

    XCTAssertNotNil(retrieved)

    let decodedPlaces = try! JSONDecoder().decode([NearbyPlace].self, from: retrieved!)
    XCTAssertEqual(decodedPlaces.count, places.count)
    XCTAssertEqual(decodedPlaces[0].name, places[0].name)
  }

  func testCacheMiss() {
    let key = createCacheKey(category: "inexistente")
    let retrieved = NearbyCacheStore.get(for: key)

    XCTAssertNil(retrieved)
  }

  func testCacheRemove() {
    let key = createCacheKey()
    let places = createTestPlaces()
    let data = encodePlaces(places)

    NearbyCacheStore.set(data, for: key)
    XCTAssertNotNil(NearbyCacheStore.get(for: key))

    NearbyCacheStore.remove(for: key)
    XCTAssertNil(NearbyCacheStore.get(for: key))
  }

  func testCacheClear() {
    let key1 = createCacheKey(category: "japonês")
    let key2 = createCacheKey(category: "italiano")
    let places = createTestPlaces()
    let data = encodePlaces(places)

    NearbyCacheStore.set(data, for: key1)
    NearbyCacheStore.set(data, for: key2)

    XCTAssertNotNil(NearbyCacheStore.get(for: key1))
    XCTAssertNotNil(NearbyCacheStore.get(for: key2))

    NearbyCacheStore.clear()

    XCTAssertNil(NearbyCacheStore.get(for: key1))
    XCTAssertNil(NearbyCacheStore.get(for: key2))
  }

  // MARK: - Cache Count Tests

  func testCacheCount() {
    XCTAssertEqual(NearbyCacheStore.count, 0)

    let key1 = createCacheKey(category: "japonês")
    let key2 = createCacheKey(category: "italiano")
    let data = encodePlaces(createTestPlaces())

    NearbyCacheStore.set(data, for: key1)
    XCTAssertEqual(NearbyCacheStore.count, 1)

    NearbyCacheStore.set(data, for: key2)
    XCTAssertEqual(NearbyCacheStore.count, 2)
  }

  // MARK: - TTL Tests

  func testCacheTTLExpiration() {
    let key = createCacheKey()
    let places = createTestPlaces()
    let data = encodePlaces(places)

    // Definir TTL muito curto (1 segundo)
    NearbyCacheStore.set(data, for: key, ttlSeconds: 1)

    // Imediatamente após, deve estar disponível
    XCTAssertNotNil(NearbyCacheStore.get(for: key))

    // Esperar expiração
    Thread.sleep(forTimeInterval: 1.5)

    // Após TTL, deve retornar nil
    XCTAssertNil(NearbyCacheStore.get(for: key))
  }

  func testCacheValidCount() {
    let key1 = createCacheKey(category: "japonês")
    let key2 = createCacheKey(category: "italiano")
    let data = encodePlaces(createTestPlaces())

    // Uma entrada com TTL curto, outra com TTL longo
    NearbyCacheStore.set(data, for: key1, ttlSeconds: 1)
    NearbyCacheStore.set(data, for: key2, ttlSeconds: 3600)

    XCTAssertEqual(NearbyCacheStore.count, 2)
    XCTAssertEqual(NearbyCacheStore.validCount, 2)

    // Esperar primeira expirar
    Thread.sleep(forTimeInterval: 1.5)

    XCTAssertEqual(NearbyCacheStore.count, 2) // Ainda 2 entradas
    XCTAssertEqual(NearbyCacheStore.validCount, 1) // Apenas 1 válida
  }

  func testPruneExpired() {
    let key1 = createCacheKey(category: "japonês")
    let key2 = createCacheKey(category: "italiano")
    let data = encodePlaces(createTestPlaces())

    NearbyCacheStore.set(data, for: key1, ttlSeconds: 1)
    NearbyCacheStore.set(data, for: key2, ttlSeconds: 3600)

    // Esperar primeira expirar
    Thread.sleep(forTimeInterval: 1.5)

    XCTAssertEqual(NearbyCacheStore.count, 2)

    // Limpar expiradas
    NearbyCacheStore.pruneExpired()

    XCTAssertEqual(NearbyCacheStore.count, 1)
    XCTAssertNil(NearbyCacheStore.get(for: key1))
    XCTAssertNotNil(NearbyCacheStore.get(for: key2))
  }

  // MARK: - Cache Entry Tests

  func testCacheEntryIsExpired() {
    let key = createCacheKey()
    let entry = NearbyCacheEntry(
      key: key,
      createdAt: Date().addingTimeInterval(-3600), // 1 hora atrás
      ttlSeconds: 1800, // 30 minutos
      placesData: Data()
    )

    XCTAssertTrue(entry.isExpired)
  }

  func testCacheEntryIsNotExpired() {
    let key = createCacheKey()
    let entry = NearbyCacheEntry(
      key: key,
      createdAt: Date(),
      ttlSeconds: 1800,
      placesData: Data()
    )

    XCTAssertFalse(entry.isExpired)
  }

  // MARK: - Default TTL Test

  func testDefaultTTL() {
    // Default TTL deve ser 30 minutos (1800 segundos)
    XCTAssertEqual(NearbyCacheStore.defaultTTLSeconds, 30 * 60)
  }

  // MARK: - Update Existing Entry

  func testUpdateExistingEntry() {
    let key = createCacheKey()
    let places1 = [createTestPlaces()[0]]
    let places2 = createTestPlaces()

    NearbyCacheStore.set(encodePlaces(places1), for: key)

    var retrieved = NearbyCacheStore.get(for: key)
    var decoded = try! JSONDecoder().decode([NearbyPlace].self, from: retrieved!)
    XCTAssertEqual(decoded.count, 1)

    // Atualizar com mais lugares
    NearbyCacheStore.set(encodePlaces(places2), for: key)

    retrieved = NearbyCacheStore.get(for: key)
    decoded = try! JSONDecoder().decode([NearbyPlace].self, from: retrieved!)
    XCTAssertEqual(decoded.count, 2)
  }
}

