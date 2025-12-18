//
//  TagChip.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftUI

struct TagChip: View {
  let label: String
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      Text(label.capitalized)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
          isSelected ? AppColors.primary : AppColors.surface,
          in: Capsule()
        )
        .overlay(
          Capsule()
            .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(label.capitalized)")
    .accessibilityHint(isSelected ? "Toque para desmarcar" : "Toque para selecionar")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#Preview {
  HStack {
    TagChip(label: "Japanese", isSelected: true) {}
    TagChip(label: "Pizza", isSelected: false) {}
  }
  .padding()
  .background(AppColors.background)
}

