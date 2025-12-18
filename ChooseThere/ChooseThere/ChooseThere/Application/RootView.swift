//
//  RootView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftData
import SwiftUI

struct RootView: View {
  @Environment(AppRouter.self) private var router
  @State private var hasCheckedOnboarding = false

  var body: some View {
    Group {
      switch router.current {
      case .onboarding:
        OnboardingView()
      case .mainTabs:
        MainTabView()
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
    .onAppear {
      checkInitialRoute()
    }
  }

  private func checkInitialRoute() {
    guard !hasCheckedOnboarding else { return }
    hasCheckedOnboarding = true

    // Decide initial route based on onboarding status
    if OnboardingStorage.hasSeenOnboarding {
      router.reset(to: .mainTabs)
    } else {
      router.reset(to: .onboarding)
    }
  }
}

#Preview {
  RootView()
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}
