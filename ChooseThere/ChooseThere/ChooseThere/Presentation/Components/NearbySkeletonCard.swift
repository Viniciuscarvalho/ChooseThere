//
//  NearbySkeletonCard.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-18.
//

import SwiftUI

/// Skeleton loading card para o modo "Perto de mim".
/// Exibe um placeholder animado enquanto os resultados estão carregando.
struct NearbySkeletonCard: View {
  // MARK: - Dynamic Type Support
  @ScaledMetric(relativeTo: .body) private var imageSize: CGFloat = 80

  var body: some View {
    HStack(spacing: 12) {
      // Placeholder para imagem
      ShimmerView(cornerRadius: 12)
        .frame(width: imageSize, height: imageSize)

      VStack(alignment: .leading, spacing: 8) {
        // Placeholder para nome
        ShimmerView(cornerRadius: 4)
          .frame(height: 18)
          .frame(maxWidth: 200)

        // Placeholder para categoria
        ShimmerView(cornerRadius: 4)
          .frame(height: 14)
          .frame(maxWidth: 120)

        // Placeholder para distância
        ShimmerView(cornerRadius: 4)
          .frame(height: 14)
          .frame(maxWidth: 80)
      }
    }
    .padding(12)
    .background(AppColors.surface)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .accessibilityLabel("Carregando restaurante")
    .accessibilityHint("Aguarde enquanto buscamos restaurantes próximos")
  }
}

/// View container para múltiplos skeleton cards (estado de loading)
struct NearbySkeletonList: View {
  let count: Int

  init(count: Int = 5) {
    self.count = count
  }

  var body: some View {
    VStack(spacing: 12) {
      ForEach(0..<count, id: \.self) { _ in
        NearbySkeletonCard()
      }
    }
    .padding(.horizontal, 16)
  }
}

// MARK: - Preview

#Preview("Skeleton Card") {
  VStack(spacing: 16) {
    NearbySkeletonCard()
    NearbySkeletonCard()
    NearbySkeletonCard()
  }
  .padding()
  .background(AppColors.background)
}

#Preview("Skeleton List") {
  ScrollView {
    NearbySkeletonList(count: 5)
  }
  .background(AppColors.background)
}
