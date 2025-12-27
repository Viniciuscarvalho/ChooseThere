//
//  NearbyPlace.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import Foundation

// MARK: - NearbyPlace

/// Entidade transitória para resultados do Apple Maps
/// Não é persistida no SwiftData para não "poluir" a base do usuário
struct NearbyPlace: Identifiable, Equatable, Hashable, Codable {
  /// ID único estável (derivado de nome + coordenadas)
  let id: String

  /// Nome do estabelecimento
  let name: String

  /// Endereço formatado (opcional)
  let address: String?

  /// Latitude
  let latitude: Double

  /// Longitude
  let longitude: Double

  /// Dica de categoria (derivada do MapKit quando disponível)
  let categoryHint: String?

  /// URL externa para abrir no Maps (opcional)
  let externalLink: URL?

  /// Número de telefone (opcional)
  let phoneNumber: String?

  // MARK: - Computed Properties

  /// Coordenada como CLLocationCoordinate2D
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

  // MARK: - Initializers

  init(
    id: String,
    name: String,
    address: String? = nil,
    latitude: Double,
    longitude: Double,
    categoryHint: String? = nil,
    externalLink: URL? = nil,
    phoneNumber: String? = nil
  ) {
    self.id = id
    self.name = name
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.categoryHint = categoryHint
    self.externalLink = externalLink
    self.phoneNumber = phoneNumber
  }

  /// Cria um NearbyPlace com ID gerado automaticamente
  static func create(
    name: String,
    address: String? = nil,
    latitude: Double,
    longitude: Double,
    categoryHint: String? = nil,
    externalLink: URL? = nil,
    phoneNumber: String? = nil
  ) -> NearbyPlace {
    // Gera ID estável baseado em nome + coordenadas arredondadas
    let coordKey = String(format: "%.5f|%.5f", latitude, longitude)
    let idSource = "\(name)|\(coordKey)"
    let id = idSource.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString

    return NearbyPlace(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      categoryHint: categoryHint,
      externalLink: externalLink,
      phoneNumber: phoneNumber
    )
  }
}

// MARK: - Distance Calculation

extension NearbyPlace {
  /// Calcula a distância em metros até uma coordenada
  func distance(from coordinate: CLLocationCoordinate2D) -> Double {
    let placeLocation = CLLocation(latitude: latitude, longitude: longitude)
    let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    return userLocation.distance(from: placeLocation)
  }

  /// Retorna a distância formatada
  func formattedDistance(from coordinate: CLLocationCoordinate2D) -> String {
    let meters = distance(from: coordinate)
    if meters < 1000 {
      return String(format: "%.0f m", meters)
    } else {
      return String(format: "%.1f km", meters / 1000)
    }
  }
}

