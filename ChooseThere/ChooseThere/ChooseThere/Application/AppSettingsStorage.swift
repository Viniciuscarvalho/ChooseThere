//
//  AppSettingsStorage.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import Foundation

// MARK: - SearchMode

/// Modo de busca para sorteio de restaurantes
enum SearchMode: String, CaseIterable, Identifiable, Codable {
  case myList = "myList"
  case nearby = "nearby"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .myList:
      return "Minha Lista"
    case .nearby:
      return "Perto de mim"
    }
  }

  var icon: String {
    switch self {
    case .myList:
      return "list.bullet"
    case .nearby:
      return "location.fill"
    }
  }
}

// MARK: - NearbySource

/// Fonte de dados para o modo "Perto de mim"
enum NearbySource: String, CaseIterable, Identifiable, Codable {
  case localBase = "localBase"
  case appleMaps = "appleMaps"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .localBase:
      return "Minha base"
    case .appleMaps:
      return "Apple Maps"
    }
  }
}

// MARK: - AppSettingsStorage

/// Gerencia preferências globais do usuário via UserDefaults
/// (cidade selecionada, modo "Perto de mim", raio e fonte)
enum AppSettingsStorage {
  // MARK: - Keys

  private static let selectedCityKeyKey = "selectedCityKey"
  private static let nearbySourceKey = "nearbySource"
  private static let nearbyRadiusKmKey = "nearbyRadiusKm"
  private static let nearbyLastCategoryKey = "nearbyLastCategory"
  private static let searchModeKey = "searchMode"

  // MARK: - Defaults

  static let defaultRadiusKm = 3
  static let defaultNearbySource: NearbySource = .localBase
  static let defaultSearchMode: SearchMode = .myList

  // MARK: - Selected City

  /// Cidade selecionada no formato "City|State" (ex: "São Paulo|SP")
  /// `nil` significa "Any City / Perto de mim"
  static var selectedCityKey: String? {
    get { UserDefaults.standard.string(forKey: selectedCityKeyKey) }
    set { UserDefaults.standard.set(newValue, forKey: selectedCityKeyKey) }
  }

  /// Retorna true se está no modo "Any City" (cidade não selecionada)
  static var isAnyCityMode: Bool {
    selectedCityKey == nil
  }

  /// Define a cidade selecionada a partir de city e state separados
  static func setSelectedCity(city: String, state: String) {
    selectedCityKey = "\(city)|\(state)"
  }

  /// Limpa a cidade selecionada (volta para Any City)
  static func clearSelectedCity() {
    selectedCityKey = nil
  }

  /// Parseia a cidade selecionada em (city, state), ou nil se Any City
  static func parseSelectedCity() -> (city: String, state: String)? {
    guard let key = selectedCityKey else { return nil }
    let parts = key.split(separator: "|", maxSplits: 1)
    guard parts.count == 2 else { return nil }
    return (String(parts[0]), String(parts[1]))
  }

  // MARK: - Nearby Source

  /// Fonte atual do modo "Perto de mim"
  static var nearbySource: NearbySource {
    get {
      guard let rawValue = UserDefaults.standard.string(forKey: nearbySourceKey),
            let source = NearbySource(rawValue: rawValue) else {
        return defaultNearbySource
      }
      return source
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: nearbySourceKey)
    }
  }

  // MARK: - Nearby Radius

  /// Raio em km para busca "Perto de mim" (1–10)
  static var nearbyRadiusKm: Int {
    get {
      let stored = UserDefaults.standard.integer(forKey: nearbyRadiusKmKey)
      // Se nunca foi setado, retorna default
      if stored == 0 && !UserDefaults.standard.dictionaryRepresentation().keys.contains(nearbyRadiusKmKey) {
        return defaultRadiusKm
      }
      // Clamp para range válido
      return max(1, min(10, stored))
    }
    set {
      let clamped = max(1, min(10, newValue))
      UserDefaults.standard.set(clamped, forKey: nearbyRadiusKmKey)
    }
  }

  // MARK: - Last Category

  /// Última categoria/tipo usado no modo "Perto de mim"
  static var nearbyLastCategory: String? {
    get { UserDefaults.standard.string(forKey: nearbyLastCategoryKey) }
    set { UserDefaults.standard.set(newValue, forKey: nearbyLastCategoryKey) }
  }

  // MARK: - Search Mode

  /// Modo de busca atual (Minha Lista ou Perto de mim)
  static var searchMode: SearchMode {
    get {
      guard let rawValue = UserDefaults.standard.string(forKey: searchModeKey),
            let mode = SearchMode(rawValue: rawValue) else {
        return defaultSearchMode
      }
      return mode
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: searchModeKey)
    }
  }

  // MARK: - Reset

  /// Reseta todas as preferências (útil para testes)
  static func resetAll() {
    selectedCityKey = nil
    nearbySource = defaultNearbySource
    UserDefaults.standard.removeObject(forKey: nearbyRadiusKmKey)
    nearbyLastCategory = nil
    searchMode = defaultSearchMode
  }

  /// Indica se o onboarding de cidade foi completado
  /// (true se uma cidade foi explicitamente selecionada, incluindo Any City confirmado)
  private static let hasCityOnboardingCompletedKey = "hasCityOnboardingCompleted"

  static var hasCityOnboardingCompleted: Bool {
    get { UserDefaults.standard.bool(forKey: hasCityOnboardingCompletedKey) }
    set { UserDefaults.standard.set(newValue, forKey: hasCityOnboardingCompletedKey) }
  }

  static func markCityOnboardingCompleted() {
    hasCityOnboardingCompleted = true
  }
}

