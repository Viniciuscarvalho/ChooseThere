//
//  CityGeocodingService.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import CoreLocation
import Foundation
import MapKit

// MARK: - CityGeocodingService

/// Serviço para obter coordenadas de uma cidade usando geocoding
final class CityGeocodingService {
  /// Obtém as coordenadas de uma cidade usando geocoding
  /// - Parameters:
  ///   - city: Nome da cidade
  ///   - state: Sigla do estado (ex: "SP")
  /// - Returns: Coordenada da cidade ou nil se não encontrada
  static func getCoordinates(city: String, state: String) async -> CLLocationCoordinate2D? {
    let query = "\(city), \(state), Brasil"
    
    let geocoder = CLGeocoder()
    
    do {
      let placemarks = try await geocoder.geocodeAddressString(query)
      
      guard let placemark = placemarks.first,
            let location = placemark.location else {
        return nil
      }
      
      return location.coordinate
    } catch {
      print("⚠️ CityGeocodingService: Failed to geocode \(query): \(error)")
      return nil
    }
  }
  
  /// Obtém as coordenadas de uma cidade usando MapKit (alternativa)
  /// - Parameters:
  ///   - city: Nome da cidade
  ///   - state: Sigla do estado
  /// - Returns: Coordenada da cidade ou nil se não encontrada
  static func getCoordinatesWithMapKit(city: String, state: String) async -> CLLocationCoordinate2D? {
    let query = "\(city), \(state), Brasil"
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.resultTypes = .address
    
    let search = MKLocalSearch(request: request)
    
    do {
      let response = try await search.start()
      
      guard let mapItem = response.mapItems.first else {
        return nil
      }
      
      return mapItem.placemark.coordinate
    } catch {
      print("⚠️ CityGeocodingService: Failed to geocode with MapKit \(query): \(error)")
      return nil
    }
  }
}

