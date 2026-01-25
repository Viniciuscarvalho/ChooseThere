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

  /// Indica se estamos em São Paulo (com base local disponível)
  private var isSaoPaulo: Bool {
    AppSettingsStorage.isSaoPauloSelected
  }

  /// Descrição da fonte de dados
  private var dataSourceDescription: String {
    if isSaoPaulo {
      return "Minha Base + Apple Maps"
    } else {
      return "via Apple Maps"
    }
  }

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "mappin.circle.fill")
        .font(.system(size: 28))
        .foregroundStyle(AppColors.accent)

      VStack(alignment: .leading, spacing: 4) {
        Text("Buscando em")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)

        Text(cityDisplayName)
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)

        // Badge indicando fonte de dados
        HStack(spacing: 4) {
          Image(systemName: isSaoPaulo ? "externaldrive.fill" : "map.fill")
            .font(.system(size: 9))
          Text(dataSourceDescription)
            .font(.caption2)
        }
        .foregroundStyle(isSaoPaulo ? AppColors.primary : AppColors.accent)
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

