import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
  // MARK: - State
  
  /// Rota principal (onboarding ou mainTabs)
  private(set) var mainRoute: AppRoute = .onboarding
  
  /// Pilha de rotas empilhadas sobre as tabs
  private(set) var overlayStack: [OverlayRoute] = []
  
  /// Indica se há alguma rota de overlay ativa
  var hasOverlay: Bool {
    !overlayStack.isEmpty
  }
  
  /// Rota de overlay atual (topo da pilha)
  var currentOverlay: OverlayRoute? {
    overlayStack.last
  }
  
  // MARK: - Navigation Actions
  
  /// Define a rota principal (para transições onboarding -> mainTabs)
  func setMainRoute(_ route: AppRoute) {
    mainRoute = route
    // Limpa overlays ao mudar rota principal
    overlayStack.removeAll()
  }
  
  /// Empilha uma rota de overlay sobre as tabs
  func pushOverlay(_ route: OverlayRoute) {
    overlayStack.append(route)
  }
  
  /// Remove a rota de overlay do topo
  func popOverlay() {
    guard !overlayStack.isEmpty else { return }
    overlayStack.removeLast()
  }
  
  /// Remove todas as rotas de overlay (volta para tabs limpas)
  func dismissAllOverlays() {
    overlayStack.removeAll()
  }
  
  /// Substitui a pilha de overlays por uma única rota
  func replaceOverlay(with route: OverlayRoute) {
    overlayStack = [route]
  }
  
  // MARK: - Legacy Compatibility (para facilitar migração)
  
  /// Mantém compatibilidade com código existente que usa push/pop
  func push(_ route: OverlayRoute) {
    pushOverlay(route)
  }
  
  func pop() {
    popOverlay()
  }
  
  /// Volta para MainTabs
  func backToTabs() {
    dismissAllOverlays()
  }
  
  // MARK: - Deprecated (para referência durante migração)
  
  @available(*, deprecated, message: "Use setMainRoute ou pushOverlay")
  func reset(to route: AppRoute) {
    setMainRoute(route)
  }
}


