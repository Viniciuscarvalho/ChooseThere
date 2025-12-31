//
//  LocationManager.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import CoreLocation
import Foundation
import Observation
import UIKit

// MARK: - LocationStatus

/// Estado da permissão de localização
enum LocationStatus: Equatable {
  case notDetermined
  case denied
  case restricted
  case authorized
  case authorizedWhenInUse
  case unknown

  var isAuthorized: Bool {
    self == .authorized || self == .authorizedWhenInUse
  }

  var canRequest: Bool {
    self == .notDetermined
  }
}

// MARK: - LocationManaging Protocol

/// Protocolo para abstração do gerenciador de localização (permite mocks em testes)
@MainActor
protocol LocationManaging: AnyObject {
  var status: LocationStatus { get }
  var currentLocation: CLLocationCoordinate2D? { get }
  var isLoading: Bool { get }
  var lastError: Error? { get }
  
  func requestPermission()
  func getCurrentLocation() async -> CLLocationCoordinate2D?
  func updateStatus()
  func openSettings()
}

// MARK: - LocationManager

/// Gerencia permissões e obtenção de localização via CoreLocation
@MainActor
@Observable
final class LocationManager: NSObject, LocationManaging {
  // MARK: - State

  private(set) var status: LocationStatus = .notDetermined
  private(set) var currentLocation: CLLocationCoordinate2D?
  private(set) var isLoading = false
  private(set) var lastError: Error?

  // MARK: - Private

  private let locationManager = CLLocationManager()
  private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

  // MARK: - Init

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    updateStatus()
  }

  // MARK: - Public API

  /// Solicita permissão de localização
  func requestPermission() {
    guard status.canRequest else { return }
    locationManager.requestWhenInUseAuthorization()
  }

  /// Obtém a localização atual
  /// - Returns: Coordenada ou nil se não disponível
  func getCurrentLocation() async -> CLLocationCoordinate2D? {
    guard status.isAuthorized else {
      if status.canRequest {
        requestPermission()
      }
      return nil
    }

    isLoading = true
    lastError = nil

    return await withCheckedContinuation { continuation in
      locationContinuation = continuation
      locationManager.requestLocation()
    }
  }

  /// Atualiza o status com base no estado atual do CLLocationManager
  func updateStatus() {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      status = .notDetermined
    case .denied:
      status = .denied
    case .restricted:
      status = .restricted
    case .authorizedAlways:
      status = .authorized
    case .authorizedWhenInUse:
      status = .authorizedWhenInUse
    @unknown default:
      status = .unknown
    }
  }

  /// Abre as configurações do sistema
  func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      Task { @MainActor in
        await UIApplication.shared.open(url)
      }
    }
  }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    Task { @MainActor in
      updateStatus()
    }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    Task { @MainActor in
      isLoading = false
      if let location = locations.last {
        currentLocation = location.coordinate
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
      } else {
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
      }
    }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Task { @MainActor in
      isLoading = false
      lastError = error
      locationContinuation?.resume(returning: nil)
      locationContinuation = nil
    }
  }
}

