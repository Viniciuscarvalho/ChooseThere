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
    ZStack(alignment: .bottom) {
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

      // Custom TabBar
      CustomTabBar(selectedTab: $selectedTab)
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
}

#Preview {
  MainTabView()
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}

