//
//  ChooseThereApp.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftData
import SwiftUI

@main
struct ChooseThereApp: App {
  @State private var router = AppRouter()

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      RestaurantModel.self,
      VisitModel.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(router)
        .onAppear {
          let context = sharedModelContainer.mainContext
          RestaurantSeeder.seedIfNeeded(context: context)
        }
    }
    .modelContainer(sharedModelContainer)
  }
}


