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
  @State private var isInitializing = true

  var body: some View {
    Group {
      if isInitializing {
        LoadingView()
      } else {
        switch router.mainRoute {
        case .onboarding:
          OnboardingView()
        case .mainTabs:
          MainTabView()
        }
      }
    }
    .onAppear {
      checkInitialRoute()
    }
  }

  private func checkInitialRoute() {
    guard !hasCheckedOnboarding else { return }
    hasCheckedOnboarding = true

    // Inicialização imediata - removido delay desnecessário que travava a app
    withAnimation(.easeOut(duration: 0.2)) {
      isInitializing = false
    }

    // Decide initial route based on onboarding status
    if OnboardingStorage.hasSeenOnboarding {
      router.setMainRoute(.mainTabs)
    } else {
      router.setMainRoute(.onboarding)
    }
  }
}

#Preview {
  RootView()
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}
