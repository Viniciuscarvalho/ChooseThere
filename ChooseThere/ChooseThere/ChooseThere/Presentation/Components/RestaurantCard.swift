//
//  RestaurantCard.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import SwiftUI

/// Card de restaurante estilo Deliverio com imagem, informações e ações rápidas.
/// Reutilizável em "Minha base" e "Perto de mim".
struct RestaurantCard: View {
  // MARK: - Properties
  
  let restaurant: Restaurant
  let distance: Double? // em km, opcional
  let onTap: () -> Void
  let onQuickAction: (QuickAction) -> Void
  
  // MARK: - Environment
  
  @Environment(\.openURL) private var openURL
  
  // MARK: - State
  
  @State private var imageURL: URL?
  @State private var imageLoadState: ImageLoadState = .loading
  
  private enum ImageLoadState {
    case loading
    case loaded
    case failed
  }
  
  // MARK: - Constants
  
  private let imageHeight: CGFloat = 140
  private let cornerRadius: CGFloat = 20
  private let shadowRadius: CGFloat = 12
  
  // MARK: - Body
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Imagem com overlay
      imageSection
      
      // Conteúdo
      contentSection
    }
    .background(AppColors.surface)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    .shadow(color: Color.black.opacity(0.06), radius: shadowRadius, x: 0, y: 6)
    .overlay(
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .stroke(AppColors.divider.opacity(0.5), lineWidth: 1)
    )
    .contentShape(Rectangle())
    .onTapGesture {
      onTap()
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("\(restaurant.name), \(restaurant.category)")
    .accessibilityHint("Toque para ver detalhes")
    .task {
      await loadImage()
    }
  }
  
  // MARK: - Image Section
  
  private var imageSection: some View {
    ZStack(alignment: .topLeading) {
      // Imagem ou placeholder
      imageContent
      
      // Overlay gradiente para legibilidade
      LinearGradient(
        colors: [
          Color.black.opacity(0.4),
          Color.black.opacity(0.1),
          Color.clear
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      
      // Badges superiores
      topBadges
    }
    .frame(height: imageHeight)
    .clipShape(
      UnevenRoundedRectangle(
        topLeadingRadius: cornerRadius,
        bottomLeadingRadius: 0,
        bottomTrailingRadius: 0,
        topTrailingRadius: cornerRadius,
        style: .continuous
      )
    )
  }
  
  @ViewBuilder
  private var imageContent: some View {
    switch imageLoadState {
    case .loading:
      ShimmerView()
      
    case .loaded:
      if let url = imageURL {
        AsyncImage(url: url) { phase in
          switch phase {
          case .empty:
            ShimmerView()
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(height: imageHeight)
          case .failure:
            ImagePlaceholder(style: .error, icon: "fork.knife")
          @unknown default:
            ImagePlaceholder(style: .empty, icon: "fork.knife")
          }
        }
      } else {
        ImagePlaceholder(style: .empty, icon: "fork.knife")
      }
      
    case .failed:
      ImagePlaceholder(style: .error, icon: "fork.knife")
    }
  }
  
  private var topBadges: some View {
    HStack {
      // Favorito badge
      if restaurant.isFavorite {
        HStack(spacing: 4) {
          Image(systemName: "heart.fill")
            .font(.system(size: 10, weight: .bold))
          Text("Favorito")
            .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.secondary.opacity(0.9))
        .clipShape(Capsule())
      }
      
      Spacer()
      
      // Rating badge (se tiver)
      if restaurant.ratingCount > 0 {
        HStack(spacing: 3) {
          Image(systemName: "star.fill")
            .font(.system(size: 10, weight: .bold))
          Text(String(format: "%.1f", restaurant.ratingAverage))
            .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .clipShape(Capsule())
      }
    }
    .padding(12)
  }
  
  // MARK: - Content Section
  
  private var contentSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      // Header: Nome e categoria
      VStack(alignment: .leading, spacing: 6) {
        Text(restaurant.name)
          .font(.headline.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)
          .lineLimit(1)
        
        HStack(spacing: 6) {
          // Categoria com ícone
          HStack(spacing: 4) {
            Image(systemName: categoryIcon)
              .font(.system(size: 11, weight: .medium))
            Text(restaurant.category.capitalized)
              .font(.subheadline)
          }
          .foregroundStyle(AppColors.textSecondary)
          .lineLimit(1)
          
          // Separador
          if distance != nil {
            Circle()
              .fill(AppColors.textSecondary.opacity(0.4))
              .frame(width: 3, height: 3)
          }
          
          // Distância (se disponível)
          if let distance {
            distanceBadge(distance)
          }
          
          Spacer()
        }
      }
      
      // Divider sutil
      Rectangle()
        .fill(AppColors.divider.opacity(0.6))
        .frame(height: 1)
      
      // Ações rápidas
      quickActionsSection
    }
    .padding(14)
  }
  
  private var categoryIcon: String {
    let category = restaurant.category.lowercased()
    switch category {
    case let c where c.contains("japonês") || c.contains("japan") || c.contains("sushi"):
      return "fish.fill"
    case let c where c.contains("italiano") || c.contains("pizza") || c.contains("pasta"):
      return "fork.knife"
    case let c where c.contains("café") || c.contains("coffee") || c.contains("padaria"):
      return "cup.and.saucer.fill"
    case let c where c.contains("burger") || c.contains("hamburguer") || c.contains("lanche"):
      return "takeoutbag.and.cup.and.straw.fill"
    case let c where c.contains("bar") || c.contains("drink") || c.contains("cerveja"):
      return "wineglass.fill"
    case let c where c.contains("churrasco") || c.contains("carne") || c.contains("bbq"):
      return "flame.fill"
    case let c where c.contains("vegetariano") || c.contains("vegan") || c.contains("salada"):
      return "leaf.fill"
    case let c where c.contains("doce") || c.contains("sobremesa") || c.contains("sorvete"):
      return "birthday.cake.fill"
    default:
      return "fork.knife"
    }
  }
  
  // MARK: - Distance Badge
  
  private func distanceBadge(_ km: Double) -> some View {
    HStack(spacing: 3) {
      Image(systemName: "location.fill")
        .font(.system(size: 9, weight: .semibold))
      
      Text(formatDistance(km))
        .font(.caption.weight(.medium))
    }
    .foregroundStyle(AppColors.primary)
    .accessibilityLabel("Distância: \(formatDistance(km))")
  }
  
  private func formatDistance(_ km: Double) -> String {
    if km < 1 {
      return "\(Int(km * 1000))m"
    } else {
      return String(format: "%.1f km", km)
    }
  }
  
  // MARK: - Quick Actions Section
  
  private var quickActionsSection: some View {
    HStack(spacing: 6) {
      ForEach(restaurant.availableQuickActions) { action in
        quickActionButton(action: action)
      }
      
      Spacer()
    }
  }
  
  // MARK: - Quick Action Button
  
  private func quickActionButton(action: QuickAction) -> some View {
    Button {
      onQuickAction(action)
    } label: {
      HStack(spacing: 4) {
        Image(systemName: action.icon)
          .font(.system(size: 10, weight: .semibold))
        
        Text(action.shortLabel)
          .font(.caption2.weight(.semibold))
      }
      .foregroundStyle(action.color)
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(action.color.opacity(action.isSearchAction ? 0.08 : 0.12))
      .clipShape(Capsule())
      .overlay(
        // Borda tracejada para ações de busca (indica que não é link direto)
        Capsule()
          .strokeBorder(
            action.isSearchAction ? action.color.opacity(0.3) : Color.clear,
            style: StrokeStyle(lineWidth: 1, dash: [3, 2])
          )
      )
    }
    .buttonStyle(.plain)
    .frame(minHeight: 32)
    .accessibilityLabel(action.label)
    .accessibilityHint(action.accessibilityHint)
  }
  
  // MARK: - Image Loading
  
  private func loadImage() async {
    imageLoadState = .loading
    
    // 1. Se não tem externalLink, tentar enriquecer via MapKit
    var enrichedWebsite: URL? = restaurant.externalLink
    
    if enrichedWebsite == nil {
      let enrichResult = await WebsiteEnrichmentService.shared.enrichRestaurant(restaurant)
      enrichedWebsite = enrichResult.websiteURL
    }
    
    // 2. Resolver imagem via OpenGraph
    var resolvedImageURL: URL? = nil
    
    // Prioridade 1: imageURL manual
    if let manualURL = restaurant.imageURL {
      resolvedImageURL = manualURL
    }
    // Prioridade 2: OpenGraph do site (original ou enriquecido)
    else if let websiteURL = enrichedWebsite {
      resolvedImageURL = await OpenGraphImageResolver.shared.resolve(websiteURL: websiteURL)
    }
    // Prioridade 3: Tentar TripAdvisor
    else if let tripAdvisorURL = restaurant.tripAdvisorURL {
      resolvedImageURL = await OpenGraphImageResolver.shared.resolve(websiteURL: tripAdvisorURL)
    }
    // Prioridade 4: Tentar iFood
    else if let iFoodURL = restaurant.iFoodURL {
      resolvedImageURL = await OpenGraphImageResolver.shared.resolve(websiteURL: iFoodURL)
    }
    
    if let url = resolvedImageURL {
      imageURL = url
      imageLoadState = .loaded
    } else {
      imageLoadState = .failed
    }
  }
}

// MARK: - Preview

#Preview {
  ScrollView {
    VStack(spacing: 16) {
      // Card com todos os links
      RestaurantCard(
        restaurant: Restaurant(
          id: "1",
          name: "Izakaya Matsu",
          category: "Japonês",
          address: "Rua Augusta, 123",
          city: "São Paulo",
          state: "SP",
          tags: ["sushi", "japanese"],
          notes: "",
          externalLink: URL(string: "https://izakayamatsu.com.br"),
          lat: -23.5632,
          lng: -46.6541,
          isFavorite: true,
          ratingAverage: 4.5,
          ratingCount: 12,
          tripAdvisorURL: URL(string: "https://tripadvisor.com/izakaya"),
          iFoodURL: URL(string: "https://ifood.com.br/izakaya"),
          ride99URL: nil,
          imageURL: nil
        ),
        distance: 1.2,
        onTap: { print("Tapped") },
        onQuickAction: { action in print("Action: \(action)") }
      )
      
      // Card sem links
      RestaurantCard(
        restaurant: Restaurant(
          id: "2",
          name: "Pizzaria Bella Napoli",
          category: "Italiano",
          address: "Rua Oscar Freire, 456",
          city: "São Paulo",
          state: "SP",
          tags: ["pizza", "italian"],
          notes: "",
          externalLink: nil,
          lat: -23.5650,
          lng: -46.6550,
          isFavorite: false,
          ratingAverage: 0,
          ratingCount: 0,
          tripAdvisorURL: nil,
          iFoodURL: nil,
          ride99URL: nil,
          imageURL: nil
        ),
        distance: 0.5,
        onTap: { print("Tapped") },
        onQuickAction: { action in print("Action: \(action)") }
      )
    }
    .padding()
  }
  .background(AppColors.background)
}

