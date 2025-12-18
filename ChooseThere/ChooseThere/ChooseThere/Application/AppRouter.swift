import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
  private(set) var stack: [AppRoute] = [.preferences]

  var current: AppRoute {
    stack.last ?? .preferences
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
}


