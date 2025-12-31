//
//  NearbyPlaceCard.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import SwiftUI

/// Card para exibir resultados do Apple Maps no modo "Perto de mim".
/// Estilo Deliverio, consistente com RestaurantCard.
struct NearbyPlaceCard: View {
  // MARK: - Properties
  
  let place: NearbyPlace
  let distance: Double? // em km, opcional
  let onTap: () -> Void
  let onRouteAction: () -> Void
  
  // MARK: - Constants
  
  private let imageHeight: CGFloat = 100
  private let cornerRadius: CGFloat = 20
  private let shadowRadius: CGFloat = 12
  
  // MARK: - Body
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header visual (Maps themed)
      headerSection
      
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
    .accessibilityLabel("\(place.name)\(place.categoryHint.map { ", \($0)" } ?? "")")
    .accessibilityHint("Toque para ver detalhes")
  }
  
  // MARK: - Header Section (Maps themed)
  
  private var headerSection: some View {
    ZStack(alignment: .bottomLeading) {
      // Background gradiente temático
      LinearGradient(
        colors: [
          AppColors.primary.opacity(0.15),
          AppColors.accent.opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      
      // Pattern decorativo
      GeometryReader { geometry in
        ZStack {
          // Círculos decorativos
          Circle()
            .fill(AppColors.primary.opacity(0.1))
            .frame(width: 60, height: 60)
            .offset(x: geometry.size.width - 40, y: -20)
          
          Circle()
            .fill(AppColors.accent.opacity(0.08))
            .frame(width: 40, height: 40)
            .offset(x: geometry.size.width - 80, y: 50)
        }
      }
      
      // Ícone e label do Apple Maps
      VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 8) {
          // Ícone de mapa
          ZStack {
            Circle()
              .fill(AppColors.primary.opacity(0.15))
              .frame(width: 44, height: 44)
            
            Image(systemName: "map.fill")
              .font(.system(size: 18, weight: .medium))
              .foregroundStyle(AppColors.primary)
          }
          
          VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
              Image(systemName: "apple.logo")
                .font(.system(size: 10, weight: .medium))
              Text("Maps")
                .font(.caption.weight(.semibold))
            }
            .foregroundStyle(AppColors.textSecondary.opacity(0.8))
            
            if let category = place.categoryHint {
              Text(category)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                .lineLimit(1)
            }
          }
        }
      }
      .padding(14)
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
  
  // MARK: - Content Section
  
  private var contentSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      // Header: Nome
      VStack(alignment: .leading, spacing: 6) {
        Text(place.name)
          .font(.headline.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)
          .lineLimit(2)
        
        HStack(spacing: 6) {
          // Endereço
          if let address = place.address {
            HStack(spacing: 4) {
              Image(systemName: "mappin")
                .font(.system(size: 10, weight: .medium))
              Text(address)
                .font(.caption)
                .lineLimit(1)
            }
            .foregroundStyle(AppColors.textSecondary.opacity(0.8))
          }
          
          Spacer()
          
          // Distância
          if let distance {
            distanceBadge(distance)
          }
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
    HStack(spacing: 8) {
      // Rota no mapa
      routeButton
      
      // Salvar na base (CTA secundário)
      saveButton
      
      Spacer()
    }
  }
  
  // MARK: - Route Button
  
  private var routeButton: some View {
    Button {
      onRouteAction()
    } label: {
      HStack(spacing: 5) {
        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
          .font(.system(size: 11, weight: .semibold))
        
        Text("Rota")
          .font(.caption.weight(.semibold))
      }
      .foregroundStyle(AppColors.primary)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(AppColors.primary.opacity(0.12))
      .clipShape(Capsule())
    }
    .buttonStyle(.plain)
    .frame(minWidth: 44, minHeight: 36)
    .accessibilityLabel("Rota no mapa")
    .accessibilityHint("Abre a rota para este lugar no Apple Maps")
  }
  
  // MARK: - Save Button (visual only for now)
  
  private var saveButton: some View {
    Button {
      onTap() // Abre detalhes onde pode salvar
    } label: {
      HStack(spacing: 5) {
        Image(systemName: "plus.circle.fill")
          .font(.system(size: 11, weight: .semibold))
        
        Text("Salvar")
          .font(.caption.weight(.semibold))
      }
      .foregroundStyle(AppColors.accent)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(AppColors.accent.opacity(0.12))
      .clipShape(Capsule())
    }
    .buttonStyle(.plain)
    .frame(minWidth: 44, minHeight: 36)
    .accessibilityLabel("Salvar na minha base")
    .accessibilityHint("Adiciona este lugar à sua lista de restaurantes")
  }
}

// MARK: - Preview

#Preview {
  ScrollView {
    VStack(spacing: 20) {
      NearbyPlaceCard(
        place: NearbyPlace.create(
          name: "Restaurante Bom Sabor",
          address: "Rua Augusta, 1234, São Paulo",
          latitude: -23.5632,
          longitude: -46.6541,
          categoryHint: "Restaurante"
        ),
        distance: 0.8,
        onTap: { print("Tapped") },
        onRouteAction: { print("Route") }
      )
      
      NearbyPlaceCard(
        place: NearbyPlace.create(
          name: "Padaria Central com Nome Muito Grande Para Testar Quebra de Linha",
          address: "Avenida Paulista, 5678",
          latitude: -23.5650,
          longitude: -46.6550,
          categoryHint: "Padaria"
        ),
        distance: 1.5,
        onTap: { print("Tapped") },
        onRouteAction: { print("Route") }
      )
      
      NearbyPlaceCard(
        place: NearbyPlace.create(
          name: "Café Expresso",
          address: nil,
          latitude: -23.5660,
          longitude: -46.6560,
          categoryHint: nil
        ),
        distance: 0.3,
        onTap: { print("Tapped") },
        onRouteAction: { print("Route") }
      )
    }
    .padding(16)
  }
  .background(AppColors.background)
}
