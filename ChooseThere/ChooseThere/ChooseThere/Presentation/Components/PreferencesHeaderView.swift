//
//  PreferencesHeaderView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 01/01/26.
//

import SwiftUI

/// Header da tela de preferências com título e botão de configurações
struct PreferencesHeaderView: View {
  let onSettingsTapped: () -> Void
  
  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Hoje estamos a fim de…")
          .font(.title2.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)

        Text("Selecione tags e ajuste filtros para sortear.")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
      }

      Spacer()

      Button {
        onSettingsTapped()
      } label: {
        Image(systemName: "gearshape.fill")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(AppColors.textSecondary)
          .frame(width: 40, height: 40)
          .background(AppColors.surface, in: Circle())
          .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Configurações")
    }
  }
}

