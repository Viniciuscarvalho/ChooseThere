//
//  CustomTabBar.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftUI

/// Enum representando as abas principais do app
enum Tab: Int, CaseIterable {
  case history = 0
  case draw = 1
  case restaurants = 2

  var icon: String {
    switch self {
    case .history: return "clock.arrow.circlepath"
    case .draw: return "dice.fill"
    case .restaurants: return "list.bullet"
    }
  }

  var title: String {
    switch self {
    case .history: return "Histórico"
    case .draw: return "Escolher"
    case .restaurants: return "Restaurantes"
    }
  }
}

/// TabBar customizada com aba central destacada
struct CustomTabBar: View {
  @Binding var selectedTab: Tab

  var body: some View {
    HStack(spacing: 0) {
      ForEach(Tab.allCases, id: \.rawValue) { tab in
        if tab == .draw {
          // Aba central destacada
          centralTabButton(tab: tab)
        } else {
          // Abas laterais
          regularTabButton(tab: tab)
        }
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 8)
    .padding(.bottom, 4)
    .background(
      AppColors.surface
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: -3)
    )
  }

  // MARK: - Regular Tab

  private func regularTabButton(tab: Tab) -> some View {
    Button {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        selectedTab = tab
      }
    } label: {
      VStack(spacing: 2) {
        Image(systemName: tab.icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(selectedTab == tab ? AppColors.primary : AppColors.textSecondary)

        Text(tab.title)
          .font(.caption2.weight(.medium))
          .foregroundStyle(selectedTab == tab ? AppColors.primary : AppColors.textSecondary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 6)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(tab.title)
    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
  }

  // MARK: - Central Tab (Highlighted)

  private func centralTabButton(tab: Tab) -> some View {
    Button {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        selectedTab = tab
      }
    } label: {
      VStack(spacing: 2) {
        ZStack {
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(AppColors.primary)
            .frame(width: 48, height: 40)
            .shadow(color: AppColors.primary.opacity(0.3), radius: 6, y: 2)

          Image(systemName: tab.icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(AppColors.textPrimary)
        }

        Text(tab.title)
          .font(.caption2.weight(.medium))
          .foregroundStyle(AppColors.primary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 6)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(tab.title)
    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
  }
}

#Preview {
  VStack {
    Spacer()
    CustomTabBar(selectedTab: .constant(.draw))
  }
  .background(AppColors.background)
}

