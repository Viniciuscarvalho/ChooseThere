import Foundation

/// Rotas de nível superior (controlam qual container principal está ativo)
enum AppRoute: Hashable {
  case onboarding
  case mainTabs
}

/// Rotas empilhadas sobre as tabs (aparecem como overlay)
enum OverlayRoute: Hashable, Identifiable {
  case roulette
  case result(restaurantId: String)
  case rating(restaurantId: String)
  case historyDetail(restaurantId: String, visitId: UUID)
  
  var id: String {
    switch self {
    case .roulette:
      return "roulette"
    case .result(let restaurantId):
      return "result-\(restaurantId)"
    case .rating(let restaurantId):
      return "rating-\(restaurantId)"
    case .historyDetail(let restaurantId, let visitId):
      return "historyDetail-\(restaurantId)-\(visitId)"
    }
  }
}


