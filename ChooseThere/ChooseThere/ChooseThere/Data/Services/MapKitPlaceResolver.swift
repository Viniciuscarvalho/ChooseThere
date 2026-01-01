//
//  MapKitPlaceResolver.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import Foundation
import MapKit
import CoreLocation
import OSLog

/// Implementação do PlaceResolver usando Apple MapKit (MKLocalSearch)
final class MapKitPlaceResolver: PlaceResolver, @unchecked Sendable {
  private let logger = Logger(subsystem: "ChooseThere", category: "PlaceResolver")
  
  /// Distância máxima aceitável (em km) entre coordenada atual e encontrada
  private let maxAcceptableDistanceKm: Double = 5.0
  
  /// Nível de confiança mínimo para aceitar um resultado
  private let minConfidenceThreshold: Double = 0.5
  
  func resolve(
    name: String,
    address: String,
    city: String,
    state: String,
    currentLat: Double?,
    currentLng: Double?
  ) async throws -> PlaceResolverResult? {
    // Tentar várias estratégias de query em ordem de especificidade
    let queries = buildQueryStrategies(name: name, address: address, city: city, state: state)
    
    for query in queries {
      if let result = try await searchWithQuery(
        query,
        originalName: name,
        currentLat: currentLat,
        currentLng: currentLng
      ) {
        return result
      }
    }
    
    logger.info("Place not resolved for: \(name)")
    return nil
  }
  
  // MARK: - Query Strategies
  
  /// Constrói diferentes estratégias de query do mais específico ao mais genérico
  private func buildQueryStrategies(name: String, address: String, city: String, state: String) -> [String] {
    var strategies: [String] = []
    
    // 1. Nome completo + endereço completo + cidade/estado
    if !address.isEmpty {
      strategies.append("\(name), \(address), \(city), \(state)")
    }
    
    // 2. Nome + cidade/estado (sem endereço)
    strategies.append("\(name), \(city), \(state)")
    
    // 3. Apenas nome + cidade (menos específico)
    strategies.append("\(name), \(city)")
    
    // 4. Endereço + cidade (para casos onde o nome pode diferir)
    if !address.isEmpty {
      strategies.append("\(address), \(city), \(state)")
    }
    
    return strategies
  }
  
  // MARK: - Search
  
  private func searchWithQuery(
    _ query: String,
    originalName: String,
    currentLat: Double?,
    currentLng: Double?
  ) async throws -> PlaceResolverResult? {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    
    // Se temos coordenadas atuais, definir região para melhorar resultados
    if let lat = currentLat, let lng = currentLng {
      let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      let region = MKCoordinateRegion(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
      request.region = region
    }
    
    // Filtrar apenas por POIs (Points of Interest)
    request.resultTypes = .pointOfInterest
    
    let search = MKLocalSearch(request: request)
    
    do {
      let response = try await search.start()
      
      guard !response.mapItems.isEmpty else {
        return nil
      }
      
      // Avaliar cada resultado e escolher o melhor
      let scored = response.mapItems.compactMap { item -> (MKMapItem, Double)? in
        let score = calculateConfidence(
          item: item,
          originalName: originalName,
          currentLat: currentLat,
          currentLng: currentLng
        )
        return score >= minConfidenceThreshold ? (item, score) : nil
      }
      
      // Ordenar por score e pegar o melhor
      guard let best = scored.sorted(by: { $0.1 > $1.1 }).first else {
        return nil
      }
      
      let item = best.0
      let confidence = best.1
      
      logger.info("Resolved '\(originalName)' to '\(item.name ?? "")' with confidence \(confidence)")
      
      return PlaceResolverResult(
        latitude: item.placemark.coordinate.latitude,
        longitude: item.placemark.coordinate.longitude,
        normalizedName: item.name,
        normalizedAddress: formatAddress(from: item.placemark),
        confidence: confidence
      )
      
    } catch {
      logger.error("Search failed for query '\(query)': \(error.localizedDescription)")
      throw PlaceResolverError.searchFailed(underlying: error)
    }
  }
  
  // MARK: - Heuristics
  
  /// Calcula um score de confiança (0.0 a 1.0) para um resultado
  private func calculateConfidence(
    item: MKMapItem,
    originalName: String,
    currentLat: Double?,
    currentLng: Double?
  ) -> Double {
    var score = 0.0
    
    // Heurística 1: Similaridade de nome (40% do score)
    if let itemName = item.name {
      let nameSimilarity = calculateStringSimilarity(originalName.lowercased(), itemName.lowercased())
      score += nameSimilarity * 0.4
    }
    
    // Heurística 2: Distância da coordenada atual (30% do score)
    if let lat = currentLat, let lng = currentLng {
      let currentLocation = CLLocation(latitude: lat, longitude: lng)
      let itemLocation = CLLocation(
        latitude: item.placemark.coordinate.latitude,
        longitude: item.placemark.coordinate.longitude
      )
      let distanceKm = currentLocation.distance(from: itemLocation) / 1000.0
      
      if distanceKm <= maxAcceptableDistanceKm {
        // Quanto mais perto, maior o score
        let distanceScore = max(0, 1.0 - (distanceKm / maxAcceptableDistanceKm))
        score += distanceScore * 0.3
      }
    } else {
      // Se não temos coordenadas atuais, dar pontuação média
      score += 0.15
    }
    
    // Heurística 3: Tem telefone/URL (indica lugar real) (15% do score)
    if item.phoneNumber != nil || item.url != nil {
      score += 0.15
    }
    
    // Heurística 4: É um POI válido com categoria de comida (15% do score)
    if let category = item.pointOfInterestCategory {
      let foodCategories: Set<MKPointOfInterestCategory> = [
        .restaurant, .cafe, .bakery, .brewery, .foodMarket, .nightlife, .winery
      ]
      if foodCategories.contains(category) {
        score += 0.15
      }
    }
    
    return min(1.0, score)
  }
  
  /// Calcula similaridade entre duas strings (Jaccard simplificado)
  private func calculateStringSimilarity(_ s1: String, _ s2: String) -> Double {
    let words1 = Set(s1.split(separator: " ").map { String($0) })
    let words2 = Set(s2.split(separator: " ").map { String($0) })
    
    let intersection = words1.intersection(words2).count
    let union = words1.union(words2).count
    
    guard union > 0 else { return 0 }
    return Double(intersection) / Double(union)
  }
  
  /// Formata endereço a partir do placemark
  private func formatAddress(from placemark: MKPlacemark) -> String {
    var components: [String] = []
    
    if let thoroughfare = placemark.thoroughfare {
      if let subThoroughfare = placemark.subThoroughfare {
        components.append("\(thoroughfare), \(subThoroughfare)")
      } else {
        components.append(thoroughfare)
      }
    }
    
    if let locality = placemark.locality {
      components.append(locality)
    }
    
    if let administrativeArea = placemark.administrativeArea {
      components.append(administrativeArea)
    }
    
    return components.joined(separator: ", ")
  }
}





