//
//  ExternalLinkOpener.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import Foundation
import MapKit
import OSLog
import SwiftUI

/// Helper para abrir links externos e rotas no mapa.
/// Centraliza a lógica de abertura de URLs e fallback para Maps.
@MainActor
struct ExternalLinkOpener {
  // MARK: - Dependencies
  
  private let openURL: OpenURLAction
  private let logger = Logger(subsystem: "ChooseThere", category: "ExternalLinkOpener")
  
  // MARK: - Init
  
  init(openURL: OpenURLAction) {
    self.openURL = openURL
  }
  
  // MARK: - Public API
  
  /// Abre uma URL no navegador ou app correspondente
  func open(url: URL) {
    logger.info("Opening URL: \(url.absoluteString)")
    openURL(url)
  }
  
  /// Abre o TripAdvisor do restaurante
  func openTripAdvisor(url: URL) {
    logger.info("Opening TripAdvisor: \(url.absoluteString)")
    openURL(url)
  }
  
  /// Abre o iFood do restaurante
  func openIFood(url: URL) {
    logger.info("Opening iFood: \(url.absoluteString)")
    openURL(url)
  }
  
  /// Abre o 99 ou fallback para rota no Maps
  func openRideOrRoute(
    ride99URL: URL?,
    restaurantName: String,
    latitude: Double,
    longitude: Double
  ) {
    if let rideURL = ride99URL {
      // Usar link do 99 se disponível
      logger.info("Opening 99: \(rideURL.absoluteString)")
      openURL(rideURL)
    } else {
      // Fallback: abrir rota no Apple Maps
      openRouteInMaps(
        name: restaurantName,
        latitude: latitude,
        longitude: longitude
      )
    }
  }
  
  /// Abre rota no Apple Maps para o destino
  func openRouteInMaps(
    name: String,
    latitude: Double,
    longitude: Double
  ) {
    logger.info("Opening route in Maps for: \(name)")
    
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = name
    
    // Abrir com opções de direção
    mapItem.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
  }
  
  // MARK: - Search URLs (quando não tem link salvo)
  
  /// Abre busca no TripAdvisor pelo nome do restaurante
  func searchTripAdvisor(restaurantName: String, city: String) {
    let query = "\(restaurantName) \(city)"
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    // TripAdvisor search URL
    if let url = URL(string: "https://www.tripadvisor.com.br/Search?q=\(query)") {
      logger.info("Searching TripAdvisor for: \(restaurantName)")
      openURL(url)
    }
  }
  
  /// Abre busca no iFood pelo nome do restaurante
  func searchIFood(restaurantName: String, city: String) {
    let query = "\(restaurantName)"
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    // iFood search URL (abre no navegador com busca pronta)
    if let url = URL(string: "https://www.ifood.com.br/busca?q=\(query)") {
      logger.info("Searching iFood for: \(restaurantName)")
      openURL(url)
    }
  }
  
  /// Abre busca no Google Maps pelo nome do restaurante
  func searchGoogleMaps(restaurantName: String, city: String) {
    let query = "\(restaurantName) \(city)"
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    // Google Maps search URL
    if let url = URL(string: "https://www.google.com/maps/search/\(query)") {
      logger.info("Searching Google Maps for: \(restaurantName)")
      openURL(url)
    }
  }
}

// MARK: - Action Types

/// Tipos de ação rápida disponíveis no card
enum QuickAction: Identifiable, Hashable {
  case tripAdvisor       // Link direto salvo
  case iFood             // Link direto salvo
  case rideOrRoute       // 99 ou fallback Maps
  case searchTripAdvisor // Busca (sem link salvo)
  case searchIFood       // Busca (sem link salvo)
  
  var id: Self { self }
  
  var icon: String {
    switch self {
    case .tripAdvisor:
      return "star.bubble.fill"
    case .iFood:
      return "bag.fill"
    case .rideOrRoute:
      return "car.fill"
    case .searchTripAdvisor:
      return "magnifyingglass"
    case .searchIFood:
      return "magnifyingglass"
    }
  }
  
  var label: String {
    switch self {
    case .tripAdvisor:
      return "TripAdvisor"
    case .iFood:
      return "iFood"
    case .rideOrRoute:
      return "Rota"
    case .searchTripAdvisor:
      return "Buscar TripAdvisor"
    case .searchIFood:
      return "Buscar iFood"
    }
  }
  
  /// Label curto para botões compactos
  var shortLabel: String {
    switch self {
    case .tripAdvisor, .searchTripAdvisor:
      return "TripAdvisor"
    case .iFood, .searchIFood:
      return "iFood"
    case .rideOrRoute:
      return "Rota"
    }
  }
  
  var color: Color {
    switch self {
    case .tripAdvisor, .searchTripAdvisor:
      return Color(hex: 0x34E0A1) // TripAdvisor green
    case .iFood, .searchIFood:
      return Color(hex: 0xEA1D2C) // iFood red
    case .rideOrRoute:
      return AppColors.primary
    }
  }
  
  var accessibilityHint: String {
    switch self {
    case .tripAdvisor:
      return "Abre a página do restaurante no TripAdvisor"
    case .iFood:
      return "Abre o cardápio do restaurante no iFood"
    case .rideOrRoute:
      return "Abre a rota no mapa"
    case .searchTripAdvisor:
      return "Busca o restaurante no TripAdvisor"
    case .searchIFood:
      return "Busca o restaurante no iFood"
    }
  }
  
  /// Se é uma ação de busca (vs link direto)
  var isSearchAction: Bool {
    switch self {
    case .searchTripAdvisor, .searchIFood:
      return true
    default:
      return false
    }
  }
}

// MARK: - Restaurant Extension

extension Restaurant {
  /// Retorna as ações rápidas disponíveis para este restaurante
  /// Prioriza links salvos, senão oferece busca
  var availableQuickActions: [QuickAction] {
    var actions: [QuickAction] = []
    
    // TripAdvisor: link direto ou busca
    if tripAdvisorURL != nil {
      actions.append(.tripAdvisor)
    } else {
      actions.append(.searchTripAdvisor)
    }
    
    // iFood: link direto ou busca
    if iFoodURL != nil {
      actions.append(.iFood)
    } else {
      actions.append(.searchIFood)
    }
    
    // Rota sempre disponível
    actions.append(.rideOrRoute)
    
    return actions
  }
  
  /// Label para o botão de rota (99 se tiver link, senão Rota)
  var rideActionLabel: String {
    ride99URL != nil ? "99" : "Rota"
  }
  
  /// Ícone para o botão de rota
  var rideActionIcon: String {
    ride99URL != nil ? "car.fill" : "map.fill"
  }
}

