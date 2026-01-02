//
//  NearbyRouletteService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/31/25.
//

import CoreLocation
import Foundation

// MARK: - NearbyRouletteError

/// Erros específicos do sorteio "Perto de mim"
enum NearbyRouletteError: LocalizedError {
  case noPermission
  case locationUnavailable
  case noResults
  case allFiltered
  case searchFailed(String)
  
  var errorDescription: String? {
    switch self {
    case .noPermission:
      return "Permissão de localização negada"
    case .locationUnavailable:
      return "Não foi possível obter sua localização"
    case .noResults:
      return "Nenhum restaurante encontrado nessa área"
    case .allFiltered:
      return "Nenhum resultado atende aos filtros selecionados"
    case .searchFailed(let message):
      return "Busca falhou: \(message)"
    }
  }
}

// MARK: - NearbyRouletteResult

/// Resultado do sorteio "Perto de mim"
struct NearbyRouletteResult {
  /// Restaurante sorteado (pode ser da base local ou candidato transitório)
  let restaurant: Restaurant
  
  /// Indica se veio da base local (true) ou é transitório do Apple Maps (false)
  let isFromLocalBase: Bool
  
  /// Distância em metros do usuário
  let distanceMeters: Double
}

// MARK: - NearbyRouletteServicing

/// Protocolo para o serviço de sorteio "Perto de mim"
protocol NearbyRouletteServicing {
  /// Sorteia um restaurante próximo com base nos filtros
  /// - Parameters:
  ///   - context: Contexto de preferências (tags, raio, rating priority)
  ///   - userCoordinate: Coordenada do usuário
  ///   - sessionExcludes: IDs já sorteados nesta sessão (para anti-repetição local)
  /// - Returns: Resultado com o restaurante sorteado
  func draw(
    context: PreferenceContext,
    userCoordinate: CLLocationCoordinate2D,
    sessionExcludes: Set<String>
  ) async throws -> NearbyRouletteResult
}

// MARK: - NearbyRouletteService

/// Serviço que orquestra o sorteio "Perto de mim":
/// 1. Busca Apple Maps (até 10km)
/// 2. Tenta match com base local para enriquecer tags/rating
/// 3. Aplica filtros via RestaurantRandomizer
/// 4. Sorteia usando SmartRouletteService (anti-repetição + preferências aprendidas)
final class NearbyRouletteService: NearbyRouletteServicing {
  // MARK: - Dependencies
  
  private let appleMapsService: any NearbySearching
  private let restaurantRepository: any RestaurantRepository
  private let randomizer: any RestaurantRandomizerProtocol
  private let smartRoulette: SmartRouletteProtocol?
  
  // MARK: - Initialization
  
  init(
    appleMapsService: any NearbySearching = AppleMapsNearbySearchService(),
    restaurantRepository: any RestaurantRepository,
    randomizer: any RestaurantRandomizerProtocol = RestaurantRandomizer(),
    smartRoulette: SmartRouletteProtocol? = nil
  ) {
    self.appleMapsService = appleMapsService
    self.restaurantRepository = restaurantRepository
    self.randomizer = randomizer
    self.smartRoulette = smartRoulette
  }
  
  // MARK: - NearbyRouletteServicing
  
  func draw(
    context: PreferenceContext,
    userCoordinate: CLLocationCoordinate2D,
    sessionExcludes: Set<String>
  ) async throws -> NearbyRouletteResult {
    // 1. Determinar raio (máximo 10km)
    let radiusKm = min(context.radiusKm ?? 10, 10)
    
    // 2. Extrair categoria das tags desejadas (primeira tag, se houver)
    let category = context.desiredTags.first
    
    // 3. Buscar no Apple Maps
    let cityHint: String?
    if let parsed = AppSettingsStorage.parseSelectedCity() {
      cityHint = parsed.city
    } else {
      cityHint = nil
    }
    
    let places: [NearbyPlace]
    do {
      places = try await appleMapsService.search(
        radiusKm: radiusKm,
        category: category,
        userCoordinate: userCoordinate,
        cityHint: cityHint
      )
    } catch let error as AppleMapsSearchError {
      switch error {
      case .noResults:
        throw NearbyRouletteError.noResults
      default:
        throw NearbyRouletteError.searchFailed(error.localizedDescription)
      }
    }
    
    guard !places.isEmpty else {
      throw NearbyRouletteError.noResults
    }
    
    // 4. Carregar base local para matching
    let localRestaurants: [Restaurant]
    do {
      localRestaurants = try restaurantRepository.fetchAll()
    } catch {
      localRestaurants = []
    }
    
    // 5. Converter NearbyPlace → Restaurant (candidatos)
    let candidates = places.map { place in
      convertToCandidate(
        place: place,
        localRestaurants: localRestaurants,
        userCoordinate: userCoordinate
      )
    }
    
    // 6. Sortear usando randomizer com fallback de rating
    var enrichedContext = context
    enrichedContext.userLocation = userCoordinate
    enrichedContext.radiusKm = radiusKm
    
    let picked: Restaurant?
    if let smart = smartRoulette {
      // Usar SmartRouletteService (anti-repetição + preferências aprendidas)
      picked = smart.pick(from: candidates.map(\.restaurant), context: enrichedContext, sessionExcludes: sessionExcludes)
    } else {
      // Usar randomizer com fallback de rating
      picked = randomizer.pickWithRatingFallback(
        from: candidates.map(\.restaurant),
        context: enrichedContext,
        excludeRestaurantIDs: sessionExcludes
      )
    }
    
    guard let result = picked else {
      throw NearbyRouletteError.allFiltered
    }
    
    // 7. Encontrar o candidato correspondente para obter distância
    let candidateInfo = candidates.first { $0.restaurant.id == result.id }
    
    return NearbyRouletteResult(
      restaurant: result,
      isFromLocalBase: candidateInfo?.isFromLocalBase ?? false,
      distanceMeters: candidateInfo?.distanceMeters ?? 0
    )
  }
  
  // MARK: - Private Helpers
  
  private struct CandidateInfo {
    let restaurant: Restaurant
    let isFromLocalBase: Bool
    let distanceMeters: Double
  }
  
  /// Converte um NearbyPlace em Restaurant (candidato para sorteio)
  /// Tenta match com base local para enriquecer com tags/rating interno
  private func convertToCandidate(
    place: NearbyPlace,
    localRestaurants: [Restaurant],
    userCoordinate: CLLocationCoordinate2D
  ) -> CandidateInfo {
    let distanceMeters = place.distance(from: userCoordinate)
    
    // Tentar match com base local
    if let matched = findMatch(for: place, in: localRestaurants) {
      return CandidateInfo(
        restaurant: matched,
        isFromLocalBase: true,
        distanceMeters: distanceMeters
      )
    }
    
    // Criar candidato transitório
    let transitoryRestaurant = createTransitoryRestaurant(from: place)
    return CandidateInfo(
      restaurant: transitoryRestaurant,
      isFromLocalBase: false,
      distanceMeters: distanceMeters
    )
  }
  
  /// Tenta encontrar um restaurante na base local que corresponda ao NearbyPlace
  private func findMatch(for place: NearbyPlace, in localRestaurants: [Restaurant]) -> Restaurant? {
    let placeName = normalize(place.name)
    
    for restaurant in localRestaurants {
      let restaurantName = normalize(restaurant.name)
      
      // Match por nome similar (80% de similaridade ou conteúdo)
      if placeName.contains(restaurantName) || restaurantName.contains(placeName) {
        // Verificar proximidade geográfica (< 200m)
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let restaurantLocation = CLLocation(latitude: restaurant.lat, longitude: restaurant.lng)
        let distance = placeLocation.distance(from: restaurantLocation)
        
        if distance < 200 {
          return restaurant
        }
      }
    }
    
    return nil
  }
  
  /// Cria um Restaurant transitório a partir de um NearbyPlace
  private func createTransitoryRestaurant(from place: NearbyPlace) -> Restaurant {
    // Derivar tags da categoria do Apple Maps
    var tags: [String] = []
    if let categoryHint = place.categoryHint, !categoryHint.isEmpty {
      tags.append(categoryHint.lowercased())
    }
    
    // Extrair cidade do endereço (heurística simples)
    let city = extractCity(from: place.address) ?? ""
    
    return Restaurant(
      id: place.id,
      name: place.name,
      category: place.categoryHint ?? "Restaurante",
      address: place.address ?? "",
      city: city,
      state: "",
      tags: tags,
      notes: "",
      externalLink: place.externalLink,
      lat: place.latitude,
      lng: place.longitude,
      isFavorite: false,
      ratingAverage: 0,
      ratingCount: 0
    )
  }
  
  /// Normaliza string para comparação (lowercase, remove acentos)
  private func normalize(_ string: String) -> String {
    string
      .lowercased()
      .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  /// Extrai cidade do endereço (heurística simples)
  private func extractCity(from address: String?) -> String? {
    guard let address = address else { return nil }
    
    // Tenta extrair o penúltimo componente separado por vírgula (geralmente é a cidade)
    let components = address.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    if components.count >= 2 {
      return components[components.count - 2]
    }
    
    return nil
  }
}

