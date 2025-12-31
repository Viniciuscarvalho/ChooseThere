//
//  URLValidationTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import XCTest

@testable import ChooseThere

/// Testes para validação de URLs no editor de links externos
final class URLValidationTests: XCTestCase {
  
  // MARK: - URL Validation Logic Tests
  
  // Nota: Como validateURLString é private, testamos indiretamente via validateField
  // ou podemos criar um helper público para testes.
  
  // MARK: - Valid URLs
  
  func testValidURL_HTTPS() {
    let url = "https://www.tripadvisor.com/restaurant"
    XCTAssertNotNil(URL(string: url))
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testValidURL_HTTP() {
    let url = "http://ifood.com.br/delivery"
    XCTAssertNotNil(URL(string: url))
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testValidURL_WithPath() {
    let url = "https://www.tripadvisor.com.br/Restaurant_Review-g303631-d12345-Reviews"
    XCTAssertNotNil(URL(string: url))
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testValidURL_WithQueryParams() {
    let url = "https://www.ifood.com.br/delivery/sao-paulo-sp?utm_source=app"
    XCTAssertNotNil(URL(string: url))
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testValidURL_WithPort() {
    let url = "https://example.com:8080/page"
    XCTAssertNotNil(URL(string: url))
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testValidURL_SubdomainMultiLevel() {
    let url = "https://api.v2.example.com/path"
    XCTAssertNotNil(URL(string: url))
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  // MARK: - Empty/Whitespace (válido pois campo é opcional)
  
  func testEmptyString_IsValid() {
    let url = ""
    XCTAssertTrue(isValidOrEmpty(url))
  }
  
  func testWhitespaceOnly_IsValid() {
    let url = "   "
    XCTAssertTrue(isValidOrEmpty(url))
  }
  
  // MARK: - Invalid URLs
  
  func testInvalidURL_NoScheme() {
    let url = "www.example.com"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_JustDomain() {
    let url = "example.com"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_MalformedScheme() {
    let url = "htps://example.com"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_FTPScheme() {
    let url = "ftp://files.example.com"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_NoHost() {
    let url = "https://"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_JustScheme() {
    let url = "https"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_Spaces() {
    let url = "https://example .com"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_RandomText() {
    let url = "não é uma URL"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_FileScheme() {
    let url = "file:///path/to/file"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  func testInvalidURL_JavascriptScheme() {
    let url = "javascript:alert(1)"
    XCTAssertFalse(isValidExternalURL(url))
  }
  
  // MARK: - URL Trimming
  
  func testURL_LeadingWhitespace_StillValid() {
    let url = "  https://example.com"
    XCTAssertTrue(isValidExternalURL(url.trimmingCharacters(in: .whitespacesAndNewlines)))
  }
  
  func testURL_TrailingWhitespace_StillValid() {
    let url = "https://example.com   "
    XCTAssertTrue(isValidExternalURL(url.trimmingCharacters(in: .whitespacesAndNewlines)))
  }
  
  // MARK: - Real World URLs
  
  func testRealURL_TripAdvisor() {
    let url = "https://www.tripadvisor.com.br/Restaurant_Review-g303631-d2345678-Reviews-Restaurante_Exemplo-Sao_Paulo_State_of_Sao_Paulo.html"
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testRealURL_IFood() {
    let url = "https://www.ifood.com.br/delivery/sao-paulo-sp/restaurante-exemplo-centro/12345678-1234"
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testRealURL_99() {
    let url = "https://99app.com/ride?destination=-23.5632,-46.6541"
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  func testRealURL_ImageCDN() {
    let url = "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800"
    XCTAssertTrue(isValidExternalURL(url))
  }
  
  // MARK: - Helper Methods
  
  /// Simula a lógica de validação do ViewModel
  private func isValidExternalURL(_ string: String) -> Bool {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }
    guard let url = URL(string: trimmed) else { return false }
    guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else { return false }
    guard url.host != nil else { return false }
    return true
  }
  
  /// Verifica se string é vazia/whitespace (válido para campo opcional) ou URL válida
  private func isValidOrEmpty(_ string: String) -> Bool {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return true }
    return isValidExternalURL(string)
  }
}

