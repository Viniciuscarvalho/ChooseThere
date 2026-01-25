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
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Computed Properties

  /// Indica se estamos em São Paulo (com base local disponível)
  private var isSaoPaulo: Bool {
    AppSettingsStorage.isSaoPauloSelected
  }

  /// Modos visíveis baseado na localização atual
  /// Minha Lista só aparece em São Paulo (onde há dados locais)
  private var visibleModes: [SearchMode] {
    if isSaoPaulo {
      return SearchMode.allCases
    } else {
      return [.nearby] // Apenas "Perto de mim" fora de SP
    }
  }

  /// Animação usada para transições (respeita reduce motion)
  private var modeAnimation: Animation? {
    reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8)
  }

  var body: some View {
    VStack(spacing: 8) {
      // Segmento principal
      segmentedControl

      // Info contextual para usuário fora de SP
      if !isSaoPaulo {
        nearbyOnlyInfo
      }
    }
  }

  // MARK: - Segmented Control

  private var segmentedControl: some View {
    HStack(spacing: 0) {
      ForEach(visibleModes) { mode in
        Button {
          withAnimation(modeAnimation) {
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
        .transition(.opacity)
      }
    }
    .padding(4)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Modo de busca")
    .animation(reduceMotion ? .none : .linear(duration: 0.25), value: visibleModes)
    .onChange(of: visibleModes) { oldValue, newValue in
      // Se modo atual não está mais visível, mudar para .nearby
      if !newValue.contains(selectedMode) {
        withAnimation(modeAnimation) {
          selectedMode = .nearby
          AppSettingsStorage.searchMode = .nearby
        }
      }
    }
  }

  // MARK: - Nearby Only Info

  private var nearbyOnlyInfo: some View {
    HStack(spacing: 6) {
      Image(systemName: "info.circle.fill")
        .font(.system(size: 12))
      Text("Usando Apple Maps para buscar restaurantes na sua cidade")
        .font(.caption)
    }
    .foregroundStyle(AppColors.textSecondary)
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColors.divider.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
    .accessibilityLabel("Busca via Apple Maps disponível para sua localização")
  }
}

