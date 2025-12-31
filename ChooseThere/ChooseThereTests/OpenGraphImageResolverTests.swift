//
//  OpenGraphImageResolverTests.swift
//  ChooseThereTests
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import XCTest

@testable import ChooseThere

final class OpenGraphImageResolverTests: XCTestCase {
  
  var resolver: OpenGraphImageResolver!
  
  override func setUp() async throws {
    resolver = OpenGraphImageResolver()
  }
  
  override func tearDown() async throws {
    await resolver.clearCache()
  }
  
  // MARK: - Parser Tests
  
  func testParseOGImage_PropertyAttribute_AbsoluteURL() async {
    let html = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta property="og:image" content="https://example.com/image.jpg">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://example.com/image.jpg")
  }
  
  func testParseOGImage_ContentBeforeProperty() async {
    let html = """
    <html>
    <head>
      <meta content="https://example.com/photo.png" property="og:image">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://example.com/photo.png")
  }
  
  func testParseOGImage_NameAttribute() async {
    let html = """
    <html>
    <head>
      <meta name="og:image" content="https://cdn.site.com/thumb.jpg">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://site.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://cdn.site.com/thumb.jpg")
  }
  
  func testParseOGImage_RelativeURL() async {
    let html = """
    <html>
    <head>
      <meta property="og:image" content="/images/og-image.jpg">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://restaurant.com/about")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://restaurant.com/images/og-image.jpg")
  }
  
  func testParseOGImage_RelativeURLWithoutSlash() async {
    let html = """
    <html>
    <head>
      <meta property="og:image" content="assets/image.png">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://restaurant.com/menu/")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertNotNil(result)
    XCTAssertTrue(result!.absoluteString.contains("restaurant.com"))
  }
  
  func testParseOGImage_NoOGImage() async {
    let html = """
    <html>
    <head>
      <meta property="og:title" content="Restaurant Name">
      <meta property="og:description" content="Best food in town">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertNil(result)
  }
  
  func testParseOGImage_SingleQuotes() async {
    let html = """
    <html>
    <head>
      <meta property='og:image' content='https://example.com/single.jpg'>
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://example.com/single.jpg")
  }
  
  func testParseOGImage_ExtraAttributes() async {
    let html = """
    <html>
    <head>
      <meta property="og:image" content="https://example.com/img.jpg" data-test="true" class="meta">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://example.com/img.jpg")
  }
  
  func testParseOGImage_MultipleOGTags() async {
    let html = """
    <html>
    <head>
      <meta property="og:title" content="Title">
      <meta property="og:image" content="https://example.com/first.jpg">
      <meta property="og:image" content="https://example.com/second.jpg">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    // Deve retornar o primeiro encontrado
    XCTAssertEqual(result?.absoluteString, "https://example.com/first.jpg")
  }
  
  func testParseOGImage_RealWorldHTML() async {
    // HTML típico de um restaurante real
    let html = """
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
      <meta charset="UTF-8">
      <title>Izakaya Matsu - Restaurante Japonês</title>
      <meta name="description" content="O melhor restaurante japonês de São Paulo">
      <meta property="og:title" content="Izakaya Matsu">
      <meta property="og:type" content="restaurant">
      <meta property="og:image" content="https://izakayamatsu.com.br/og-image.jpg">
      <meta property="og:url" content="https://izakayamatsu.com.br">
      <link rel="stylesheet" href="/css/style.css">
    </head>
    <body>
      <h1>Bem-vindo ao Izakaya Matsu</h1>
    </body>
    </html>
    """
    let baseURL = URL(string: "https://izakayamatsu.com.br")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://izakayamatsu.com.br/og-image.jpg")
  }
  
  func testParseOGImage_EmptyContent() async {
    let html = """
    <html>
    <head>
      <meta property="og:image" content="">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertNil(result)
  }
  
  func testParseOGImage_WhitespaceInContent() async {
    let html = """
    <html>
    <head>
      <meta property="og:image" content="  https://example.com/spaced.jpg  ">
    </head>
    </html>
    """
    let baseURL = URL(string: "https://example.com")!
    
    let result = await resolver.parseOGImage(from: html, baseURL: baseURL)
    
    XCTAssertEqual(result?.absoluteString, "https://example.com/spaced.jpg")
  }
  
  // MARK: - Restaurant Integration Tests
  
  func testResolveForRestaurant_PreferManualImageURL() async {
    let restaurant = Restaurant(
      id: "test",
      name: "Test",
      category: "restaurant",
      address: "",
      city: "SP",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: URL(string: "https://restaurant.com"),
      lat: 0,
      lng: 0,
      imageURL: URL(string: "https://manual.com/image.jpg")
    )
    
    let result = await resolver.resolveForRestaurant(restaurant)
    
    // Deve usar a imageURL manual, não tentar resolver OG
    XCTAssertEqual(result?.absoluteString, "https://manual.com/image.jpg")
  }
  
  func testResolveForRestaurant_NoImageOrExternalLink() async {
    let restaurant = Restaurant(
      id: "test",
      name: "Test",
      category: "restaurant",
      address: "",
      city: "SP",
      state: "SP",
      tags: [],
      notes: "",
      externalLink: nil,
      lat: 0,
      lng: 0,
      imageURL: nil
    )
    
    let result = await resolver.resolveForRestaurant(restaurant)
    
    XCTAssertNil(result)
  }
}

