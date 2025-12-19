//
//  OnboardingStorage.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import Foundation

/// Gerencia o estado de onboarding do usuário via UserDefaults
enum OnboardingStorage {
  private static let hasSeenOnboardingKey = "hasSeenOnboarding"

  /// Indica se o usuário já viu o onboarding
  static var hasSeenOnboarding: Bool {
    get { UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) }
    set { UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey) }
  }

  /// Marca o onboarding como visto
  static func markAsSeen() {
    hasSeenOnboarding = true
  }

  /// Reseta o estado (útil para testes)
  static func reset() {
    hasSeenOnboarding = false
  }
}



