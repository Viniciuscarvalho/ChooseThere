//
//  CityCatalog.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import Foundation

// MARK: - CityOption

/// Representa uma opção de cidade para seleção
struct CityOption: Identifiable, Hashable {
  /// Identificador único no formato "City|State" ou nil para Any City
  let id: String?
  /// Nome da cidade
  let city: String
  /// Estado/UF
  let state: String
  /// Nome para exibição
  let displayName: String

  /// Opção especial "Any City / Perto de mim"
  static let anyCity = CityOption(
    id: nil,
    city: "",
    state: "",
    displayName: "Qualquer lugar (Perto de mim)"
  )

  /// Cria uma opção de cidade a partir de city e state
  init(city: String, state: String) {
    self.id = "\(city)|\(state)"
    self.city = city
    self.state = state
    self.displayName = "\(city), \(state)"
  }

  /// Inicializador privado para opções especiais
  private init(id: String?, city: String, state: String, displayName: String) {
    self.id = id
    self.city = city
    self.state = state
    self.displayName = displayName
  }

  /// Verifica se é a opção "Any City"
  var isAnyCity: Bool {
    id == nil
  }
}

// MARK: - CityCatalog

/// Catálogo de cidades disponíveis, derivado do seed local + capitais do Brasil
enum CityCatalog {
  /// Lista de todas as capitais do Brasil (26 estados + DF)
  static let brazilianCapitals: [CityOption] = [
    CityOption(city: "Rio Branco", state: "AC"),
    CityOption(city: "Maceió", state: "AL"),
    CityOption(city: "Macapá", state: "AP"),
    CityOption(city: "Manaus", state: "AM"),
    CityOption(city: "Salvador", state: "BA"),
    CityOption(city: "Fortaleza", state: "CE"),
    CityOption(city: "Brasília", state: "DF"),
    CityOption(city: "Vitória", state: "ES"),
    CityOption(city: "Goiânia", state: "GO"),
    CityOption(city: "São Luís", state: "MA"),
    CityOption(city: "Cuiabá", state: "MT"),
    CityOption(city: "Campo Grande", state: "MS"),
    CityOption(city: "Belo Horizonte", state: "MG"),
    CityOption(city: "Belém", state: "PA"),
    CityOption(city: "João Pessoa", state: "PB"),
    CityOption(city: "Curitiba", state: "PR"),
    CityOption(city: "Recife", state: "PE"),
    CityOption(city: "Teresina", state: "PI"),
    CityOption(city: "Rio de Janeiro", state: "RJ"),
    CityOption(city: "Natal", state: "RN"),
    CityOption(city: "Porto Alegre", state: "RS"),
    CityOption(city: "Porto Velho", state: "RO"),
    CityOption(city: "Boa Vista", state: "RR"),
    CityOption(city: "Florianópolis", state: "SC"),
    CityOption(city: "São Paulo", state: "SP"),
    CityOption(city: "Aracaju", state: "SE"),
    CityOption(city: "Palmas", state: "TO")
  ]

  /// Extrai cidades únicas a partir de uma lista de restaurantes
  /// - Parameter restaurants: Lista de restaurantes com city/state
  /// - Returns: Lista ordenada de CityOption (Any City + cidades únicas)
  static func extractCities(from restaurants: [Restaurant]) -> [CityOption] {
    // Extrair pares únicos de city/state
    var uniqueCities: Set<String> = []
    var cityOptions: [CityOption] = []

    for restaurant in restaurants {
      let city = restaurant.city.trimmingCharacters(in: .whitespacesAndNewlines)
      let state = restaurant.state.trimmingCharacters(in: .whitespacesAndNewlines)

      // Ignorar entradas vazias
      guard !city.isEmpty, !state.isEmpty else { continue }

      let key = "\(city)|\(state)"
      if !uniqueCities.contains(key) {
        uniqueCities.insert(key)
        cityOptions.append(CityOption(city: city, state: state))
      }
    }

    // Ordenar por nome da cidade, depois por estado
    let sorted = cityOptions.sorted { lhs, rhs in
      if lhs.city == rhs.city {
        return lhs.state < rhs.state
      }
      return lhs.city < rhs.city
    }

    // Adicionar "Any City" no início
    return [CityOption.anyCity] + sorted
  }

  /// Extrai cidades únicas a partir de um repository
  /// - Parameter repository: Repository de restaurantes
  /// - Returns: Lista ordenada de CityOption (Any City + cidades únicas + capitais do Brasil)
  static func extractCities(from repository: any RestaurantRepository) -> [CityOption] {
    var allCities: Set<String> = []
    var cityOptions: [CityOption] = []

    // 1. Adicionar cidades do repositório
    do {
      let restaurants = try repository.fetchAll()
      for restaurant in restaurants {
        let city = restaurant.city.trimmingCharacters(in: .whitespacesAndNewlines)
        let state = restaurant.state.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !city.isEmpty, !state.isEmpty else { continue }

        let key = "\(city)|\(state)"
        if !allCities.contains(key) {
          allCities.insert(key)
          cityOptions.append(CityOption(city: city, state: state))
        }
      }
    } catch {
      // Em caso de erro, continuar apenas com capitais
    }

    // 2. Adicionar capitais do Brasil que não estão no repositório
    for capital in brazilianCapitals {
      let key = capital.id ?? ""
      if !allCities.contains(key) {
        allCities.insert(key)
        cityOptions.append(capital)
      }
    }

    // 3. Ordenar por nome da cidade, depois por estado
    let sorted = cityOptions.sorted { lhs, rhs in
      if lhs.city == rhs.city {
        return lhs.state < rhs.state
      }
      return lhs.city < rhs.city
    }

    // 4. Adicionar "Any City" no início
    return [CityOption.anyCity] + sorted
  }

  /// Encontra a CityOption correspondente a um selectedCityKey
  /// - Parameters:
  ///   - key: Chave no formato "City|State" ou nil
  ///   - options: Lista de opções disponíveis
  /// - Returns: CityOption correspondente ou anyCity se não encontrado
  static func findOption(for key: String?, in options: [CityOption]) -> CityOption {
    guard let key else { return .anyCity }
    return options.first { $0.id == key } ?? .anyCity
  }
}

