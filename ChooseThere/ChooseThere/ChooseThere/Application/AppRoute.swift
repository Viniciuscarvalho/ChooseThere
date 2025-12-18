import Foundation

enum AppRoute: Hashable {
  case onboarding
  case mainTabs
  case preferences
  case roulette
  case result(restaurantId: String)
  case rating(restaurantId: String)
  case history
  case historyDetail(restaurantId: String, visitId: UUID)
}


