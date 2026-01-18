//
//  NearbyEmptyStateView.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-18.
//

import SwiftUI

/// View de estado vazio/erro melhorada para o modo "Perto de mim".
/// Exibe ícone, título, mensagem e ação principal opcional.
struct NearbyEmptyStateView: View {
  let icon: String
  let title: String
  let message: String
  let primaryAction: (title: String, action: () -> Void)?

  init(
    icon: String,
    title: String,
    message: String,
    primaryAction: (title: String, action: () -> Void)? = nil
  ) {
    self.icon = icon
    self.title = title
    self.message = message
    self.primaryAction = primaryAction
  }

  var body: some View {
    VStack(spacing: 24) {
      // Ícone grande e sutil
      Image(systemName: icon)
        .font(.system(size: 48))
        .foregroundStyle(AppColors.textSecondary.opacity(0.5))
        .accessibilityHidden(true)

      VStack(spacing: 8) {
        Text(title)
          .font(.title3.weight(.semibold))
          .foregroundStyle(AppColors.textPrimary)

        Text(message)
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
          .multilineTextAlignment(.center)
      }

      // Botão de ação principal
      if let action = primaryAction {
        Button(action.title) {
          action.action()
        }
        .buttonStyle(.borderedProminent)
        .tint(AppColors.primary)
        .accessibilityLabel(action.title)
      }
    }
    .padding(32)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title). \(message)")
  }
}

// MARK: - Convenience Initializers

extension NearbyEmptyStateView {
  /// Estado vazio: nenhum resultado encontrado
  static func noResults(
    message: String = "Tente aumentar o raio de busca ou mudar os filtros.",
    action: (() -> Void)? = nil
  ) -> NearbyEmptyStateView {
    NearbyEmptyStateView(
      icon: "magnifyingglass",
      title: "Nenhum restaurante encontrado",
      message: message,
      primaryAction: action.map { ("Tentar novamente", $0) }
    )
  }

  /// Estado de permissão negada
  static func noPermission(
    canRequest: Bool,
    requestAction: @escaping () -> Void,
    openSettingsAction: @escaping () -> Void
  ) -> NearbyEmptyStateView {
    NearbyEmptyStateView(
      icon: "location.slash.fill",
      title: "Localização necessária",
      message: "Para encontrar restaurantes próximos, precisamos de acesso à sua localização.",
      primaryAction: canRequest
        ? ("Permitir localização", requestAction)
        : ("Abrir Configurações", openSettingsAction)
    )
  }

  /// Estado de erro genérico
  static func error(
    message: String,
    retryAction: @escaping () -> Void
  ) -> NearbyEmptyStateView {
    NearbyEmptyStateView(
      icon: "exclamationmark.triangle.fill",
      title: "Ops! Algo deu errado",
      message: message,
      primaryAction: ("Tentar novamente", retryAction)
    )
  }

  /// Estado de erro de rede
  static func networkError(
    retryAction: @escaping () -> Void
  ) -> NearbyEmptyStateView {
    NearbyEmptyStateView(
      icon: "wifi.slash",
      title: "Sem conexão",
      message: "Verifique sua conexão com a internet e tente novamente.",
      primaryAction: ("Tentar novamente", retryAction)
    )
  }

  /// Estado idle: aguardando ação do usuário
  static func idle(
    searchAction: @escaping () -> Void
  ) -> NearbyEmptyStateView {
    NearbyEmptyStateView(
      icon: "location.magnifyingglass",
      title: "Busca por proximidade",
      message: "Encontre restaurantes próximos usando sua localização atual.",
      primaryAction: ("Buscar", searchAction)
    )
  }
}

// MARK: - Preview

#Preview("No Results") {
  NearbyEmptyStateView.noResults(
    message: "Não encontramos restaurantes com os filtros selecionados."
  ) {
    print("Retry tapped")
  }
  .background(AppColors.background)
}

#Preview("No Permission - Can Request") {
  NearbyEmptyStateView.noPermission(
    canRequest: true,
    requestAction: { print("Request permission") },
    openSettingsAction: { print("Open settings") }
  )
  .background(AppColors.background)
}

#Preview("No Permission - Settings") {
  NearbyEmptyStateView.noPermission(
    canRequest: false,
    requestAction: { print("Request permission") },
    openSettingsAction: { print("Open settings") }
  )
  .background(AppColors.background)
}

#Preview("Error") {
  NearbyEmptyStateView.error(
    message: "Erro ao buscar restaurantes. Por favor, tente novamente."
  ) {
    print("Retry tapped")
  }
  .background(AppColors.background)
}

#Preview("Network Error") {
  NearbyEmptyStateView.networkError {
    print("Retry tapped")
  }
  .background(AppColors.background)
}

#Preview("Idle") {
  NearbyEmptyStateView.idle {
    print("Search tapped")
  }
  .background(AppColors.background)
}
