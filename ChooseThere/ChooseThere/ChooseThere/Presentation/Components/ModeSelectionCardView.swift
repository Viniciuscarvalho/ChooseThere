//
//  ModeSelectionCardView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 01/24/26.
//

import SwiftUI

/// Card individual para seleção de modo de busca
/// Design melhorado com visual claro e hierarquia definida
struct ModeSelectionCard: View {
  let mode: SearchMode
  let isSelected: Bool
  let onTap: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Computed Properties

  private var accentColor: Color {
    switch mode {
    case .myList:
      return AppColors.primary // Amarelo/Mango
    case .nearby:
      return AppColors.accent // Mint/Turquesa
    }
  }

  private var lightAccentColor: Color {
    accentColor.opacity(0.15)
  }

  private var icon: String {
    switch mode {
    case .myList:
      return "heart.fill"
    case .nearby:
      return "location.fill"
    }
  }

  private var title: String {
    mode.displayName
  }

  private var description: String {
    switch mode {
    case .myList:
      return "Restaurantes selecionados a dedo, com filtros por categoria, preço e nota"
    case .nearby:
      return "Encontre restaurantes próximos usando sua localização atual"
    }
  }

  private var badgeText: String {
    switch mode {
    case .myList:
      return "Base local curada"
    case .nearby:
      return "via Apple Maps"
    }
  }

  private var badgeIcon: String {
    switch mode {
    case .myList:
      return "externaldrive.fill"
    case .nearby:
      return "map.fill"
    }
  }

  private var cardAnimation: Animation? {
    reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)
  }

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 14) {
        // Icon Box
        iconBox

        // Content
        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.body.weight(.semibold))
            .foregroundStyle(AppColors.textPrimary)

          Text(description)
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)

          // Badge
          badge
        }

        Spacer(minLength: 0)

        // Selection indicator
        if isSelected {
          selectionIndicator
        }
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(AppColors.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(
            isSelected ? accentColor : AppColors.divider,
            lineWidth: isSelected ? 2 : 1
          )
      )
      .shadow(
        color: isSelected ? accentColor.opacity(0.2) : Color.black.opacity(0.04),
        radius: isSelected ? 12 : 6,
        y: isSelected ? 4 : 2
      )
    }
    .buttonStyle(.plain)
    .animation(cardAnimation, value: isSelected)
    .accessibilityLabel(title)
    .accessibilityHint(isSelected ? "Modo selecionado" : "Toque duas vezes para selecionar")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }

  // MARK: - Subviews

  private var iconBox: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(lightAccentColor)
        .frame(width: 56, height: 56)

      Image(systemName: icon)
        .font(.system(size: 26, weight: .medium))
        .foregroundStyle(accentColor)
    }
  }

  private var badge: some View {
    HStack(spacing: 4) {
      Image(systemName: badgeIcon)
        .font(.system(size: 10, weight: .medium))

      Text(badgeText)
        .font(.caption2.weight(.semibold))
    }
    .foregroundStyle(accentColor)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      Capsule()
        .fill(lightAccentColor)
    )
  }

  private var selectionIndicator: some View {
    ZStack {
      Circle()
        .fill(accentColor)
        .frame(width: 24, height: 24)

      Image(systemName: "checkmark")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.white)
    }
  }
}

// MARK: - Mode Selection Container

/// Container com os dois cards de seleção de modo
/// Substitui o SearchModeSegmentView com design melhorado
struct ModeSelectionCardView: View {
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
    VStack(alignment: .leading, spacing: 12) {
      // Header
      VStack(alignment: .leading, spacing: 4) {
        Text("Como você quer escolher?")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)

        Text("Selecione o modo que melhor se encaixa no momento")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
      }
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)

      // Mode Cards
      VStack(spacing: 12) {
        ForEach(visibleModes) { mode in
          ModeSelectionCard(
            mode: mode,
            isSelected: selectedMode == mode,
            onTap: {
              withAnimation(modeAnimation) {
                selectedMode = mode
                AppSettingsStorage.searchMode = mode
              }
            }
          )
        }
      }

      // Info contextual para usuário fora de SP
      if !isSaoPaulo {
        nearbyOnlyInfo
      }
    }
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

// MARK: - Preview

#Preview("São Paulo - Ambos os modos") {
  VStack {
    ModeSelectionCardView(selectedMode: .constant(.myList))
  }
  .padding()
  .background(Color(hex: 0xF7F8FA))
}

#Preview("Fora de SP - Apenas Nearby") {
  VStack {
    ModeSelectionCardView(selectedMode: .constant(.nearby))
  }
  .padding()
  .background(Color(hex: 0xF7F8FA))
}
