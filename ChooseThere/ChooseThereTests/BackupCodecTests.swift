//
//  BackupCodecTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import XCTest
@testable import ChooseThere

final class BackupCodecTests: XCTestCase {
  // MARK: - Properties

  private var sut: BackupCodec!

  // MARK: - Setup/Teardown

  override func setUp() {
    super.setUp()
    sut = BackupCodec()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  // MARK: - Helper Methods

  private func makeValidRestaurant(
    id: String = "rest-001",
    name: String = "Restaurante Teste"
  ) -> BackupRestaurant {
    BackupRestaurant(
      id: id,
      name: name,
      category: "Japonês",
      address: "Rua Teste, 123",
      city: "São Paulo",
      state: "SP",
      tags: ["sushi", "japonês"],
      notes: "Ótimo sushi",
      externalLink: nil,
      lat: -23.5505,
      lng: -46.6333,
      isFavorite: true,
      ratingAverage: 4.5,
      ratingCount: 10,
      ratingLastVisitedAt: Date())
  }

  private func makeValidVisit(
    id: UUID = UUID(),
    restaurantId: String = "rest-001"
  ) -> BackupVisit {
    BackupVisit(
      id: id,
      restaurantId: restaurantId,
      dateVisited: Date().addingTimeInterval(-86400),
      rating: 4,
      tags: ["almoço"],
      note: "Muito bom!",
      isMatch: true,
      wouldReturn: true)
  }

  private func makeValidBackup(
    restaurants: [BackupRestaurant]? = nil,
    visits: [BackupVisit]? = nil
  ) -> BackupV1 {
    let rest = restaurants ?? [makeValidRestaurant()]
    let vis = visits ?? [makeValidVisit()]
    return BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: "1.0.0",
      restaurants: rest,
      visits: vis)
  }

  // MARK: - Encode Tests

  func testEncode_ValidBackup_ReturnsData() throws {
    let backup = makeValidBackup()

    let data = try sut.encode(backup)

    XCTAssertFalse(data.isEmpty)
  }

  func testEncode_ValidBackup_ProducesValidJSON() throws {
    let backup = makeValidBackup()

    let data = try sut.encode(backup)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    XCTAssertNotNil(json)
    XCTAssertEqual(json?["schemaVersion"] as? Int, 1)
  }

  func testEncode_IncludesAllRequiredFields() throws {
    let backup = makeValidBackup()

    let data = try sut.encode(backup)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    XCTAssertNotNil(json?["schemaVersion"])
    XCTAssertNotNil(json?["createdAt"])
    XCTAssertNotNil(json?["restaurants"])
    XCTAssertNotNil(json?["visits"])
  }

  // MARK: - Decode Tests

  func testDecode_ValidJSON_ReturnsBackup() throws {
    let original = makeValidBackup()
    let data = try sut.encode(original)

    let decoded = try sut.decode(from: data)

    XCTAssertEqual(decoded.schemaVersion, original.schemaVersion)
    XCTAssertEqual(decoded.restaurants.count, original.restaurants.count)
    XCTAssertEqual(decoded.visits.count, original.visits.count)
  }

  func testDecode_InvalidJSON_ThrowsError() {
    let invalidData = "not json".data(using: .utf8)!

    XCTAssertThrowsError(try sut.decode(from: invalidData)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .invalidJSON = backupError {
        // Success
      } else {
        XCTFail("Expected invalidJSON error")
      }
    }
  }

  func testDecode_MissingSchemaVersion_ThrowsError() {
    let json = """
      {
        "createdAt": "2025-01-01T00:00:00Z",
        "restaurants": [],
        "visits": []
      }
      """
    let data = json.data(using: .utf8)!

    XCTAssertThrowsError(try sut.decode(from: data)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .missingRequiredField(let field) = backupError {
        XCTAssertEqual(field, "schemaVersion")
      } else {
        XCTFail("Expected missingRequiredField error")
      }
    }
  }

  // MARK: - Roundtrip Tests

  func testRoundtrip_PreservesAllData() throws {
    let restaurant = makeValidRestaurant(id: "unique-123", name: "Sushi Place")
    let visit = makeValidVisit(restaurantId: "unique-123")
    let original = BackupV1(
      schemaVersion: 1,
      createdAt: Date(timeIntervalSince1970: 1700000000),
      appVersion: "2.0.0",
      restaurants: [restaurant],
      visits: [visit])

    let data = try sut.encode(original)
    let decoded = try sut.decode(from: data)

    XCTAssertEqual(decoded.schemaVersion, original.schemaVersion)
    XCTAssertEqual(decoded.appVersion, original.appVersion)
    XCTAssertEqual(decoded.restaurants.count, 1)
    XCTAssertEqual(decoded.restaurants[0].id, restaurant.id)
    XCTAssertEqual(decoded.restaurants[0].name, restaurant.name)
    XCTAssertEqual(decoded.restaurants[0].isFavorite, restaurant.isFavorite)
    XCTAssertEqual(decoded.visits.count, 1)
    XCTAssertEqual(decoded.visits[0].restaurantId, visit.restaurantId)
    XCTAssertEqual(decoded.visits[0].rating, visit.rating)
  }

  // MARK: - Validation Tests

  func testValidate_ValidBackup_NoThrow() throws {
    let backup = makeValidBackup()

    XCTAssertNoThrow(try sut.validate(backup, strict: true))
  }

  func testValidate_UnsupportedVersion_ThrowsError() {
    let backup = BackupV1(
      schemaVersion: 99,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [makeValidRestaurant()],
      visits: [])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .unsupportedSchemaVersion(let version) = backupError {
        XCTAssertEqual(version, 99)
      } else {
        XCTFail("Expected unsupportedSchemaVersion error")
      }
    }
  }

  func testValidate_EmptyBackup_ThrowsError() {
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [],
      visits: [])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .emptyBackup = backupError {
        // Success
      } else {
        XCTFail("Expected emptyBackup error")
      }
    }
  }

  func testValidate_FutureCreatedAt_ThrowsError() {
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date().addingTimeInterval(86400 * 365), // 1 year in future
      appVersion: nil,
      restaurants: [makeValidRestaurant()],
      visits: [])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .futureDate = backupError {
        // Success
      } else {
        XCTFail("Expected futureDate error")
      }
    }
  }

  func testValidate_RestaurantEmptyID_ThrowsError() {
    let invalidRestaurant = BackupRestaurant(
      id: "   ",
      name: "Test",
      category: "Test",
      address: "Test",
      city: "Test",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: 0,
      lng: 0,
      isFavorite: false)
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [invalidRestaurant],
      visits: [])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .invalidRestaurantData(_, let reason) = backupError {
        XCTAssertTrue(reason.contains("ID vazio"))
      } else {
        XCTFail("Expected invalidRestaurantData error")
      }
    }
  }

  func testValidate_RestaurantInvalidLatitude_ThrowsError() {
    let invalidRestaurant = BackupRestaurant(
      id: "rest-001",
      name: "Test",
      category: "Test",
      address: "Test",
      city: "Test",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: -100, // Invalid
      lng: 0,
      isFavorite: false)
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [invalidRestaurant],
      visits: [])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .invalidRestaurantData(_, let reason) = backupError {
        XCTAssertTrue(reason.contains("Latitude"))
      } else {
        XCTFail("Expected invalidRestaurantData error")
      }
    }
  }

  func testValidate_VisitInvalidRating_ThrowsError() {
    let restaurant = makeValidRestaurant()
    let invalidVisit = BackupVisit(
      id: UUID(),
      restaurantId: restaurant.id,
      dateVisited: Date(),
      rating: 10, // Invalid
      tags: [],
      note: nil,
      isMatch: false,
      wouldReturn: false)
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [restaurant],
      visits: [invalidVisit])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .invalidVisitData(_, let reason) = backupError {
        XCTAssertTrue(reason.contains("Rating"))
      } else {
        XCTFail("Expected invalidVisitData error")
      }
    }
  }

  func testValidate_OrphanedVisit_StrictMode_ThrowsError() {
    let restaurant = makeValidRestaurant(id: "rest-001")
    let orphanedVisit = makeValidVisit(restaurantId: "non-existent")
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [restaurant],
      visits: [orphanedVisit])

    XCTAssertThrowsError(try sut.validate(backup, strict: true)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .orphanedVisit(_, let restaurantId) = backupError {
        XCTAssertEqual(restaurantId, "non-existent")
      } else {
        XCTFail("Expected orphanedVisit error")
      }
    }
  }

  func testValidate_OrphanedVisit_NonStrictMode_NoThrow() throws {
    let restaurant = makeValidRestaurant(id: "rest-001")
    let orphanedVisit = makeValidVisit(restaurantId: "non-existent")
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: [restaurant],
      visits: [orphanedVisit])

    XCTAssertNoThrow(try sut.validate(backup, strict: false))
  }

  // MARK: - DecodeAndValidate Tests

  func testDecodeAndValidate_ValidData_ReturnsBackup() throws {
    let original = makeValidBackup()
    let data = try sut.encode(original)

    let decoded = try sut.decodeAndValidate(from: data)

    XCTAssertEqual(decoded.schemaVersion, original.schemaVersion)
  }

  func testDecodeAndValidate_InvalidData_ThrowsError() {
    let invalidData = "{}".data(using: .utf8)!

    XCTAssertThrowsError(try sut.decodeAndValidate(from: invalidData))
  }

  // MARK: - Preview Tests

  func testPreview_ValidData_ReturnsPreview() throws {
    let restaurants = [
      makeValidRestaurant(id: "1"),
      makeValidRestaurant(id: "2")
    ]
    let visits = [makeValidVisit(restaurantId: "1")]
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: "1.0.0",
      restaurants: restaurants,
      visits: visits)
    let data = try sut.encode(backup)

    let preview = try sut.preview(from: data)

    XCTAssertEqual(preview.schemaVersion, 1)
    XCTAssertEqual(preview.restaurantCount, 2)
    XCTAssertEqual(preview.visitCount, 1)
  }

  func testPreview_UnsupportedVersion_ThrowsError() throws {
    let json = """
      {
        "schemaVersion": 999,
        "createdAt": "2025-01-01T00:00:00Z",
        "restaurants": [],
        "visits": []
      }
      """
    let data = json.data(using: .utf8)!

    XCTAssertThrowsError(try sut.preview(from: data)) { error in
      guard let backupError = error as? BackupValidationError else {
        XCTFail("Expected BackupValidationError")
        return
      }
      if case .unsupportedSchemaVersion(let version) = backupError {
        XCTAssertEqual(version, 999)
      } else {
        XCTFail("Expected unsupportedSchemaVersion error")
      }
    }
  }

  // MARK: - BackupImportResult Tests

  func testBackupImportResult_Summary_NoChanges() {
    let result = BackupImportResult.empty

    XCTAssertEqual(result.summary, "Nenhuma alteração realizada.")
  }

  func testBackupImportResult_Summary_WithChanges() {
    let result = BackupImportResult(
      importedRestaurants: 5,
      updatedRestaurants: 2,
      importedVisits: 10,
      updatedVisits: 3,
      skippedInvalidEntries: 1)

    XCTAssertTrue(result.summary.contains("5 restaurante(s) importado(s)"))
    XCTAssertTrue(result.summary.contains("2 restaurante(s) atualizado(s)"))
    XCTAssertTrue(result.summary.contains("10 visita(s) importada(s)"))
    XCTAssertTrue(result.summary.contains("1 entrada(s) inválida(s)"))
  }

  func testBackupImportResult_TotalAffected() {
    let result = BackupImportResult(
      importedRestaurants: 5,
      updatedRestaurants: 2,
      importedVisits: 10,
      updatedVisits: 3,
      skippedInvalidEntries: 0)

    XCTAssertEqual(result.totalRestaurantsAffected, 7)
    XCTAssertEqual(result.totalVisitsAffected, 13)
  }

  // MARK: - BackupPreview Tests

  func testBackupPreview_CountsFavorites() {
    let restaurants = [
      BackupRestaurant(
        id: "1", name: "Fav", category: "", address: "", city: "SP", state: "SP",
        tags: [], notes: "", externalLink: nil, lat: 0, lng: 0, isFavorite: true),
      BackupRestaurant(
        id: "2", name: "Not Fav", category: "", address: "", city: "SP", state: "SP",
        tags: [], notes: "", externalLink: nil, lat: 0, lng: 0, isFavorite: false),
      BackupRestaurant(
        id: "3", name: "Also Fav", category: "", address: "", city: "RJ", state: "RJ",
        tags: [], notes: "", externalLink: nil, lat: 0, lng: 0, isFavorite: true)
    ]
    let backup = BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: nil,
      restaurants: restaurants,
      visits: [])

    let preview = BackupPreview(from: backup)

    XCTAssertEqual(preview.favoriteCount, 2)
    XCTAssertEqual(preview.uniqueCities.count, 2)
    XCTAssertTrue(preview.uniqueCities.contains("SP"))
    XCTAssertTrue(preview.uniqueCities.contains("RJ"))
  }

  // MARK: - Constants Tests

  func testDefaultFileName() {
    XCTAssertEqual(BackupCodec.defaultFileName, "chooseThere_backup.json")
  }

  func testSupportedVersions() {
    XCTAssertEqual(BackupCodec.minimumSupportedVersion, 1)
    XCTAssertEqual(BackupCodec.maximumSupportedVersion, 1)
  }
}

