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

      // Custom TabBar - agora faz parte do VStack, não sobrepõe
      CustomTabBar(selectedTab: $selectedTab)
    }
    .background(AppColors.background)
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .onAppear {
      checkPendingTabSelection()
    }
    .onReceive(NotificationCenter.default.publisher(for: Tab.changeTabNotification)) { notification in
      if let tab = notification.object as? Tab {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          selectedTab = tab
        }
      }
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

