import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
  private(set) var stack: [AppRoute] = [.onboarding]

  var current: AppRoute {
    stack.last ?? .onboarding
  }

  func reset(to route: AppRoute) {
    stack = [route]
  }

  func push(_ route: AppRoute) {
    stack.append(route)
  }

  func pop() {
    guard stack.count > 1 else { return }
    stack.removeLast()
  }

  /// Navega para MainTabs e push para uma rota específica
  func navigateFromTabs(to route: AppRoute) {
    stack = [.mainTabs, route]
  }

  /// Volta para MainTabs
  func backToTabs() {
    stack = [.mainTabs]
  }
}


