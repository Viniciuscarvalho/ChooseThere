//
//  ResultViewModel.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation
import Observation
import CoreLocation
import MapKit

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

@MainActor
@Observable
final class ResultViewModel {
  // MARK: - State

  private(set) var restaurant: Restaurant?
  private(set) var isLoading = true
  private(set) var errorMessage: String?
  
  /// Estado do enriquecimento de localização
  private(set) var isEnrichingLocation = false
  private(set) var locationEnriched = false

  var isFavorite: Bool {
    restaurant?.isFavorite ?? false
  }

  var coordinate: CLLocationCoordinate2D? {
    guard let r = restaurant else { return nil }
    return CLLocationCoordinate2D(latitude: r.lat, longitude: r.lng)
  }

  var mapRegion: MKCoordinateRegion {
    guard let coord = coordinate else {
      // Default to São Paulo center
      return MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -23.55, longitude: -46.63),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      )
    }
    return MKCoordinateRegion(
      center: coord,
      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
  }

  // MARK: - Dependencies

  private let restaurantRepository: any RestaurantRepository
  private let restaurantId: String
  private var enrichmentService: RestaurantLocationEnrichmentService?

  init(restaurantId: String, restaurantRepository: any RestaurantRepository) {
    self.restaurantId = restaurantId
    self.restaurantRepository = restaurantRepository
    
    // Criar serviço de enriquecimento
    let placeResolver = MapKitPlaceResolver()
    self.enrichmentService = RestaurantLocationEnrichmentService(
      placeResolver: placeResolver,
      restaurantRepository: restaurantRepository
    )
  }

  // MARK: - Actions

  func load() {
    isLoading = true
    errorMessage = nil
    do {
      restaurant = try restaurantRepository.fetch(id: restaurantId)
      if restaurant == nil {
        errorMessage = "Restaurante não encontrado."
      } else {
        // Verificar se precisa enriquecer localização em background
        Task {
          await enrichLocationIfNeeded()
        }
      }
    } catch {
      errorMessage = "Erro ao carregar restaurante."
    }
    isLoading = false
  }
  
  /// Enriquece a localização do restaurante se ainda não foi resolvida
  private func enrichLocationIfNeeded() async {
    guard let r = restaurant, !r.applePlaceResolved else {
      locationEnriched = restaurant?.applePlaceResolved ?? false
      return
    }
    
    isEnrichingLocation = true
    
    if let service = enrichmentService {
      let result = await service.resolve(restaurantId: restaurantId)
      
      switch result {
      case .success(let lat, let lng, _, _):
        // Recarregar restaurante para obter dados atualizados
        if let updated = try? restaurantRepository.fetch(id: restaurantId) {
          restaurant = updated
          locationEnriched = true
        }
        
      case .alreadyResolved, .cacheHit:
        locationEnriched = true
        
      case .notFound, .failed:
        locationEnriched = false
      }
    }
    
    isEnrichingLocation = false
  }

  func toggleFavorite() {
    guard let r = restaurant else { return }
    let newValue = !r.isFavorite
    do {
      try restaurantRepository.setFavorite(id: r.id, isFavorite: newValue)
      // Reload to reflect change
      restaurant = try restaurantRepository.fetch(id: restaurantId)
    } catch {
      // Silent fail
    }
  }

  func openInMaps() {
    guard let coord = coordinate, let r = restaurant else { return }
    let placemark = MKPlacemark(coordinate: coord)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = r.name
    mapItem.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
  }

  func openInGoogleMaps() {
    guard let coord = coordinate else { return }
    let webUrl = "https://www.google.com/maps/dir/?api=1&destination=\(coord.latitude),\(coord.longitude)"
    guard let url = URL(string: webUrl) else { return }

    #if os(iOS)
    let appUrlString = "comgooglemaps://?daddr=\(coord.latitude),\(coord.longitude)&directionsmode=driving"
    if let appUrl = URL(string: appUrlString), UIApplication.shared.canOpenURL(appUrl) {
      UIApplication.shared.open(appUrl)
    } else {
      UIApplication.shared.open(url)
    }
    #elseif os(macOS)
    NSWorkspace.shared.open(url)
    #endif
  }
}

