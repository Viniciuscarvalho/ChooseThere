//
//  NearbyLocalFilterService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import Foundation

// MARK: - NearbyLocalFilterService

/// Serviço que filtra restaurantes locais por distância e categoria
/// Utiliza a fórmula de haversine do CoreLocation para cálculo de distância
struct NearbyLocalFilterService {
  /// Filtra restaurantes por distância e categoria
  /// - Parameters:
  ///   - restaurants: Lista de restaurantes para filtrar
  ///   - userCoordinate: Coordenada atual do usuário
  ///   - radiusKm: Raio em quilômetros (1-10)
  ///   - category: Categoria/tag opcional para filtrar
  /// - Returns: Lista de restaurantes dentro do raio, ordenados por distância
  func filter(
    restaurants: [Restaurant],
    userCoordinate: CLLocationCoordinate2D,
    radiusKm: Int,
    category: String? = nil
  ) -> [Restaurant] {
    let radiusMeters = Double(radiusKm) * 1000.0
    let userLocation = CLLocation(
      latitude: userCoordinate.latitude,
      longitude: userCoordinate.longitude
    )

    // Filtrar por distância
    var filtered = restaurants.filter { restaurant in
      let restaurantLocation = CLLocation(
        latitude: restaurant.lat,
        longitude: restaurant.lng
      )
      let distance = userLocation.distance(from: restaurantLocation)
      return distance <= radiusMeters
    }

    // Filtrar por categoria/tag se especificada
    if let category = category?.lowercased(), !category.isEmpty {
      filtered = filtered.filter { restaurant in
        // Verifica se a categoria do restaurante contém o termo
        let categoryMatch = restaurant.category.lowercased().contains(category)
        // Verifica se alguma tag contém o termo
        let tagMatch = restaurant.tags.contains { $0.lowercased().contains(category) }
        return categoryMatch || tagMatch
      }
    }

    // Ordenar por distância (mais próximo primeiro)
    return filtered.sorted { r1, r2 in
      let loc1 = CLLocation(latitude: r1.lat, longitude: r1.lng)
      let loc2 = CLLocation(latitude: r2.lat, longitude: r2.lng)
      return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
    }
  }

  /// Calcula a distância em metros entre o usuário e um restaurante
  /// - Parameters:
  ///   - restaurant: Restaurante de destino
  ///   - userCoordinate: Coordenada do usuário
  /// - Returns: Distância em metros
  func distance(
    to restaurant: Restaurant,
    from userCoordinate: CLLocationCoordinate2D
  ) -> Double {
    let userLocation = CLLocation(
      latitude: userCoordinate.latitude,
      longitude: userCoordinate.longitude
    )
    let restaurantLocation = CLLocation(
      latitude: restaurant.lat,
      longitude: restaurant.lng
    )
    return userLocation.distance(from: restaurantLocation)
  }

  /// Formata a distância para exibição
  /// - Parameter meters: Distância em metros
  /// - Returns: String formatada (ex: "500 m", "1.2 km")
  static func formatDistance(_ meters: Double) -> String {
    if meters < 1000 {
      return String(format: "%.0f m", meters)
    } else {
      return String(format: "%.1f km", meters / 1000)
    }
  }
}

