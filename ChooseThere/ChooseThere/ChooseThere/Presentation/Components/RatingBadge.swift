//
//  RatingBadge.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import SwiftUI

/// Badge para exibir rating de um restaurante
struct RatingBadge: View {
  let average: Double
  let count: Int
  
  /// Estilo de exibição
  enum Style {
    case compact  // Apenas estrela + média (para listas)
    case full     // Estrela + média + contagem (para detalhes)
    case inline   // Para uso em textos
  }
  
  var style: Style = .compact
  
  var body: some View {
    if count > 0 {
      HStack(spacing: 4) {
        Image(systemName: "star.fill")
          .font(.system(size: style == .compact ? 12 : 14, weight: .medium))
          .foregroundStyle(AppColors.primary)
        
        Text(String(format: "%.1f", average))
          .font(style == .compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
          .foregroundStyle(AppColors.textPrimary)
        
        if style == .full {
          Text("(\(count))")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }
      }
      .accessibilityLabel("Avaliação \(String(format: "%.1f", average)) de 5, baseada em \(count) \(count == 1 ? "avaliação" : "avaliações")")
    } else {
      // Sem avaliações
      if style == .full {
        HStack(spacing: 4) {
          Image(systemName: "star")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
          
          Text("Sem avaliações")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }
        .accessibilityLabel("Sem avaliações")
      }
      // No compact mode, don't show anything if no ratings
    }
  }
}

// MARK: - Convenience Initializers

extension RatingBadge {
  /// Inicializa a partir de um Restaurant
  init(restaurant: Restaurant, style: Style = .compact) {
    self.average = restaurant.ratingAverage
    self.count = restaurant.ratingCount
    self.style = style
  }
}

// MARK: - Preview

#Preview {
  VStack(spacing: 20) {
    // Com rating
    RatingBadge(average: 4.5, count: 12, style: .compact)
    RatingBadge(average: 4.5, count: 12, style: .full)
    
    // Sem rating
    RatingBadge(average: 0, count: 0, style: .compact)
    RatingBadge(average: 0, count: 0, style: .full)
  }
  .padding()
  .background(AppColors.background)
}

