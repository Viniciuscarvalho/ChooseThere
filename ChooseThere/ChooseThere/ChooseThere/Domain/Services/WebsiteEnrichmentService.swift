//
//  WebsiteEnrichmentService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/31/25.
//

import Foundation
import MapKit
import OSLog

/// Serviço para enriquecer automaticamente o site oficial dos restaurantes via MapKit.
/// Usa MKLocalSearch para encontrar o estabelecimento e extrair a URL do site.
actor WebsiteEnrichmentService {
  // MARK: - Dependencies
  
  private let logger = Logger(subsystem: "ChooseThere", category: "WebsiteEnrichment")
  
  // MARK: - Cache
  
  /// Cache de sites encontrados (nome+cidade -> URL)
  private var cache: [String: URL] = [:]
  
  /// Cache de falhas para evitar buscas repetidas
  private var failedCache: Set<String> = []
  
  // MARK: - Singleton
  
  static let shared = WebsiteEnrichmentService()
  
  // MARK: - Public API
  
  /// Resultado do enriquecimento de website
  struct EnrichmentResult: Sendable {
    let websiteURL: URL?
    let phoneNumber: String?
    let normalizedName: String?
    let source: Source
    
    enum Source: Sendable {
      case cache
      case mapKit
      case notFound
    }
  }
  
  /// Busca o site oficial de um restaurante via MapKit
  /// - Parameters:
  ///   - name: Nome do restaurante
  ///   - address: Endereço (opcional)
  ///   - city: Cidade
  ///   - state: Estado
  ///   - lat: Latitude atual (para melhorar resultados)
  ///   - lng: Longitude atual
  /// - Returns: Resultado com URL do site e metadados
  func enrichWebsite(
    name: String,
    address: String?,
    city: String,
    state: String,
    lat: Double?,
    lng: Double?
  ) async -> EnrichmentResult {
    let cacheKey = "\(name.lowercased())|\(city.lowercased())"
    
    // Verificar cache de sucesso
    if let cached = cache[cacheKey] {
      logger.debug("✅ Cache hit: \(name)")
      return EnrichmentResult(
        websiteURL: cached,
        phoneNumber: nil,
        normalizedName: nil,
        source: .cache
      )
    }
    
    // Verificar cache de falhas
    if failedCache.contains(cacheKey) {
      logger.debug("⏭️ Skip (failed before): \(name)")
      return EnrichmentResult(
        websiteURL: nil,
        phoneNumber: nil,
        normalizedName: nil,
        source: .notFound
      )
    }
    
    // Buscar via MapKit
    do {
      let result = try await searchMapKit(
        name: name,
        address: address,
        city: city,
        state: state,
        lat: lat,
        lng: lng
      )
      
      if let url = result.websiteURL {
        cache[cacheKey] = url
        logger.info("🌐 Found website for \(name): \(url.host ?? "")")
      } else {
        failedCache.insert(cacheKey)
        logger.info("❌ No website for: \(name)")
      }
      
      return result
      
    } catch {
      failedCache.insert(cacheKey)
      logger.warning("⚠️ Error for \(name): \(error.localizedDescription)")
      return EnrichmentResult(
        websiteURL: nil,
        phoneNumber: nil,
        normalizedName: nil,
        source: .notFound
      )
    }
  }
  
  /// Enriquece um restaurante existente
  func enrichRestaurant(_ restaurant: Restaurant) async -> EnrichmentResult {
    // Se já tem site, não precisa buscar
    if restaurant.externalLink != nil {
      return EnrichmentResult(
        websiteURL: restaurant.externalLink,
        phoneNumber: nil,
        normalizedName: nil,
        source: .cache
      )
    }
    
    return await enrichWebsite(
      name: restaurant.name,
      address: restaurant.address.isEmpty ? nil : restaurant.address,
      city: restaurant.city,
      state: restaurant.state,
      lat: restaurant.lat,
      lng: restaurant.lng
    )
  }
  
  /// Limpa o cache
  func clearCache() {
    cache.removeAll()
    failedCache.removeAll()
    logger.info("Cache cleared")
  }
  
  // MARK: - Private Methods
  
  private func searchMapKit(
    name: String,
    address: String?,
    city: String,
    state: String,
    lat: Double?,
    lng: Double?
  ) async throws -> EnrichmentResult {
    // Construir queries em ordem de especificidade
    var queries: [String] = []
    
    // 1. Nome + endereço + cidade
    if let address = address, !address.isEmpty {
      queries.append("\(name), \(address), \(city), \(state)")
    }
    
    // 2. Nome + cidade
    queries.append("\(name), \(city), \(state)")
    
    // 3. Apenas nome + cidade
    queries.append("\(name) \(city)")
    
    for query in queries {
      if let result = try await performSearch(
        query: query,
        originalName: name,
        lat: lat,
        lng: lng
      ) {
        return result
      }
    }
    
    return EnrichmentResult(
      websiteURL: nil,
      phoneNumber: nil,
      normalizedName: nil,
      source: .notFound
    )
  }
  
  private func performSearch(
    query: String,
    originalName: String,
    lat: Double?,
    lng: Double?
  ) async throws -> EnrichmentResult? {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.resultTypes = .pointOfInterest
    
    // Se temos coordenadas, definir região para melhorar resultados
    if let lat = lat, let lng = lng {
      let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      let region = MKCoordinateRegion(
        center: center,
        latitudinalMeters: 5000,
        longitudinalMeters: 5000
      )
      request.region = region
    }
    
    let search = MKLocalSearch(request: request)
    let response = try await search.start()
    
    // Encontrar o melhor match
    for item in response.mapItems {
      guard let itemName = item.name else { continue }
      
      // Verificar similaridade de nome (case-insensitive)
      let similarity = calculateSimilarity(originalName, itemName)
      if similarity >= 0.5 {
        // Priorizar resultados com URL
        if let url = item.url {
          return EnrichmentResult(
            websiteURL: url,
            phoneNumber: item.phoneNumber,
            normalizedName: itemName,
            source: .mapKit
          )
        }
      }
    }
    
    // Fallback: primeiro resultado com URL
    for item in response.mapItems {
      if let url = item.url {
        return EnrichmentResult(
          websiteURL: url,
          phoneNumber: item.phoneNumber,
          normalizedName: item.name,
          source: .mapKit
        )
      }
    }
    
    return nil
  }
  
  /// Calcula similaridade entre strings (Jaccard simplificado)
  private func calculateSimilarity(_ s1: String, _ s2: String) -> Double {
    let words1 = Set(s1.lowercased().split(separator: " ").map { String($0) })
    let words2 = Set(s2.lowercased().split(separator: " ").map { String($0) })
    
    let intersection = words1.intersection(words2).count
    let union = words1.union(words2).count
    
    guard union > 0 else { return 0 }
    return Double(intersection) / Double(union)
  }
}

// MARK: - Batch Enrichment

extension WebsiteEnrichmentService {
  /// Resultado do enriquecimento em lote
  struct BatchResult: Sendable {
    let enriched: Int
    let alreadyHadSite: Int
    let notFound: Int
    let total: Int
  }
  
  /// Resultado de enriquecimento individual para callback
  struct EnrichmentItem: Sendable {
    let restaurantId: String
    let websiteURL: URL
  }
  
  /// Enriquece múltiplos restaurantes em lote
  /// - Parameters:
  ///   - restaurants: Lista de restaurantes para enriquecer
  ///   - onEnriched: Callback chamado para cada restaurante enriquecido (para salvar)
  ///   - onProgress: Callback de progresso
  /// - Returns: Resultado do lote
  func enrichBatch(
    restaurants: [Restaurant],
    onEnriched: @escaping @Sendable (EnrichmentItem) async -> Bool,
    onProgress: ((Int, Int) -> Void)? = nil
  ) async -> BatchResult {
    var enriched = 0
    var alreadyHadSite = 0
    var notFound = 0
    
    for (index, restaurant) in restaurants.enumerated() {
      // Reportar progresso
      onProgress?(index + 1, restaurants.count)
      
      // Se já tem site, pular
      if restaurant.externalLink != nil {
        alreadyHadSite += 1
        continue
      }
      
      // Buscar site
      let result = await enrichRestaurant(restaurant)
      
      if let websiteURL = result.websiteURL {
        // Chamar callback para salvar
        let item = EnrichmentItem(restaurantId: restaurant.id, websiteURL: websiteURL)
        let saved = await onEnriched(item)
        if saved {
          enriched += 1
        } else {
          notFound += 1
        }
      } else {
        notFound += 1
      }
      
      // Throttle para não sobrecarregar o MapKit
      if index < restaurants.count - 1 {
        try? await Task.sleep(for: .milliseconds(300))
      }
    }
    
    return BatchResult(
      enriched: enriched,
      alreadyHadSite: alreadyHadSite,
      notFound: notFound,
      total: restaurants.count
    )
  }
}

