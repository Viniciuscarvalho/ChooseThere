//
//  LocationOnboardingView.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-17.
//

import SwiftUI

/// Tela de onboarding que educa usuário sobre benefícios de permissão de localização
struct LocationOnboardingView: View {
  @Environment(\.dismiss) private var dismiss

  let locationManager: LocationManager
  let onPermissionGranted: () -> Void
  let onSkip: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      // Ilustração (decorativa)
      Image(systemName: "location.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(AppColors.primary)
        .symbolRenderingMode(.hierarchical)
        .accessibilityHidden(true)

      // Título
      Text("Descubra restaurantes perto de você")
        .font(.title2.weight(.bold))
        .foregroundColor(AppColors.textPrimary)
        .multilineTextAlignment(.center)
        .accessibilityAddTraits(.isHeader)

      // Descrição
      Text("Permitir acesso à localização ajuda a encontrar as melhores opções próximas")
        .font(.body)
        .foregroundColor(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)

      Spacer()

      // Botões
      VStack(spacing: 12) {
        // Botão primário - Solicitar permissão
        Button {
          locationManager.requestPermission()
          // Pequeno delay para o sistema processar
          Task {
            try? await Task.sleep(for: .milliseconds(500))
            locationManager.updateStatus()
            if locationManager.status.isAuthorized {
              AppSettingsStorage.markLocationPermissionGranted()
              onPermissionGranted()
              dismiss()
            }
          }
        } label: {
          Text("Permitir localização")
            .font(.headline)
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel("Permitir acesso à localização")
        .accessibilityHint("Abre a solicitação de permissão do sistema")

        // Botão secundário - Pular
        Button {
          AppSettingsStorage.markLocationOnboardingSkipped()
          onSkip()
          dismiss()
        } label: {
          Text("Agora não")
            .font(.subheadline)
            .foregroundColor(AppColors.textSecondary)
        }
        .accessibilityLabel("Agora não")
        .accessibilityHint("Pula esta etapa e continua sem permissão de localização")
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 32)
    }
    .padding()
    .background(AppColors.background)
    .onAppear {
      AppSettingsStorage.markLocationOnboardingShown()
    }
  }
}

// MARK: - Preview

#Preview {
  LocationOnboardingView(
    locationManager: LocationManager(),
    onPermissionGranted: { print("Permission granted") },
    onSkip: { print("Skipped") }
  )
}
