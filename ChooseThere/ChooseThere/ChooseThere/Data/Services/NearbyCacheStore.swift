//
//  NearbyCacheStore.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import Foundation

// MARK: - NearbyCacheKey

/// Chave para identificar uma entrada no cache de "Perto de mim"
struct NearbyCacheKey: Hashable, Codable {
  let source: String // sempre "appleMaps" por enquanto
  let category: String?
  let radiusKm: Int
  let cityHint: String?
  let locationBucket: String // ex: "-23.56|-46.65" (arredondado)

  /// Cria uma chave de cache a partir dos parâmetros de busca
  static func make(
    category: String?,
    radiusKm: Int,
    cityHint: String?,
    latitude: Double,
    longitude: Double,
    precision: Int = 2
  ) -> NearbyCacheKey {
    // Arredonda lat/lng para criar "buckets" de localização
    let latBucket = (latitude * pow(10.0, Double(precision))).rounded() / pow(10.0, Double(precision))
    let lngBucket = (longitude * pow(10.0, Double(precision))).rounded() / pow(10.0, Double(precision))
    let locationBucket = String(format: "%.2f|%.2f", latBucket, lngBucket)

    return NearbyCacheKey(
      source: "appleMaps",
      category: category,
      radiusKm: radiusKm,
      cityHint: cityHint,
      locationBucket: locationBucket
    )
  }
}

// MARK: - NearbyCacheEntry

/// Uma entrada no cache com dados e metadados de expiração
struct NearbyCacheEntry: Codable {
  let key: NearbyCacheKey
  let createdAt: Date
  let ttlSeconds: Int
  let placesData: Data // JSON encoded [NearbyPlace]

  var isExpired: Bool {
    Date().timeIntervalSince(createdAt) > Double(ttlSeconds)
  }
}

// MARK: - NearbyCacheStore

/// Gerencia o cache local para resultados do Apple Maps "Perto de mim"
/// Implementação simples usando UserDefaults com serialização JSON
enum NearbyCacheStore {
  // MARK: - Keys

  private static let cacheKey = "nearby_cache_entries"

  // MARK: - Defaults

  static let defaultTTLSeconds = 30 * 60 // 30 minutos

  // MARK: - Public API

  /// Busca uma entrada no cache
  /// - Parameter key: Chave de cache
  /// - Returns: Data dos places se encontrado e válido, nil caso contrário
  static func get(for key: NearbyCacheKey) -> Data? {
    let entries = loadEntries()
    guard let entry = entries[key], !entry.isExpired else {
      return nil
    }
    return entry.placesData
  }

  /// Armazena uma entrada no cache
  /// - Parameters:
  ///   - placesData: Data serializada dos places
  ///   - key: Chave de cache
  ///   - ttlSeconds: Tempo de vida em segundos (default: 30 min)
  static func set(_ placesData: Data, for key: NearbyCacheKey, ttlSeconds: Int = defaultTTLSeconds) {
    var entries = loadEntries()
    let entry = NearbyCacheEntry(
      key: key,
      createdAt: Date(),
      ttlSeconds: ttlSeconds,
      placesData: placesData
    )
    entries[key] = entry
    saveEntries(entries)
  }

  /// Remove uma entrada específica do cache
  /// - Parameter key: Chave de cache
  static func remove(for key: NearbyCacheKey) {
    var entries = loadEntries()
    entries.removeValue(forKey: key)
    saveEntries(entries)
  }

  /// Limpa todo o cache
  static func clear() {
    UserDefaults.standard.removeObject(forKey: cacheKey)
  }

  /// Remove entradas expiradas do cache
  static func pruneExpired() {
    var entries = loadEntries()
    let validEntries = entries.filter { !$0.value.isExpired }
    if validEntries.count != entries.count {
      saveEntries(validEntries)
    }
  }

  /// Retorna o número de entradas no cache
  static var count: Int {
    loadEntries().count
  }

  /// Retorna o número de entradas válidas (não expiradas) no cache
  static var validCount: Int {
    loadEntries().filter { !$0.value.isExpired }.count
  }

  // MARK: - Private

  private static func loadEntries() -> [NearbyCacheKey: NearbyCacheEntry] {
    guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
      return [:]
    }
    do {
      return try JSONDecoder().decode([NearbyCacheKey: NearbyCacheEntry].self, from: data)
    } catch {
      print("⚠️ NearbyCacheStore: Failed to decode entries: \(error)")
      return [:]
    }
  }

  private static func saveEntries(_ entries: [NearbyCacheKey: NearbyCacheEntry]) {
    do {
      let data = try JSONEncoder().encode(entries)
      UserDefaults.standard.set(data, forKey: cacheKey)
    } catch {
      print("⚠️ NearbyCacheStore: Failed to encode entries: \(error)")
    }
  }
}

