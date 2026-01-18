//
//  UnifiedRestaurantCard.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-17.
//

import SwiftUI

/// Card unificado para exibir Restaurant e NearbyPlace
struct UnifiedRestaurantCard: View {
  let item: any NearbyDisplayable
  let onTap: () -> Void
  let onExternalAction: (ExternalAction) -> Void

  // MARK: - Dynamic Type Support
  @ScaledMetric(relativeTo: .body) private var imageSize: CGFloat = 80
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Press State for feedback
  @State private var isPressed: Bool = false

  var body: some View {
    HStack(spacing: 12) {
      // Imagem ou ícone placeholder
      itemImage
        .frame(width: imageSize, height: imageSize)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true) // Imagem é decorativa

      VStack(alignment: .leading, spacing: 4) {
        // Nome + Badge
        HStack(alignment: .top, spacing: 8) {
          Text(item.displayName)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppColors.textPrimary)
            .lineLimit(2)

          Spacer()

          DataSourceBadge(source: item.dataSource)
        }

        // Categoria
        Text(item.displayCategory)
          .font(.system(size: 13))
          .foregroundColor(AppColors.textSecondary)
          .lineLimit(1)

        // Distância
        if let distance = item.distanceKm {
          Text(formatDistance(distance))
            .font(.system(size: 15))
            .foregroundColor(AppColors.textSecondary)
        }

        // Rating (se disponível)
        if let rating = item.displayRating {
          HStack(spacing: 4) {
            Image(systemName: "star.fill")
              .font(.system(size: 12))
              .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
              .font(.system(size: 13, weight: .medium))
              .foregroundColor(AppColors.textPrimary)
          }
        }

        // Quick actions
        HStack(spacing: 8) {
          ForEach(item.externalActions, id: \.self) { action in
            quickActionButton(action)
          }
        }
        .padding(.top, 4)
      }
    }
    .padding(12)
    .background(AppColors.surface)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .animation(reduceMotion ? .none : .spring(response: 0.2), value: isPressed)
    .contentShape(Rectangle())
    .onTapGesture {
      // Feedback visual rápido
      withAnimation(.spring(response: 0.15)) {
        isPressed = true
      }
      // Reset e executa ação
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.spring(response: 0.15)) {
          isPressed = false
        }
        onTap()
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(accessibilityCardLabel)
    .accessibilityHint("Toque duas vezes para ver detalhes")
  }

  // MARK: - Accessibility

  private var accessibilityCardLabel: String {
    var parts = [item.displayName, item.displayCategory]

    if let distance = item.distanceKm {
      parts.append("a \(formatDistance(distance))")
    }

    if let rating = item.displayRating {
      parts.append("avaliação \(String(format: "%.1f", rating)) estrelas")
    }

    parts.append("fonte: \(item.dataSource.displayName)")

    return parts.joined(separator: ", ")
  }

  // MARK: - Item Image

  @ViewBuilder
  private var itemImage: some View {
    if let imageURL = item.displayImageURL {
      AsyncImage(url: imageURL) { phase in
        switch phase {
        case .empty:
          ShimmerView()
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        case .failure:
          imagePlaceholder
        @unknown default:
          imagePlaceholder
        }
      }
    } else {
      imagePlaceholder
    }
  }

  private var imagePlaceholder: some View {
    // Usa o CategoryPlaceholderView para consistência visual com RestaurantCard
    // Diferencia visualmente Apple Maps vs Minha Base através do tema de categoria
    ZStack {
      if item.dataSource == .appleMaps {
        // Para Apple Maps, usa um overlay sutil para diferenciar
        CategoryPlaceholderView(category: item.displayCategory)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
          )
      } else {
        CategoryPlaceholderView(category: item.displayCategory)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  // MARK: - Distance Formatting

  private func formatDistance(_ km: Double) -> String {
    if km < 1 {
      return String(format: "%.0f m", km * 1000)
    }
    return String(format: "%.1f km", km)
  }

  // MARK: - Quick Action Button

  private func quickActionButton(_ action: ExternalAction) -> some View {
    Button {
      onExternalAction(action)
    } label: {
      HStack(spacing: 4) {
        Image(systemName: action.icon)
          .font(.system(size: 10, weight: .semibold))
        Text(action.displayName)
          .font(.system(size: 11, weight: .medium))
      }
      .foregroundColor(actionColor(for: action))
      .padding(.horizontal, 8)
      .padding(.vertical, 5)
      .background(actionColor(for: action).opacity(0.1))
      .clipShape(Capsule())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(action.displayName)
    .accessibilityHint(action.accessibilityLabel)
  }

  private func actionColor(for action: ExternalAction) -> Color {
    switch action {
    case .tripAdvisor:
      return Color(hex: 0x00AA6C) // TripAdvisor green
    case .ifood:
      return Color(hex: 0xEA1D2C) // iFood red
    case .ride99:
      return Color(hex: 0xFF9800) // 99 orange
    case .maps:
      return AppColors.accent
    }
  }
}

// MARK: - Preview

#Preview("Restaurant Card") {
  VStack(spacing: 16) {
    // Simular um card usando dados mock
    UnifiedRestaurantCard(
      item: MockNearbyDisplayable(
        displayId: "1",
        displayName: "Izakaya Matsu",
        displayCategory: "Japonês",
        displayImageURL: nil,
        displayRating: 4.5,
        displayAddress: "Rua Augusta, 123",
        distanceKm: 0.8,
        dataSource: .localBase,
        externalActions: [.tripAdvisor, .ifood, .maps]
      ),
      onTap: {},
      onExternalAction: { _ in }
    )

    UnifiedRestaurantCard(
      item: MockNearbyDisplayable(
        displayId: "2",
        displayName: "Restaurante do Apple Maps",
        displayCategory: "Restaurante",
        displayImageURL: nil,
        displayRating: nil,
        displayAddress: "Av Paulista, 1000",
        distanceKm: 2.3,
        dataSource: .appleMaps,
        externalActions: [.maps]
      ),
      onTap: {},
      onExternalAction: { _ in }
    )
  }
  .padding()
  .background(AppColors.background)
}

// MARK: - Mock for Preview

private struct MockNearbyDisplayable: NearbyDisplayable {
  let displayId: String
  let displayName: String
  let displayCategory: String
  let displayImageURL: URL?
  let displayRating: Double?
  let displayAddress: String?
  let distanceKm: Double?
  let dataSource: DataSource
  let externalActions: [ExternalAction]
}
