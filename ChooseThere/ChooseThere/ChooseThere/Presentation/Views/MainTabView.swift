//
//  MainTabView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftData
import SwiftUI

/// Container principal com TabBar para navegação entre as 3 áreas do app
struct MainTabView: View {
  @Environment(AppRouter.self) private var router
  @State private var selectedTab: Tab = .draw

  var body: some View {
    ZStack {
      // Base: conteúdo das tabs + TabBar
      VStack(spacing: 0) {
        // Content based on selected tab
        Group {
          switch selectedTab {
          case .history:
            HistoryView()
          case .draw:
            PreferencesView()
          case .restaurants:
            RestaurantListView()
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // Custom TabBar - sempre visível
        CustomTabBar(selectedTab: $selectedTab)
      }
      .background(AppColors.background)
      
      // Overlay: rotas empilhadas sobre as tabs
      if router.hasOverlay {
        overlayContent
          .transition(.move(edge: .trailing).combined(with: .opacity))
      }
    }
    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.hasOverlay)
    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.currentOverlay?.id)
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .onAppear {
      checkPendingTabSelection()
    }
    .onReceive(NotificationCenter.default.publisher(for: Tab.changeTabNotification)) { notification in
      if let tab = notification.object as? Tab {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          selectedTab = tab
          // Dismiss overlays quando muda de tab
          router.dismissAllOverlays()
        }
      }
    }
  }
  
  // MARK: - Overlay Content
  
  @ViewBuilder
  private var overlayContent: some View {
    if let overlay = router.currentOverlay {
      // Overlays ocupam tela cheia SEM TabBar
      // Isso faz sentido porque são telas de detalhe/foco
      Group {
        switch overlay {
        case .roulette:
          RouletteView()
        case .result(let restaurantId):
          ResultView(restaurantId: restaurantId)
        case .rating(let restaurantId):
          RatingView(restaurantId: restaurantId)
        case .historyDetail(let restaurantId, let visitId):
          HistoryDetailView(restaurantId: restaurantId, visitId: visitId)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(AppColors.background)
    }
  }

  /// Verifica se há uma tab pendente para ser selecionada (ex: após salvar avaliação)
  private func checkPendingTabSelection() {
    let savedTabRawValue = UserDefaults.standard.integer(forKey: "selectedTabOnReturn")
    if let savedTab = Tab(rawValue: savedTabRawValue) {
      selectedTab = savedTab
      // Limpar para não afetar próximas navegações
      UserDefaults.standard.removeObject(forKey: "selectedTabOnReturn")
    }
  }
}

#Preview {
  MainTabView()
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}

