//
//  StateView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import SwiftUI

// MARK: - StateType

/// Tipos de estados para exibição em views
enum StateType {
  case idle
  case loading
  case empty
  case noPermission
  case error
  case success
}

// MARK: - StateViewStyle

/// Estilos visuais para StateView
enum StateViewStyle {
  case card       // Com fundo card e bordas arredondadas
  case fullscreen // Centralizado sem fundo extra
}

// MARK: - StateView

/// Componente reutilizável para exibir estados (empty, error, loading, etc.)
/// Segue padrões HIG com ícones SF Symbols e touch targets adequados
struct StateView: View {
  // MARK: - Properties

  let type: StateType
  let icon: String
  let title: String
  let message: String
  var style: StateViewStyle = .card
  var primaryAction: StateAction?
  var secondaryAction: StateAction?

  // MARK: - Action Model

  struct StateAction {
    let title: String
    let style: ActionStyle
    let action: () -> Void

    enum ActionStyle {
      case primary    // Fundo colorido, texto claro
      case secondary  // Borda ou fundo transparente
      case destructive
    }
  }

  // MARK: - Body

  var body: some View {
    Group {
      switch style {
      case .card:
        cardContent
          .padding(20)
          .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      case .fullscreen:
        cardContent
          .padding(20)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityDescription)
  }

  // MARK: - Content

  private var cardContent: some View {
    VStack(spacing: 16) {
      // Ícone
      iconView

      // Título
      Text(title)
        .font(.headline)
        .foregroundStyle(titleColor)
        .multilineTextAlignment(.center)

      // Mensagem
      Text(message)
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)

      // Ações
      if primaryAction != nil || secondaryAction != nil {
        actionButtons
          .padding(.top, 8)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, style == .card ? 24 : 40)
  }

  // MARK: - Icon View

  @ViewBuilder
  private var iconView: some View {
    if type == .loading {
      ProgressView()
        .scaleEffect(1.5)
        .tint(AppColors.accent)
        .frame(width: 48, height: 48)
    } else {
      Image(systemName: icon)
        .font(.system(size: 48, weight: .light))
        .foregroundStyle(iconColor)
    }
  }

  // MARK: - Action Buttons

  private var actionButtons: some View {
    VStack(spacing: 12) {
      if let primary = primaryAction {
        actionButton(for: primary)
      }

      if let secondary = secondaryAction {
        actionButton(for: secondary)
      }
    }
  }

  private func actionButton(for action: StateAction) -> some View {
    Button {
      action.action()
    } label: {
      Text(action.title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(buttonForegroundColor(for: action.style))
        .frame(minWidth: 160)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(buttonBackground(for: action.style))
    }
    .buttonStyle(.plain)
    .frame(minHeight: 44) // Touch target mínimo HIG
    .accessibilityLabel(action.title)
    .accessibilityHint(accessibilityHintForAction(action))
  }

  // MARK: - Colors & Styling

  private var iconColor: Color {
    switch type {
    case .idle:
      return AppColors.textSecondary.opacity(0.5)
    case .loading:
      return AppColors.accent
    case .empty:
      return AppColors.textSecondary.opacity(0.5)
    case .noPermission:
      return AppColors.error.opacity(0.7)
    case .error:
      return AppColors.error.opacity(0.7)
    case .success:
      return AppColors.success
    }
  }

  private var titleColor: Color {
    switch type {
    case .error, .noPermission:
      return AppColors.textPrimary
    default:
      return AppColors.textPrimary
    }
  }

  private func buttonForegroundColor(for style: StateAction.ActionStyle) -> Color {
    switch style {
    case .primary:
      // Botão primary com fundo accent (mint) deve ter texto claro para contraste
      return AppColors.surface
    case .secondary:
      return AppColors.accent
    case .destructive:
      return AppColors.error
    }
  }

  @ViewBuilder
  private func buttonBackground(for style: StateAction.ActionStyle) -> some View {
    switch style {
    case .primary:
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(AppColors.accent)
    case .secondary:
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(AppColors.accent.opacity(0.15))
    case .destructive:
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(AppColors.error.opacity(0.15))
    }
  }

  // MARK: - Accessibility

  private var accessibilityDescription: String {
    var description = "\(title). \(message)"
    if let primary = primaryAction {
      description += " Ação disponível: \(primary.title)."
    }
    if let secondary = secondaryAction {
      description += " Alternativa: \(secondary.title)."
    }
    return description
  }

  private func accessibilityHintForAction(_ action: StateAction) -> String {
    switch action.style {
    case .primary:
      return "Toque duas vezes para executar a ação principal"
    case .secondary:
      return "Toque duas vezes para executar ação alternativa"
    case .destructive:
      return "Toque duas vezes para executar ação destrutiva"
    }
  }
}

// MARK: - Convenience Initializers

extension StateView {
  /// Estado de busca vazia (idle)
  static func idle(
    title: String = "Busca por proximidade",
    message: String = "Toque em \"Buscar\" para encontrar restaurantes próximos.",
    primaryAction: StateAction? = nil
  ) -> StateView {
    StateView(
      type: .idle,
      icon: "location.magnifyingglass",
      title: title,
      message: message,
      primaryAction: primaryAction
    )
  }

  /// Estado de carregamento
  static func loading(
    message: String = "Buscando restaurantes próximos..."
  ) -> StateView {
    StateView(
      type: .loading,
      icon: "",
      title: "",
      message: message
    )
  }

  /// Estado vazio (sem resultados)
  static func empty(
    title: String = "Nenhum resultado encontrado",
    message: String = "Tente aumentar o raio de busca ou mudar os filtros.",
    primaryAction: StateAction? = nil,
    secondaryAction: StateAction? = nil
  ) -> StateView {
    StateView(
      type: .empty,
      icon: "mappin.slash",
      title: title,
      message: message,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction
    )
  }

  /// Estado de permissão negada
  static func noPermission(
    title: String = "Localização necessária",
    message: String = "Para encontrar restaurantes próximos, precisamos de acesso à sua localização.",
    canRequest: Bool,
    requestAction: @escaping () -> Void,
    openSettingsAction: @escaping () -> Void
  ) -> StateView {
    StateView(
      type: .noPermission,
      icon: "location.slash.fill",
      title: title,
      message: canRequest
        ? "Toque para permitir o acesso à sua localização."
        : "A permissão foi negada anteriormente. Você pode ativá-la nos Ajustes do iOS.",
      primaryAction: canRequest
        ? StateAction(title: "Permitir acesso", style: .primary, action: requestAction)
        : StateAction(title: "Abrir Ajustes", style: .secondary, action: openSettingsAction)
    )
  }

  /// Estado de erro genérico
  static func error(
    title: String = "Ops! Algo deu errado",
    message: String,
    retryAction: StateAction? = nil,
    fallbackAction: StateAction? = nil
  ) -> StateView {
    StateView(
      type: .error,
      icon: "exclamationmark.triangle.fill",
      title: title,
      message: message,
      primaryAction: retryAction,
      secondaryAction: fallbackAction
    )
  }

  /// Estado de erro de rede (específico para Apple Maps)
  static func networkError(
    retryAction: @escaping () -> Void,
    switchToLocalAction: @escaping () -> Void
  ) -> StateView {
    StateView(
      type: .error,
      icon: "wifi.slash",
      title: "Sem conexão",
      message: "Não foi possível buscar no Apple Maps. Verifique sua conexão ou use \"Minha base\" para buscar localmente.",
      primaryAction: StateAction(title: "Tentar novamente", style: .primary, action: retryAction),
      secondaryAction: StateAction(title: "Usar Minha base", style: .secondary, action: switchToLocalAction)
    )
  }
}

// MARK: - Preview

#Preview("Idle") {
  StateView.idle()
    .padding()
}

#Preview("Loading") {
  StateView.loading()
    .padding()
}

#Preview("Empty") {
  StateView.empty(
    primaryAction: .init(title: "Aumentar raio", style: .primary, action: {}),
    secondaryAction: .init(title: "Mudar filtros", style: .secondary, action: {})
  )
  .padding()
}

#Preview("No Permission - Can Request") {
  StateView.noPermission(
    canRequest: true,
    requestAction: {},
    openSettingsAction: {}
  )
  .padding()
}

#Preview("No Permission - Denied") {
  StateView.noPermission(
    canRequest: false,
    requestAction: {},
    openSettingsAction: {}
  )
  .padding()
}

#Preview("Error") {
  StateView.error(
    message: "Não foi possível completar a busca.",
    retryAction: .init(title: "Tentar novamente", style: .primary, action: {})
  )
  .padding()
}

#Preview("Network Error") {
  StateView.networkError(
    retryAction: {},
    switchToLocalAction: {}
  )
  .padding()
}

