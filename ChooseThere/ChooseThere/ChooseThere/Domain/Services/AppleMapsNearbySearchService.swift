//
//  AppleMapsNearbySearchService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import Foundation
import MapKit

// MARK: - NearbySearching Protocol

/// Protocolo para serviços de busca de lugares próximos
protocol NearbySearching {
  /// Busca lugares próximos
  /// - Parameters:
  ///   - radiusKm: Raio em quilômetros (1-10)
  ///   - category: Categoria/tipo de estabelecimento (opcional)
  ///   - userCoordinate: Coordenada do usuário
  ///   - cityHint: Dica de cidade para melhorar resultados (opcional)
  /// - Returns: Lista de lugares encontrados
  func search(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace]
  
  /// Busca lugares próximos sem usar cache
  func searchWithoutCache(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace]
}

// MARK: - AppleMapsSearchError

/// Erros específicos da busca Apple Maps
enum AppleMapsSearchError: LocalizedError {
  case noResults
  case networkError
  case invalidLocation
  case searchFailed(String)

  var errorDescription: String? {
    switch self {
    case .noResults:
      return "Nenhum resultado encontrado"
    case .networkError:
      return "Erro de conexão. Verifique sua internet."
    case .invalidLocation:
      return "Localização inválida"
    case .searchFailed(let message):
      return "Busca falhou: \(message)"
    }
  }
}

// MARK: - AppleMapsNearbySearchService

/// Serviço de busca de lugares próximos via Apple Maps (MapKit/MKLocalSearch)
/// Implementa cache-first strategy para reduzir chamadas repetidas
struct AppleMapsNearbySearchService: NearbySearching {
  // MARK: - Category Mapping

  /// Mapeia categorias da aplicação para queries do Apple Maps
  private static let categoryQueries: [String: [String]] = [
    // Tipos de culinária
    "japonês": ["japanese restaurant", "sushi", "ramen"],
    "japonesa": ["japanese restaurant", "sushi", "ramen"],
    "italiano": ["italian restaurant", "pizza", "pasta"],
    "italiana": ["italian restaurant", "pizza", "pasta"],
    "brasileiro": ["brazilian restaurant", "churrascaria"],
    "brasileira": ["brazilian restaurant", "churrascaria"],
    "mexicano": ["mexican restaurant", "tacos"],
    "mexicana": ["mexican restaurant", "tacos"],
    "chinês": ["chinese restaurant", "dim sum"],
    "chinesa": ["chinese restaurant", "dim sum"],
    "árabe": ["middle eastern restaurant", "kebab"],
    "pizza": ["pizza", "pizzeria"],
    "hamburger": ["burger", "hamburger"],
    "hamburguer": ["burger", "hamburger"],
    "hambúrguer": ["burger", "hamburger"],
    "sushi": ["sushi", "japanese restaurant"],
    "churrasco": ["steakhouse", "churrascaria", "bbq"],
    "frutos do mar": ["seafood restaurant"],
    "vegetariano": ["vegetarian restaurant", "vegan"],
    "vegano": ["vegan restaurant", "vegetarian"],

    // Tipos de estabelecimento
    "bar": ["bar", "pub"],
    "café": ["cafe", "coffee shop"],
    "cafeteria": ["cafe", "coffee shop"],
    "padaria": ["bakery"],
    "doceria": ["dessert", "bakery", "sweets"],
    "sorveteria": ["ice cream"],
    "fast food": ["fast food"],
    "food truck": ["food truck"],
    "restaurante": ["restaurant"],
    "bistrô": ["bistro", "restaurant"],
    "lanchonete": ["diner", "snack bar"]
  ]

  // MARK: - Search Implementation

  func search(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace] {
    // Valida coordenada
    guard CLLocationCoordinate2DIsValid(userCoordinate) else {
      throw AppleMapsSearchError.invalidLocation
    }

    // Verificar cache primeiro
    let cacheKey = NearbyCacheKey.make(
      category: category,
      radiusKm: radiusKm,
      cityHint: cityHint,
      latitude: userCoordinate.latitude,
      longitude: userCoordinate.longitude
    )

    if let cachedData = NearbyCacheStore.get(for: cacheKey) {
      do {
        let places = try JSONDecoder().decode([NearbyPlace].self, from: cachedData)
        return places
      } catch {
        // Cache corrompido, continuar com busca
        NearbyCacheStore.remove(for: cacheKey)
      }
    }

    // Executar busca no Apple Maps
    let places = try await performSearch(
      radiusKm: radiusKm,
      category: category,
      userCoordinate: userCoordinate,
      cityHint: cityHint
    )

    // Armazenar no cache
    if !places.isEmpty {
      do {
        let data = try JSONEncoder().encode(places)
        NearbyCacheStore.set(data, for: cacheKey)
      } catch {
        // Falha ao cachear não é crítica
        print("⚠️ AppleMapsNearbySearchService: Failed to cache results: \(error)")
      }
    }

    return places
  }

  // MARK: - Private Search Logic

  private func performSearch(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace] {
    // Construir query de busca
    let query = buildSearchQuery(category: category, cityHint: cityHint)

    // Configurar a região de busca
    let radiusMeters = Double(radiusKm) * 1000.0
    let region = MKCoordinateRegion(
      center: userCoordinate,
      latitudinalMeters: radiusMeters * 2,
      longitudinalMeters: radiusMeters * 2
    )

    // Criar request
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = region
    request.resultTypes = .pointOfInterest

    // Executar busca
    let search = MKLocalSearch(request: request)

    do {
      let response = try await search.start()

      // Converter resultados para NearbyPlace
      var places = response.mapItems.compactMap { mapItem -> NearbyPlace? in
        convertToNearbyPlace(mapItem: mapItem)
      }

      // Filtrar por distância real (MapKit pode retornar fora do raio)
      places = filterByDistance(
        places: places,
        userCoordinate: userCoordinate,
        radiusKm: radiusKm
      )

      // Ordenar por distância
      places.sort { place1, place2 in
        place1.distance(from: userCoordinate) < place2.distance(from: userCoordinate)
      }

      if places.isEmpty {
        throw AppleMapsSearchError.noResults
      }

      return places
    } catch let error as AppleMapsSearchError {
      throw error
    } catch let error as MKError {
      throw mapMKError(error)
    } catch {
      throw AppleMapsSearchError.searchFailed(error.localizedDescription)
    }
  }

  // MARK: - Query Building

  private func buildSearchQuery(category: String?, cityHint: String?) -> String {
    var queryParts: [String] = []

    // Adicionar categoria se disponível
    if let category = category?.lowercased().trimmingCharacters(in: .whitespaces), !category.isEmpty {
      if let mappedQueries = Self.categoryQueries[category] {
        // Usar o primeiro termo mapeado
        queryParts.append(mappedQueries[0])
      } else {
        // Usar categoria como está + "restaurant" para melhorar resultados
        queryParts.append("\(category) restaurant")
      }
    } else {
      // Busca genérica por restaurantes
      queryParts.append("restaurant")
    }

    // Adicionar cidade se disponível (melhora resultados em algumas situações)
    if let cityHint = cityHint?.trimmingCharacters(in: .whitespaces), !cityHint.isEmpty {
      queryParts.append(cityHint)
    }

    return queryParts.joined(separator: " ")
  }

  // MARK: - Result Conversion

  private func convertToNearbyPlace(mapItem: MKMapItem) -> NearbyPlace? {
    guard let name = mapItem.name, !name.isEmpty else {
      return nil
    }

    let coordinate = mapItem.placemark.coordinate
    guard CLLocationCoordinate2DIsValid(coordinate) else {
      return nil
    }

    // Construir endereço formatado
    let address = buildFormattedAddress(from: mapItem.placemark)

    // Extrair categoria do MapItem (quando disponível)
    let categoryHint = extractCategoryHint(from: mapItem)

    // Construir URL para abrir no Maps
    let mapsURL = mapItem.url

    return NearbyPlace.create(
      name: name,
      address: address,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      categoryHint: categoryHint,
      externalLink: mapsURL,
      phoneNumber: mapItem.phoneNumber
    )
  }

  private func buildFormattedAddress(from placemark: MKPlacemark) -> String? {
    var components: [String] = []

    if let thoroughfare = placemark.thoroughfare {
      if let subThoroughfare = placemark.subThoroughfare {
        components.append("\(thoroughfare), \(subThoroughfare)")
      } else {
        components.append(thoroughfare)
      }
    }

    if let subLocality = placemark.subLocality {
      components.append(subLocality)
    }

    if let locality = placemark.locality {
      components.append(locality)
    }

    return components.isEmpty ? nil : components.joined(separator: " - ")
  }

  private func extractCategoryHint(from mapItem: MKMapItem) -> String? {
    // MKMapItem.pointOfInterestCategory está disponível a partir do iOS 13
    if let category = mapItem.pointOfInterestCategory {
      return mapPOICategoryToDisplayName(category)
    }
    return nil
  }

  private func mapPOICategoryToDisplayName(_ category: MKPointOfInterestCategory) -> String {
    switch category {
    case .restaurant:
      return "Restaurante"
    case .cafe:
      return "Café"
    case .bakery:
      return "Padaria"
    case .brewery:
      return "Cervejaria"
    case .winery:
      return "Vinícola"
    case .nightlife:
      return "Vida Noturna"
    case .foodMarket:
      return "Mercado"
    default:
      return "Estabelecimento"
    }
  }

  // MARK: - Distance Filtering

  private func filterByDistance(
    places: [NearbyPlace],
    userCoordinate: CLLocationCoordinate2D,
    radiusKm: Int
  ) -> [NearbyPlace] {
    let radiusMeters = Double(radiusKm) * 1000.0

    return places.filter { place in
      place.distance(from: userCoordinate) <= radiusMeters
    }
  }

  // MARK: - Error Mapping

  private func mapMKError(_ error: MKError) -> AppleMapsSearchError {
    switch error.code {
    case .serverFailure, .loadingThrottled:
      return .networkError
    case .placemarkNotFound:
      return .noResults
    default:
      return .searchFailed(error.localizedDescription)
    }
  }
}

// MARK: - Search Without Cache

extension AppleMapsNearbySearchService {
  /// Executa busca ignorando o cache (força refresh)
  func searchWithoutCache(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace] {
    // Invalida cache para esta chave
    let cacheKey = NearbyCacheKey.make(
      category: category,
      radiusKm: radiusKm,
      cityHint: cityHint,
      latitude: userCoordinate.latitude,
      longitude: userCoordinate.longitude
    )
    NearbyCacheStore.remove(for: cacheKey)

    // Executa busca normalmente (que irá cachear o resultado)
    return try await search(
      radiusKm: radiusKm,
      category: category,
      userCoordinate: userCoordinate,
      cityHint: cityHint
    )
  }
}

