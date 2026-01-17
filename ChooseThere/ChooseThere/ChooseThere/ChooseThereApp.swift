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
  @State private var showLocationOnboarding = false
  @State private var locationManager = LocationManager()

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      RestaurantModel.self,
      VisitModel.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      // Se falhar, tentar deletar o banco de dados existente e recriar
      print("⚠️ SwiftData migration failed: \(error)")
      print("🔄 Attempting to delete existing database and recreate...")
      
      // Deletar arquivos do banco de dados
      let fileManager = FileManager.default
      if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        let storeURL = appSupport.appendingPathComponent("default.store")
        let shmURL = appSupport.appendingPathComponent("default.store-shm")
        let walURL = appSupport.appendingPathComponent("default.store-wal")
        
        try? fileManager.removeItem(at: storeURL)
        try? fileManager.removeItem(at: shmURL)
        try? fileManager.removeItem(at: walURL)
        
        print("✅ Deleted existing database files")
      }
      
      // Tentar novamente
      do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
      } catch {
        fatalError("Could not create ModelContainer after reset: \(error)")
      }
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(router)
        .onAppear {
          let context = sharedModelContainer.mainContext
          RestaurantSeeder.seedIfNeeded(context: context)
          checkAndShowLocationOnboarding()
        }
        .sheet(isPresented: $showLocationOnboarding) {
          LocationOnboardingView(
            locationManager: locationManager,
            onPermissionGranted: {
              AppSettingsStorage.markLocationPermissionGranted()
            },
            onSkip: {
              AppSettingsStorage.markLocationOnboardingSkipped()
            }
          )
          .interactiveDismissDisabled()
        }
    }
    .modelContainer(sharedModelContainer)
  }

  // MARK: - Location Onboarding

  /// Verifica se deve mostrar onboarding de localização
  private func checkAndShowLocationOnboarding() {
    // Só mostrar se:
    // 1. Nunca mostrou antes
    // 2. Não tem permissão já concedida
    let shouldShow = !AppSettingsStorage.hasShownLocationOnboarding &&
                     !locationManager.status.isAuthorized

    if shouldShow {
      // Delay pequeno para evitar apresentação no frame inicial
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        showLocationOnboarding = true
      }
    }
  }
}


