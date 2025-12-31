//
//  NearbyModeViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import Foundation
import Observation

// MARK: - NearbySearchState

/// Estado da busca "Perto de mim"
enum NearbySearchState: Equatable {
  case idle
  case loading
  case noPermission
  case noResults
  case error(String)
  case localResults([Restaurant])
  case appleMapsResults([NearbyPlace])

  var isLoading: Bool {
    if case .loading = self { return true }
    return false
  }

  var restaurants: [Restaurant] {
    if case .localResults(let restaurants) = self {
      return restaurants
    }
    return []
  }

  var places: [NearbyPlace] {
    if case .appleMapsResults(let places) = self {
      return places
    }
    return []
  }

  var hasResults: Bool {
    switch self {
    case .localResults(let restaurants):
      return !restaurants.isEmpty
    case .appleMapsResults(let places):
      return !places.isEmpty
    default:
      return false
    }
  }

  var resultCount: Int {
    switch self {
    case .localResults(let restaurants):
      return restaurants.count
    case .appleMapsResults(let places):
      return places.count
    default:
      return 0
    }
  }

  static func == (lhs: NearbySearchState, rhs: NearbySearchState) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle), (.loading, .loading), (.noPermission, .noPermission), (.noResults, .noResults):
      return true
    case (.error(let lhsMsg), .error(let rhsMsg)):
      return lhsMsg == rhsMsg
    case (.localResults(let lhsRestaurants), .localResults(let rhsRestaurants)):
      return lhsRestaurants.map(\.id) == rhsRestaurants.map(\.id)
    case (.appleMapsResults(let lhsPlaces), .appleMapsResults(let rhsPlaces)):
      return lhsPlaces.map(\.id) == rhsPlaces.map(\.id)
    default:
      return false
    }
  }
}

// MARK: - NearbyModeViewModel

/// ViewModel para o modo "Perto de mim" (fontes: Minha base e Apple Maps)
@MainActor
@Observable
final class NearbyModeViewModel {
  // MARK: - State

  private(set) var searchState: NearbySearchState = .idle
  private(set) var nearbyRestaurants: [Restaurant] = []
  private(set) var nearbyPlaces: [NearbyPlace] = []
  private(set) var selectedRestaurant: Restaurant?
  private(set) var selectedPlace: NearbyPlace?

  /// Raio atual (sincronizado com AppSettingsStorage)
  var radiusKm: Int {
    didSet {
      AppSettingsStorage.nearbyRadiusKm = radiusKm
    }
  }

  /// Categoria/tipo selecionado
  var selectedCategory: String? {
    didSet {
      AppSettingsStorage.nearbyLastCategory = selectedCategory
    }
  }

  /// Fonte de dados atual
  var source: NearbySource {
    didSet {
      AppSettingsStorage.nearbySource = source
      // Resetar estado ao trocar fonte
      if oldValue != source {
        searchState = .idle
        nearbyRestaurants = []
        nearbyPlaces = []
      }
    }
  }

  // MARK: - Dependencies

  private let locationManager: any LocationManaging
  private let restaurantRepository: any RestaurantRepository
  private let filterService: NearbyLocalFilterService
  private let appleMapsService: any NearbySearching
  private let randomizer: any RestaurantRandomizerProtocol

  // MARK: - Session State

  private var drawnRestaurantIds: Set<String> = []
  private var drawnPlaceIds: Set<String> = []
  private var reRollCount = 0
  private let maxReRolls = 3
  private var lastUserCoordinate: CLLocationCoordinate2D?

  var canReRoll: Bool { reRollCount < maxReRolls }

  // MARK: - Init

  init(
    locationManager: any LocationManaging,
    restaurantRepository: any RestaurantRepository,
    filterService: NearbyLocalFilterService = NearbyLocalFilterService(),
    appleMapsService: any NearbySearching = AppleMapsNearbySearchService(),
    randomizer: any RestaurantRandomizerProtocol = RestaurantRandomizer()
  ) {
    self.locationManager = locationManager
    self.restaurantRepository = restaurantRepository
    self.filterService = filterService
    self.appleMapsService = appleMapsService
    self.randomizer = randomizer
    self.radiusKm = AppSettingsStorage.nearbyRadiusKm
    self.selectedCategory = AppSettingsStorage.nearbyLastCategory
    self.source = AppSettingsStorage.nearbySource
  }

  // MARK: - Location Status

  var locationStatus: LocationStatus {
    locationManager.status
  }

  var hasLocationPermission: Bool {
    locationManager.status.isAuthorized
  }

  var canRequestPermission: Bool {
    locationManager.status.canRequest
  }

  // MARK: - Actions

  /// Solicita permissão de localização
  @MainActor
  func requestLocationPermission() {
    // Garantir que estamos no MainActor antes de solicitar permissão
    locationManager.requestPermission()
    // Atualizar status imediatamente após solicitar
    locationManager.updateStatus()
  }

  /// Abre as configurações do sistema
  func openSettings() {
    locationManager.openSettings()
  }

  /// Busca restaurantes/lugares próximos
  func searchNearby() async {
    // Verificar permissão
    guard hasLocationPermission else {
      if canRequestPermission {
        requestLocationPermission()
        // Aguardar um pouco para o sistema processar a permissão
        try? await Task.sleep(for: .milliseconds(500))
        // Atualizar status após solicitar permissão
        locationManager.updateStatus()
        // Se ainda não tiver permissão, mostrar estado de noPermission
        if !locationManager.status.isAuthorized {
          searchState = .noPermission
        }
        return
      } else {
        searchState = .noPermission
      }
      return
    }

    searchState = .loading

    // Obter localização atual
    guard let userCoordinate = await locationManager.getCurrentLocation() else {
      if let error = locationManager.lastError {
        searchState = .error("Erro ao obter localização: \(error.localizedDescription)")
      } else {
        searchState = .error("Não foi possível obter sua localização")
      }
      return
    }

    lastUserCoordinate = userCoordinate

    // Executar busca baseado na fonte selecionada
    switch source {
    case .localBase:
      await searchLocalBase(userCoordinate: userCoordinate)
    case .appleMaps:
      await searchAppleMaps(userCoordinate: userCoordinate)
    }
  }

  // MARK: - Local Base Search

  private func searchLocalBase(userCoordinate: CLLocationCoordinate2D) async {
    do {
      let allRestaurants = try restaurantRepository.fetchAll()

      // Filtrar por cidade se selecionada
      let cityFiltered: [Restaurant]
      if AppSettingsStorage.selectedCityKey != nil,
         let parsed = AppSettingsStorage.parseSelectedCity() {
        cityFiltered = allRestaurants.filter { restaurant in
          restaurant.city.lowercased() == parsed.city.lowercased() &&
          restaurant.state.lowercased() == parsed.state.lowercased()
        }
      } else {
        cityFiltered = allRestaurants
      }

      // Aplicar filtro de distância e categoria
      let filtered = filterService.filter(
        restaurants: cityFiltered,
        userCoordinate: userCoordinate,
        radiusKm: radiusKm,
        category: selectedCategory
      )

      nearbyRestaurants = filtered
      nearbyPlaces = []

      if filtered.isEmpty {
        searchState = .noResults
      } else {
        searchState = .localResults(filtered)
      }
    } catch {
      searchState = .error("Erro ao buscar restaurantes: \(error.localizedDescription)")
    }
  }

  // MARK: - Apple Maps Search

  private func searchAppleMaps(userCoordinate: CLLocationCoordinate2D) async {
    // Construir cityHint para melhorar resultados
    let cityHint: String?
    if let parsed = AppSettingsStorage.parseSelectedCity() {
      cityHint = parsed.city
    } else {
      cityHint = nil
    }

    do {
      let places = try await appleMapsService.search(
        radiusKm: radiusKm,
        category: selectedCategory,
        userCoordinate: userCoordinate,
        cityHint: cityHint
      )

      nearbyPlaces = places
      nearbyRestaurants = []

      if places.isEmpty {
        searchState = .noResults
      } else {
        searchState = .appleMapsResults(places)
      }
    } catch let error as AppleMapsSearchError {
      switch error {
      case .noResults:
        searchState = .noResults
      case .networkError:
        searchState = .error("Sem conexão. Tente \"Minha base\" ou verifique sua internet.")
      default:
        searchState = .error(error.localizedDescription)
      }
    } catch {
      searchState = .error("Erro ao buscar: \(error.localizedDescription)")
    }
  }

  /// Força uma nova busca ignorando o cache (apenas Apple Maps)
  func refreshSearch() async {
    guard source == .appleMaps else {
      await searchNearby()
      return
    }

    // Usar localização cacheada ou obter nova
    var userCoordinate = lastUserCoordinate
    if userCoordinate == nil {
      userCoordinate = await locationManager.getCurrentLocation()
    }

    guard let coordinate = userCoordinate else {
      searchState = .error("Não foi possível obter sua localização")
      return
    }

    searchState = .loading

    let cityHint: String?
    if let parsed = AppSettingsStorage.parseSelectedCity() {
      cityHint = parsed.city
    } else {
      cityHint = nil
    }

    do {
      let places = try await appleMapsService.searchWithoutCache(
        radiusKm: radiusKm,
        category: selectedCategory,
        userCoordinate: coordinate,
        cityHint: cityHint
      )

      nearbyPlaces = places
      nearbyRestaurants = []

      if places.isEmpty {
        searchState = .noResults
      } else {
        searchState = .appleMapsResults(places)
      }
    } catch let error as AppleMapsSearchError {
      switch error {
      case .noResults:
        searchState = .noResults
      default:
        searchState = .error(error.localizedDescription)
      }
    } catch {
      searchState = .error("Erro ao buscar: \(error.localizedDescription)")
    }
  }

  /// Sorteia um restaurante dos resultados (fonte: Minha base)
  /// - Returns: ID do restaurante sorteado ou nil
  func draw() -> String? {
    guard source == .localBase, !nearbyRestaurants.isEmpty else { return nil }

    // Usar o randomizer com contexto básico
    let context = PreferenceContext()
    if let picked = randomizer.pick(
      from: nearbyRestaurants,
      context: context,
      excludeRestaurantIDs: drawnRestaurantIds
    ) {
      drawnRestaurantIds.insert(picked.id)
      selectedRestaurant = picked
      return picked.id
    }
    return nil
  }

  /// Sorteia um lugar dos resultados (fonte: Apple Maps)
  /// - Returns: NearbyPlace sorteado ou nil
  func drawPlace() -> NearbyPlace? {
    guard source == .appleMaps, !nearbyPlaces.isEmpty else { return nil }

    // Filtrar lugares já sorteados
    let available = nearbyPlaces.filter { !drawnPlaceIds.contains($0.id) }

    guard !available.isEmpty else {
      // Se todos foram sorteados, resetar e sortear novamente
      drawnPlaceIds.removeAll()
      return drawPlace()
    }

    // Sortear aleatoriamente
    guard let picked = available.randomElement() else { return nil }

    drawnPlaceIds.insert(picked.id)
    selectedPlace = picked
    return picked
  }

  /// Tenta sortear novamente
  /// - Returns: ID do restaurante sorteado ou nil (para Minha base)
  func reRoll() -> String? {
    guard canReRoll, source == .localBase else { return nil }
    reRollCount += 1
    return draw()
  }

  /// Tenta sortear novamente (para Apple Maps)
  /// - Returns: NearbyPlace sorteado ou nil
  func reRollPlace() -> NearbyPlace? {
    guard canReRoll, source == .appleMaps else { return nil }
    reRollCount += 1
    return drawPlace()
  }

  /// Reseta a sessão de sorteio
  func resetSession() {
    drawnRestaurantIds.removeAll()
    drawnPlaceIds.removeAll()
    reRollCount = 0
    selectedRestaurant = nil
    selectedPlace = nil
  }

  /// Calcula a distância formatada até um restaurante
  func formattedDistance(to restaurant: Restaurant) -> String? {
    guard let userCoordinate = locationManager.currentLocation else { return nil }
    let meters = filterService.distance(to: restaurant, from: userCoordinate)
    return NearbyLocalFilterService.formatDistance(meters)
  }

  /// Calcula a distância formatada até um lugar (Apple Maps)
  func formattedDistance(to place: NearbyPlace) -> String? {
    guard let userCoordinate = locationManager.currentLocation else { return nil }
    return place.formattedDistance(from: userCoordinate)
  }
  
  /// Calcula a distância em km até um restaurante
  func distanceKm(to restaurant: Restaurant) -> Double? {
    guard let userCoordinate = locationManager.currentLocation else { return nil }
    let meters = filterService.distance(to: restaurant, from: userCoordinate)
    return meters / 1000.0
  }
  
  /// Calcula a distância em km até um lugar (Apple Maps)
  func distanceKm(to place: NearbyPlace) -> Double? {
    guard let userCoordinate = locationManager.currentLocation else { return nil }
    let meters = place.distance(from: userCoordinate)
    return meters / 1000.0
  }

  /// Retorna o lugar selecionado atualmente (Apple Maps)
  func getSelectedPlace() -> NearbyPlace? {
    selectedPlace
  }
}

