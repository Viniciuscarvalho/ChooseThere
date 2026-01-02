//
//  SearchModeSegmentView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 01/01/26.
//

import SwiftUI

/// Segmento de seleção entre "Minha Lista" e "Perto de mim"
struct SearchModeSegmentView: View {
  @Binding var selectedMode: SearchMode
  
  var body: some View {
    HStack(spacing: 0) {
      ForEach(SearchMode.allCases) { mode in
        Button {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedMode = mode
            AppSettingsStorage.searchMode = mode
          }
        } label: {
          HStack(spacing: 6) {
            Image(systemName: mode.icon)
              .font(.system(size: 14, weight: .medium))
            Text(mode.displayName)
              .font(.subheadline.weight(.semibold))
          }
          .foregroundStyle(selectedMode == mode ? AppColors.textPrimary : AppColors.textSecondary)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 44)
          .background(
            selectedMode == mode
              ? AppColors.primary
              : Color.clear,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
          )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.displayName)
        .accessibilityHint(selectedMode == mode ? "Modo selecionado" : "Toque duas vezes para selecionar")
        .accessibilityAddTraits(selectedMode == mode ? .isSelected : [])
      }
    }
    .padding(4)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Modo de busca")
  }
}

