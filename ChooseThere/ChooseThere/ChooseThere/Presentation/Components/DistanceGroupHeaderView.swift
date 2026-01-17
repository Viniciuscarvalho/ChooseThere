//
//  DistanceGroupHeaderView.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-17.
//

import SwiftUI

/// Header de seção para grupos de distância
struct DistanceGroupHeaderView: View {
  let bracket: DistanceBracket
  let count: Int

  var body: some View {
    HStack {
      Text(bracket.displayName)
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(AppColors.textPrimary)

      Circle()
        .fill(AppColors.textSecondary.opacity(0.5))
        .frame(width: 4, height: 4)

      Text("\(count) \(count == 1 ? "restaurante" : "restaurantes")")
        .font(.system(size: 13))
        .foregroundColor(AppColors.textSecondary)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(AppColors.surface.opacity(0.5))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(bracket.displayName), \(count) \(count == 1 ? "restaurante" : "restaurantes")")
    .accessibilityAddTraits(.isHeader)
  }
}

// MARK: - Preview

#Preview("Very Close") {
  VStack(spacing: 0) {
    DistanceGroupHeaderView(bracket: .veryClose, count: 5)
    DistanceGroupHeaderView(bracket: .close, count: 3)
    DistanceGroupHeaderView(bracket: .medium, count: 1)
    DistanceGroupHeaderView(bracket: .far, count: 8)
  }
  .background(AppColors.background)
}
