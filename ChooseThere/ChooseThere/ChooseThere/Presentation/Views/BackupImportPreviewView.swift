//
//  BackupImportPreviewView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import SwiftUI

// MARK: - BackupImportPreviewView

/// View de preview antes de importar o backup
/// Mostra contagens, data, versão e permite escolher modo de importação
struct BackupImportPreviewView: View {
  // MARK: - Properties

  let preview: BackupPreview
  let backup: BackupV1
  let onCancel: () -> Void
  let onConfirm: (BackupImportMode) -> Void

  // MARK: - State

  @State private var selectedMode: BackupImportMode = .mergeByID

  // MARK: - Body

  var body: some View {
    NavigationStack {
      ZStack {
        AppColors.background.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            // Header
            headerSection

            // Informações do backup
            infoSection

            // Contadores
            countersSection

            // Cidades
            if !preview.uniqueCities.isEmpty {
              citiesSection
            }

            // Modo de importação
            importModeSection

            // Botão de confirmar
            confirmButton
          }
          .padding()
        }
      }
      .navigationTitle("Preview do Backup")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancelar") {
            onCancel()
          }
          .foregroundStyle(AppColors.error)
        }
      }
    }
  }

  // MARK: - Header Section

  private var headerSection: some View {
    VStack(spacing: 12) {
      Image(systemName: "doc.badge.arrow.up")
        .font(.system(size: 48))
        .foregroundStyle(AppColors.primary)

      Text("Importar Backup")
        .font(.title2.bold())
        .foregroundStyle(AppColors.textPrimary)

      Text("Revise as informações abaixo antes de continuar")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
    }
    .padding(.top)
  }

  // MARK: - Info Section

  private var infoSection: some View {
    VStack(spacing: 12) {
      infoRow(
        icon: "calendar",
        title: "Data de criação",
        value: formatDate(preview.createdAt)
      )

      if let appVersion = preview.appVersion {
        infoRow(
          icon: "app.badge",
          title: "Versão do app",
          value: appVersion
        )
      }

      infoRow(
        icon: "doc.text",
        title: "Versão do schema",
        value: "v\(preview.schemaVersion)"
      )
    }
    .padding()
    .background(AppColors.surface)
    .cornerRadius(12)
  }

  // MARK: - Counters Section

  private var countersSection: some View {
    VStack(spacing: 16) {
      Text("O que será importado")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack(spacing: 16) {
        counterCard(
          icon: "fork.knife",
          count: preview.restaurantCount,
          label: "Restaurantes"
        )

        counterCard(
          icon: "star.fill",
          count: preview.favoriteCount,
          label: "Favoritos"
        )
      }

      counterCard(
        icon: "clock.arrow.circlepath",
        count: preview.visitCount,
        label: "Visitas/Avaliações",
        fullWidth: true
      )
    }
    .padding()
    .background(AppColors.surface)
    .cornerRadius(12)
  }

  // MARK: - Cities Section

  private var citiesSection: some View {
    VStack(spacing: 12) {
      Text("Cidades no backup")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)

      FlowLayout(spacing: 8) {
        ForEach(preview.uniqueCities, id: \.self) { city in
          Text(city)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.primary.opacity(0.1))
            .foregroundStyle(AppColors.primary)
            .cornerRadius(8)
        }
      }
    }
    .padding()
    .background(AppColors.surface)
    .cornerRadius(12)
  }

  // MARK: - Import Mode Section

  private var importModeSection: some View {
    VStack(spacing: 16) {
      Text("Como importar?")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)

      ForEach(BackupImportMode.allCases, id: \.self) { mode in
        importModeOption(mode)
      }
    }
    .padding()
    .background(AppColors.surface)
    .cornerRadius(12)
  }

  private func importModeOption(_ mode: BackupImportMode) -> some View {
    Button {
      selectedMode = mode
    } label: {
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: selectedMode == mode ? "checkmark.circle.fill" : "circle")
          .font(.title3)
          .foregroundStyle(selectedMode == mode ? AppColors.primary : AppColors.textSecondary)

        VStack(alignment: .leading, spacing: 4) {
          Text(mode.displayName)
            .font(.subheadline.bold())
            .foregroundStyle(AppColors.textPrimary)

          Text(mode.description)
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.leading)
        }

        Spacer()
      }
      .padding()
      .background(
        selectedMode == mode
          ? AppColors.primary.opacity(0.1)
          : AppColors.background
      )
      .cornerRadius(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            selectedMode == mode ? AppColors.primary : AppColors.textSecondary.opacity(0.2),
            lineWidth: selectedMode == mode ? 2 : 1
          )
      )
    }
  }

  // MARK: - Confirm Button

  private var confirmButton: some View {
    Button {
      onConfirm(selectedMode)
    } label: {
      HStack {
        Image(systemName: "arrow.down.doc")
        Text("Confirmar Importação")
      }
      .font(.headline)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding()
      .background(AppColors.primary)
      .cornerRadius(12)
    }
    .padding(.top, 8)
  }

  // MARK: - Helper Views

  private func infoRow(icon: String, title: String, value: String) -> some View {
    HStack {
      Image(systemName: icon)
        .foregroundStyle(AppColors.primary)
        .frame(width: 24)

      Text(title)
        .foregroundStyle(AppColors.textSecondary)

      Spacer()

      Text(value)
        .foregroundStyle(AppColors.textPrimary)
        .fontWeight(.medium)
    }
  }

  private func counterCard(
    icon: String,
    count: Int,
    label: String,
    fullWidth: Bool = false
  ) -> some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(AppColors.accent)

      Text("\(count)")
        .font(.title.bold())
        .foregroundStyle(AppColors.textPrimary)

      Text(label)
        .font(.caption)
        .foregroundStyle(AppColors.textSecondary)
    }
    .frame(maxWidth: fullWidth ? .infinity : nil)
    .padding()
    .background(AppColors.background)
    .cornerRadius(8)
  }

  // MARK: - Helpers

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }
}

// MARK: - Preview

#Preview {
  BackupImportPreviewView(
    preview: BackupPreview(
      from: BackupV1(
        schemaVersion: 1,
        createdAt: Date(),
        appVersion: "1.0.0",
        restaurants: [
          BackupRestaurant(
            id: "1",
            name: "Restaurante 1",
            category: "Japonês",
            address: "Rua 1",
            city: "São Paulo",
            state: "SP",
            tags: [],
            notes: "",
            externalLink: nil,
            lat: 0,
            lng: 0,
            isFavorite: true
          ),
          BackupRestaurant(
            id: "2",
            name: "Restaurante 2",
            category: "Italiano",
            address: "Rua 2",
            city: "Rio de Janeiro",
            state: "RJ",
            tags: [],
            notes: "",
            externalLink: nil,
            lat: 0,
            lng: 0,
            isFavorite: false
          )
        ],
        visits: []
      )
    ),
    backup: BackupV1(
      schemaVersion: 1,
      createdAt: Date(),
      appVersion: "1.0.0",
      restaurants: [],
      visits: []
    ),
    onCancel: {},
    onConfirm: { _ in }
  )
}

