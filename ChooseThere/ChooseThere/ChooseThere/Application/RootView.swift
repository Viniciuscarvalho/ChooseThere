import SwiftUI

struct RootView: View {
  @Environment(AppRouter.self) private var router

  var body: some View {
    switch router.current {
    case .onboarding:
      OnboardingView()
    case .preferences:
      PreferencesView()
    case .roulette:
      RouletteView()
    case .result(let restaurantId):
      ResultView(restaurantId: restaurantId)
    case .rating(let restaurantId):
      RatingView(restaurantId: restaurantId)
    case .history:
      HistoryView()
    case .historyDetail(let restaurantId, let visitId):
      HistoryDetailView(restaurantId: restaurantId, visitId: visitId)
    }
  }
}


