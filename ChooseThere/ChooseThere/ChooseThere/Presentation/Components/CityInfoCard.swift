//
//  CityInfoCard.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 01/01/26.
//

import SwiftUI

/// Card que mostra a cidade selecionada com opção de alterar
struct CityInfoCard: View {
  let cityDisplayName: String
  let onChangeTapped: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "mappin.circle.fill")
        .font(.system(size: 28))
        .foregroundStyle(AppColors.accent)

      VStack(alignment: .leading, spacing: 2) {
        Text("Buscando em")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)

        Text(cityDisplayName)
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
      }

      Spacer()

      Button {
        onChangeTapped()
      } label: {
        Text("Alterar")
          .font(.subheadline.weight(.medium))
          .foregroundStyle(AppColors.primary)
      }
      .buttonStyle(.plain)
    }
    .padding(16)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
  }
}

