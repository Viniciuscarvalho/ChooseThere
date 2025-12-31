//
//  OpenGraphImageResolver.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import Foundation
import OSLog

/// Serviço para resolver imagens via OpenGraph (og:image) do site do restaurante.
/// Best-effort: com timeout, cache e tratamento de erros sem travar UI.
actor OpenGraphImageResolver {
  // MARK: - Configuration
  
  /// Timeout padrão para requests (em segundos) - aumentado para sites lentos
  static let defaultTimeout: TimeInterval = 5.0
  
  /// Tamanho máximo do HTML a ser lido (para evitar downloads excessivos)
  private static let maxHTMLSize = 150_000 // ~150KB (aumentado)
  
  // MARK: - Dependencies
  
  private let session: URLSession
  private let logger = Logger(subsystem: "ChooseThere", category: "OpenGraphResolver")
  
  // MARK: - Cache
  
  /// Cache em memória para imagens resolvidas (URL do site -> URL da imagem)
  private var cache: [String: URL] = [:]
  
  /// Cache de falhas para evitar requests repetidos em sites sem og:image
  private var failedCache: Set<String> = []
  
  // MARK: - Singleton
  
  static let shared = OpenGraphImageResolver()
  
  // MARK: - Init
  
  init(timeout: TimeInterval = defaultTimeout) {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = timeout
    config.timeoutIntervalForResource = timeout + 2
    config.waitsForConnectivity = false
    // User-Agent mais completo para evitar bloqueios
    config.httpAdditionalHeaders = [
      "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8"
    ]
    self.session = URLSession(configuration: config)
  }
  
  // MARK: - Public API
  
  /// Resolve a URL da imagem OpenGraph a partir da URL do site.
  /// Retorna `nil` se não encontrar og:image ou se ocorrer erro.
  func resolve(websiteURL: URL) async -> URL? {
    let cacheKey = websiteURL.absoluteString
    
    // Verificar cache de sucesso
    if let cached = cache[cacheKey] {
      logger.debug("✅ Cache hit: \(websiteURL.host ?? "")")
      return cached
    }
    
    // Verificar cache de falhas
    if failedCache.contains(cacheKey) {
      logger.debug("⏭️ Skip (failed before): \(websiteURL.host ?? "")")
      return nil
    }
    
    // Fetch e parse
    do {
      let imageURL = try await fetchAndParse(websiteURL: websiteURL)
      
      if let imageURL {
        cache[cacheKey] = imageURL
        logger.info("🖼️ Found og:image for \(websiteURL.host ?? "")")
        return imageURL
      } else {
        failedCache.insert(cacheKey)
        logger.info("❌ No og:image: \(websiteURL.host ?? "")")
        return nil
      }
    } catch {
      failedCache.insert(cacheKey)
      logger.warning("⚠️ Error for \(websiteURL.host ?? ""): \(error.localizedDescription)")
      return nil
    }
  }
  
  /// Resolve a URL da imagem a partir de uma string de URL.
  func resolve(websiteURLString: String) async -> URL? {
    guard let url = URL(string: websiteURLString) else {
      logger.warning("Invalid URL string: \(websiteURLString)")
      return nil
    }
    return await resolve(websiteURL: url)
  }
  
  /// Limpa o cache (útil para testes ou refresh manual)
  func clearCache() {
    cache.removeAll()
    failedCache.removeAll()
    logger.info("Cache cleared")
  }
  
  /// Limpa apenas o cache de falhas (permite retry)
  func clearFailedCache() {
    failedCache.removeAll()
    logger.info("Failed cache cleared")
  }
  
  // MARK: - Private Methods
  
  private func fetchAndParse(websiteURL: URL) async throws -> URL? {
    var request = URLRequest(url: websiteURL)
    request.httpMethod = "GET"
    
    let (data, response) = try await session.data(for: request)
    
    // Verificar status code
    guard let httpResponse = response as? HTTPURLResponse else {
      throw OpenGraphError.invalidResponse
    }
    
    // Aceitar redirects (3xx já são seguidos automaticamente)
    guard (200...299).contains(httpResponse.statusCode) else {
      logger.debug("HTTP \(httpResponse.statusCode) for \(websiteURL.host ?? "")")
      throw OpenGraphError.invalidResponse
    }
    
    // Verificar content-type (mais permissivo)
    let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
    guard contentType.contains("text/html") || 
          contentType.contains("application/xhtml") ||
          contentType.isEmpty else { // Alguns servidores não enviam content-type
      throw OpenGraphError.notHTML
    }
    
    // Limitar tamanho do HTML
    let limitedData = data.prefix(Self.maxHTMLSize)
    
    // Converter para string (tentar múltiplos encodings)
    guard let html = decodeHTML(Data(limitedData)) else {
      throw OpenGraphError.invalidEncoding
    }
    
    // Parse og:image (tentar múltiplos padrões)
    return parseOGImage(from: html, baseURL: websiteURL)
  }
  
  /// Tenta decodificar HTML com múltiplos encodings
  private func decodeHTML(_ data: Data) -> String? {
    // Tentar UTF-8 primeiro (mais comum)
    if let html = String(data: data, encoding: .utf8) {
      return html
    }
    // Fallback para ISO Latin 1
    if let html = String(data: data, encoding: .isoLatin1) {
      return html
    }
    // Fallback para Windows-1252
    if let html = String(data: data, encoding: .windowsCP1252) {
      return html
    }
    return nil
  }
  
  // MARK: - Parser
  
  /// Extrai a URL do og:image a partir do HTML.
  /// Suporta múltiplos formatos de meta tags.
  func parseOGImage(from html: String, baseURL: URL) -> URL? {
    // Padrões para encontrar og:image (ordem de prioridade)
    let patterns = [
      // Padrão mais comum: property="og:image" content="..."
      #"<meta[^>]+property\s*=\s*[\"']og:image[\"'][^>]+content\s*=\s*[\"']([^\"']+)[\"']"#,
      // Ordem invertida: content="..." property="og:image"
      #"<meta[^>]+content\s*=\s*[\"']([^\"']+)[\"'][^>]+property\s*=\s*[\"']og:image[\"']"#,
      // Usando name em vez de property
      #"<meta[^>]+name\s*=\s*[\"']og:image[\"'][^>]+content\s*=\s*[\"']([^\"']+)[\"']"#,
      #"<meta[^>]+content\s*=\s*[\"']([^\"']+)[\"'][^>]+name\s*=\s*[\"']og:image[\"']"#,
      // Twitter card como fallback
      #"<meta[^>]+name\s*=\s*[\"']twitter:image[\"'][^>]+content\s*=\s*[\"']([^\"']+)[\"']"#,
      #"<meta[^>]+content\s*=\s*[\"']([^\"']+)[\"'][^>]+name\s*=\s*[\"']twitter:image[\"']"#
    ]
    
    for pattern in patterns {
      if let match = html.firstMatch(of: try! Regex(pattern)),
         let capture = match.output[1].substring {
        let urlString = String(capture)
          .trimmingCharacters(in: .whitespacesAndNewlines)
          .replacingOccurrences(of: "&amp;", with: "&") // Decode HTML entities
        
        // Ignorar URLs vazias ou placeholders
        guard !urlString.isEmpty,
              !urlString.contains("placeholder"),
              !urlString.contains("default") else {
          continue
        }
        
        // Tentar como URL absoluta
        if let absoluteURL = URL(string: urlString), 
           absoluteURL.scheme == "https" || absoluteURL.scheme == "http" {
          return absoluteURL
        }
        
        // Tentar como URL relativa
        if let relativeURL = URL(string: urlString, relativeTo: baseURL) {
          return relativeURL.absoluteURL
        }
      }
    }
    
    return nil
  }
}

// MARK: - Errors

enum OpenGraphError: Error, LocalizedError {
  case invalidResponse
  case notHTML
  case invalidEncoding
  case noOGImage
  
  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "Resposta inválida do servidor"
    case .notHTML:
      return "Conteúdo não é HTML"
    case .invalidEncoding:
      return "Encoding inválido"
    case .noOGImage:
      return "og:image não encontrado"
    }
  }
}

// MARK: - Convenience Extension

extension OpenGraphImageResolver {
  /// Resolve imagem para um restaurante, usando prioridade:
  /// 1. imageURL manual (maior prioridade)
  /// 2. og:image do externalLink/site
  /// 3. nil (usar placeholder)
  func resolveForRestaurant(_ restaurant: Restaurant) async -> URL? {
    // Prioridade 1: imageURL manual
    if let imageURL = restaurant.imageURL {
      return imageURL
    }
    
    // Prioridade 2: og:image do site
    if let externalLink = restaurant.externalLink {
      return await resolve(websiteURL: externalLink)
    }
    
    // Prioridade 3: Tentar construir URL do TripAdvisor/iFood se existir
    // (esses sites costumam ter og:image)
    if let tripAdvisorURL = restaurant.tripAdvisorURL {
      if let imageURL = await resolve(websiteURL: tripAdvisorURL) {
        return imageURL
      }
    }
    
    if let iFoodURL = restaurant.iFoodURL {
      if let imageURL = await resolve(websiteURL: iFoodURL) {
        return imageURL
      }
    }
    
    // Nenhuma imagem disponível
    return nil
  }
}
