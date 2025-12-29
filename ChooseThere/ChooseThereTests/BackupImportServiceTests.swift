//
//  BackupImportServiceTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import SwiftData
import XCTest
@testable import ChooseThere

final class BackupImportServiceTests: XCTestCase {
  // MARK: - Properties

  private var sut: BackupImportService!
  private var context: ModelContext!
  private var container: ModelContainer!

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    setupInMemoryContainer()
  }

  override func tearDown() {
    sut = nil
    context = nil
    container = nil
    super.tearDown()
  }

  // MARK: - Helper Methods

  private func setupInMemoryContainer() {
    let schema = Schema([RestaurantModel.self, VisitModel.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try! ModelContainer(for: schema, configurations: [configuration])
    context = ModelContext(container)
    sut = BackupImportService(context: context)
  }

  private func makeRestaurant(
    id: String,
    name: String,
    isFavorite: Bool = false
  ) -> BackupRestaurant {
    BackupRestaurant(
      id: id,
      name: name,
      category: "Teste",
      address: "Rua Teste",
      city: "São Paulo",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: -23.5505,
      lng: -46.6333,
      isFavorite: isFavorite
    )
  }

  private func makeVisit(
    id: UUID = UUID(),
    restaurantId: String,
    rating: Int = 4
  ) -> BackupVisit {
    BackupVisit(
      id: id,
      restaurantId: restaurantId,
      dateVisited: Date(),
      rating: rating,
      tags: [],
      note: nil,
      isMatch: true,
      wouldReturn: true
    )
  }

  private func makeBackup(
    restaurants: [BackupRestaurant],
    visits: [BackupVisit] = []
  ) -> BackupV1 {
    BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: "1.0.0",
      restaurants: restaurants,
      visits: visits
    )
  }

  private func countRestaurants() -> Int {
    let descriptor = FetchDescriptor<RestaurantModel>()
    return (try? context.fetch(descriptor).count) ?? 0
  }

  private func countVisits() -> Int {
    let descriptor = FetchDescriptor<VisitModel>()
    return (try? context.fetch(descriptor).count) ?? 0
  }

  private func fetchRestaurant(id: String) -> RestaurantModel? {
    var descriptor = FetchDescriptor<RestaurantModel>(
      predicate: #Predicate { $0.id == id }
    )
    descriptor.fetchLimit = 1
    return try? context.fetch(descriptor).first
  }

  private func fetchVisit(id: UUID) -> VisitModel? {
    let targetId = id
    var descriptor = FetchDescriptor<VisitModel>(
      predicate: #Predicate { $0.id == targetId }
    )
    descriptor.fetchLimit = 1
    return try? context.fetch(descriptor).first
  }

  private func insertRestaurant(id: String, name: String) {
    let model = RestaurantModel(
      id: id,
      name: name,
      category: "Existing",
      address: "Rua Existente",
      city: "São Paulo",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: 0,
      lng: 0
    )
    context.insert(model)
    try! context.save()
  }

  private func insertVisit(id: UUID, restaurantId: String) {
    let model = VisitModel(
      id: id,
      restaurantId: restaurantId,
      dateVisited: Date(),
      rating: 3,
      tags: [],
      note: nil,
      isMatch: false,
      wouldReturn: false
    )
    context.insert(model)
    try! context.save()
  }

  // MARK: - Replace All Tests

  func testReplaceAll_EmptyDatabase_ImportsAll() async throws {
    // Arrange
    let restaurants = [
      makeRestaurant(id: "1", name: "Rest 1"),
      makeRestaurant(id: "2", name: "Rest 2")
    ]
    let visits = [
      makeVisit(restaurantId: "1"),
      makeVisit(restaurantId: "2")
    ]
    let backup = makeBackup(restaurants: restaurants, visits: visits)

    // Act
    let result = try await sut.apply(backup, mode: .replaceAll)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 2)
    XCTAssertEqual(result.importedVisits, 2)
    XCTAssertEqual(result.updatedRestaurants, 0)
    XCTAssertEqual(result.updatedVisits, 0)
    XCTAssertEqual(countRestaurants(), 2)
    XCTAssertEqual(countVisits(), 2)
  }

  func testReplaceAll_ExistingData_ReplacesEverything() async throws {
    // Arrange
    insertRestaurant(id: "old-1", name: "Old Restaurant")
    insertVisit(id: UUID(), restaurantId: "old-1")

    XCTAssertEqual(countRestaurants(), 1)
    XCTAssertEqual(countVisits(), 1)

    let newRestaurants = [makeRestaurant(id: "new-1", name: "New Restaurant")]
    let newVisits = [makeVisit(restaurantId: "new-1")]
    let backup = makeBackup(restaurants: newRestaurants, visits: newVisits)

    // Act
    let result = try await sut.apply(backup, mode: .replaceAll)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 1)
    XCTAssertEqual(result.importedVisits, 1)
    XCTAssertEqual(countRestaurants(), 1)
    XCTAssertEqual(countVisits(), 1)

    // Verificar que os dados antigos não existem mais
    XCTAssertNil(fetchRestaurant(id: "old-1"))

    // Verificar que os novos dados existem
    let newRest = fetchRestaurant(id: "new-1")
    XCTAssertNotNil(newRest)
    XCTAssertEqual(newRest?.name, "New Restaurant")
  }

  func testReplaceAll_DeletesVisitsBeforeRestaurants() async throws {
    // Arrange: criar dados existentes com relação
    insertRestaurant(id: "rest-1", name: "Restaurant")
    insertVisit(id: UUID(), restaurantId: "rest-1")

    let backup = makeBackup(restaurants: [], visits: [])

    // Act
    let result = try await sut.apply(backup, mode: .replaceAll)

    // Assert: nenhum erro de integridade referencial
    XCTAssertEqual(result.importedRestaurants, 0)
    XCTAssertEqual(result.importedVisits, 0)
    XCTAssertEqual(countRestaurants(), 0)
    XCTAssertEqual(countVisits(), 0)
  }

  // MARK: - Merge By ID Tests

  func testMergeByID_EmptyDatabase_ImportsAll() async throws {
    // Arrange
    let restaurants = [
      makeRestaurant(id: "1", name: "Rest 1"),
      makeRestaurant(id: "2", name: "Rest 2")
    ]
    let visits = [
      makeVisit(restaurantId: "1"),
      makeVisit(restaurantId: "2")
    ]
    let backup = makeBackup(restaurants: restaurants, visits: visits)

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 2)
    XCTAssertEqual(result.importedVisits, 2)
    XCTAssertEqual(result.updatedRestaurants, 0)
    XCTAssertEqual(result.updatedVisits, 0)
    XCTAssertEqual(countRestaurants(), 2)
    XCTAssertEqual(countVisits(), 2)
  }

  func testMergeByID_ExistingData_PreservesLocalData() async throws {
    // Arrange
    insertRestaurant(id: "local-1", name: "Local Restaurant")

    let backupRestaurants = [makeRestaurant(id: "backup-1", name: "Backup Restaurant")]
    let backup = makeBackup(restaurants: backupRestaurants)

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 1)
    XCTAssertEqual(result.updatedRestaurants, 0)

    // Ambos os restaurantes devem existir
    XCTAssertEqual(countRestaurants(), 2)
    XCTAssertNotNil(fetchRestaurant(id: "local-1"))
    XCTAssertNotNil(fetchRestaurant(id: "backup-1"))
  }

  func testMergeByID_SameID_UpdatesExisting() async throws {
    // Arrange
    insertRestaurant(id: "rest-1", name: "Original Name")

    let original = fetchRestaurant(id: "rest-1")
    XCTAssertEqual(original?.name, "Original Name")

    let backupRestaurants = [makeRestaurant(id: "rest-1", name: "Updated Name")]
    let backup = makeBackup(restaurants: backupRestaurants)

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 0)
    XCTAssertEqual(result.updatedRestaurants, 1)
    XCTAssertEqual(countRestaurants(), 1)

    let updated = fetchRestaurant(id: "rest-1")
    XCTAssertEqual(updated?.name, "Updated Name")
  }

  func testMergeByID_VisitsSameID_UpdatesExisting() async throws {
    // Arrange
    insertRestaurant(id: "rest-1", name: "Restaurant")
    let visitId = UUID()
    insertVisit(id: visitId, restaurantId: "rest-1")

    let original = fetchVisit(id: visitId)
    XCTAssertEqual(original?.rating, 3)

    let backupVisits = [makeVisit(id: visitId, restaurantId: "rest-1", rating: 5)]
    let backup = makeBackup(restaurants: [], visits: backupVisits)

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.importedVisits, 0)
    XCTAssertEqual(result.updatedVisits, 1)
    XCTAssertEqual(countVisits(), 1)

    let updated = fetchVisit(id: visitId)
    XCTAssertEqual(updated?.rating, 5)
  }

  func testMergeByID_MixedNewAndExisting() async throws {
    // Arrange
    insertRestaurant(id: "existing-1", name: "Existing")

    let backupRestaurants = [
      makeRestaurant(id: "existing-1", name: "Existing Updated"),
      makeRestaurant(id: "new-1", name: "New")
    ]
    let backup = makeBackup(restaurants: backupRestaurants)

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 1)
    XCTAssertEqual(result.updatedRestaurants, 1)
    XCTAssertEqual(countRestaurants(), 2)

    let existing = fetchRestaurant(id: "existing-1")
    XCTAssertEqual(existing?.name, "Existing Updated")

    let new = fetchRestaurant(id: "new-1")
    XCTAssertEqual(new?.name, "New")
  }

  // MARK: - Data Integrity Tests

  func testMergeByID_UpdatesFavoriteStatus() async throws {
    // Arrange
    insertRestaurant(id: "rest-1", name: "Restaurant")

    let original = fetchRestaurant(id: "rest-1")
    XCTAssertFalse(original?.isFavorite ?? true)

    let backupRestaurants = [makeRestaurant(id: "rest-1", name: "Restaurant", isFavorite: true)]
    let backup = makeBackup(restaurants: backupRestaurants)

    // Act
    _ = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    let updated = fetchRestaurant(id: "rest-1")
    XCTAssertTrue(updated?.isFavorite ?? false)
  }

  func testReplaceAll_PreservesDataStructure() async throws {
    // Arrange
    let restaurants = [makeRestaurant(id: "1", name: "Rest 1")]
    let visits = [makeVisit(restaurantId: "1", rating: 5)]
    let backup = makeBackup(restaurants: restaurants, visits: visits)

    // Act
    _ = try await sut.apply(backup, mode: .replaceAll)

    // Assert
    let rest = fetchRestaurant(id: "1")
    XCTAssertNotNil(rest)
    XCTAssertEqual(rest?.name, "Rest 1")

    let visitDescriptor = FetchDescriptor<VisitModel>()
    let allVisits = try context.fetch(visitDescriptor)
    XCTAssertEqual(allVisits.count, 1)
    XCTAssertEqual(allVisits.first?.restaurantId, "1")
    XCTAssertEqual(allVisits.first?.rating, 5)
  }

  // MARK: - Edge Cases

  func testReplaceAll_EmptyBackup_ClearsDatabase() async throws {
    // Arrange
    insertRestaurant(id: "1", name: "Rest 1")

    let backup = makeBackup(restaurants: [])

    // Act
    let result = try await sut.apply(backup, mode: .replaceAll)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 0)
    XCTAssertEqual(countRestaurants(), 0)
  }

  func testMergeByID_EmptyBackup_PreservesLocalData() async throws {
    // Arrange
    insertRestaurant(id: "1", name: "Rest 1")

    let backup = makeBackup(restaurants: [])

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 0)
    XCTAssertEqual(result.updatedRestaurants, 0)
    XCTAssertEqual(countRestaurants(), 1)
  }

  func testReplaceAll_LargeBackup_ImportsAll() async throws {
    // Arrange
    let restaurants = (1...100).map { makeRestaurant(id: "\($0)", name: "Rest \($0)") }
    let backup = makeBackup(restaurants: restaurants)

    // Act
    let result = try await sut.apply(backup, mode: .replaceAll)

    // Assert
    XCTAssertEqual(result.importedRestaurants, 100)
    XCTAssertEqual(countRestaurants(), 100)
  }

  func testMergeByID_DuplicateVisitIDs_UpdatesEach() async throws {
    // Arrange
    insertRestaurant(id: "rest-1", name: "Restaurant")

    let visit1Id = UUID()
    let visit2Id = UUID()

    insertVisit(id: visit1Id, restaurantId: "rest-1")
    insertVisit(id: visit2Id, restaurantId: "rest-1")

    XCTAssertEqual(countVisits(), 2)

    let backupVisits = [
      makeVisit(id: visit1Id, restaurantId: "rest-1", rating: 5),
      makeVisit(id: visit2Id, restaurantId: "rest-1", rating: 4)
    ]
    let backup = makeBackup(restaurants: [], visits: backupVisits)

    // Act
    let result = try await sut.apply(backup, mode: .mergeByID)

    // Assert
    XCTAssertEqual(result.updatedVisits, 2)
    XCTAssertEqual(countVisits(), 2)

    let updated1 = fetchVisit(id: visit1Id)
    XCTAssertEqual(updated1?.rating, 5)

    let updated2 = fetchVisit(id: visit2Id)
    XCTAssertEqual(updated2?.rating, 4)
  }

  // MARK: - Result Summary Tests

  func testBackupImportResult_Summary_CorrectlyFormats() {
    let result = BackupImportResult(
      importedRestaurants: 10,
      updatedRestaurants: 5,
      importedVisits: 20,
      updatedVisits: 8,
      skippedInvalidEntries: 0
    )

    let summary = result.summary
    XCTAssertTrue(summary.contains("10 restaurante(s) importado(s)"))
    XCTAssertTrue(summary.contains("5 restaurante(s) atualizado(s)"))
    XCTAssertTrue(summary.contains("20 visita(s) importada(s)"))
    XCTAssertTrue(summary.contains("8 visita(s) atualizada(s)"))
  }

  func testBackupImportResult_TotalAffected() {
    let result = BackupImportResult(
      importedRestaurants: 10,
      updatedRestaurants: 5,
      importedVisits: 20,
      updatedVisits: 8,
      skippedInvalidEntries: 2
    )

    XCTAssertEqual(result.totalRestaurantsAffected, 15)
    XCTAssertEqual(result.totalVisitsAffected, 28)
    XCTAssertTrue(result.hasSkippedEntries)
  }
}

