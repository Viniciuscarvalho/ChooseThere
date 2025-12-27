//
//  SettingsView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import SwiftUI

// MARK: - SettingsView

/// Tela de Configurações do app
/// Permite alterar cidade, preferências do "Perto de mim" e limpar cache
struct SettingsView: View {
  // MARK: - Environment

  @Environment(\.dismiss) private var dismiss

  // MARK: - State

  @State private var selectedCityKey: String? = AppSettingsStorage.selectedCityKey
  @State private var nearbySource: NearbySource = AppSettingsStorage.nearbySource
  @State private var nearbyRadiusKm: Int = AppSettingsStorage.nearbyRadiusKm
  @State private var showingCitySelection = false
  @State private var showingClearCacheAlert = false
  @State private var cacheCleared = false

  // MARK: - Computed

  private var selectedCityDisplayName: String {
    guard let key = selectedCityKey else {
      return "Qualquer lugar (Perto de mim)"
    }
    let parts = key.split(separator: "|", maxSplits: 1)
    guard parts.count == 2 else { return key }
    return "\(parts[0]), \(parts[1])"
  }

  // MARK: - Body

  var body: some View {
    NavigationStack {
      ZStack {
        AppColors.background.ignoresSafeArea()

        List {
          // Seção: Cidade
          citySection

          // Seção: Perto de mim
          nearbySection

          // Seção: Cache
          cacheSection

          // Seção: Sobre
          aboutSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
      }
      .navigationTitle("Configurações")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Fechar") {
            dismiss()
          }
          .foregroundStyle(AppColors.primary)
        }
      }
      .sheet(isPresented: $showingCitySelection) {
        CitySelectionView(
          onCitySelected: { city in
            selectedCityKey = city.id
            showingCitySelection = false
          },
          isOnboarding: false
        )
      }
      .alert("Limpar Cache", isPresented: $showingClearCacheAlert) {
        Button("Cancelar", role: .cancel) { }
        Button("Limpar", role: .destructive) {
          clearCache()
        }
      } message: {
        Text("Isso removerá todos os resultados salvos do modo \"Perto de mim\". A próxima busca pode ser mais lenta.")
      }
    }
  }

  // MARK: - City Section

  private var citySection: some View {
    Section {
      Button {
        showingCitySelection = true
      } label: {
        HStack {
          Label {
            Text("Cidade")
              .foregroundStyle(AppColors.textPrimary)
          } icon: {
            Image(systemName: "mappin.circle.fill")
              .foregroundStyle(AppColors.accent)
          }

          Spacer()

          Text(selectedCityDisplayName)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(1)

          Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
        }
      }
      .listRowBackground(AppColors.surface)
    } header: {
      Text("Localização")
    } footer: {
      Text("A cidade selecionada é usada para filtrar restaurantes da sua lista.")
    }
  }

  // MARK: - Nearby Section

  private var nearbySection: some View {
    Section {
      // Fonte de dados
      HStack {
        Label {
          Text("Fonte")
            .foregroundStyle(AppColors.textPrimary)
        } icon: {
          Image(systemName: "square.stack.3d.up.fill")
            .foregroundStyle(AppColors.primary)
        }

        Spacer()

        Picker("", selection: $nearbySource) {
          ForEach(NearbySource.allCases) { source in
            Text(source.displayName).tag(source)
          }
        }
        .pickerStyle(.menu)
        .tint(AppColors.primary)
        .onChange(of: nearbySource) { _, newValue in
          AppSettingsStorage.nearbySource = newValue
        }
      }
      .listRowBackground(AppColors.surface)

      // Raio
      HStack {
        Label {
          Text("Raio padrão")
            .foregroundStyle(AppColors.textPrimary)
        } icon: {
          Image(systemName: "circle.dashed")
            .foregroundStyle(AppColors.secondary)
        }

        Spacer()

        Picker("", selection: $nearbyRadiusKm) {
          ForEach(1...10, id: \.self) { km in
            Text("\(km) km").tag(km)
          }
        }
        .pickerStyle(.menu)
        .tint(AppColors.primary)
        .onChange(of: nearbyRadiusKm) { _, newValue in
          AppSettingsStorage.nearbyRadiusKm = newValue
        }
      }
      .listRowBackground(AppColors.surface)
    } header: {
      Text("Perto de mim")
    } footer: {
      Text("Configurações padrão para o modo \"Perto de mim\". Você pode ajustar temporariamente durante a busca.")
    }
  }

  // MARK: - Cache Section

  private var cacheSection: some View {
    Section {
      Button(role: .destructive) {
        showingClearCacheAlert = true
      } label: {
        HStack {
          Label {
            Text("Limpar cache")
              .foregroundStyle(AppColors.error)
          } icon: {
            Image(systemName: "trash")
              .foregroundStyle(AppColors.error)
          }

          Spacer()

          if cacheCleared {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(AppColors.success)
          } else {
            Text("\(NearbyCacheStore.validCount) itens")
              .font(.subheadline)
              .foregroundStyle(AppColors.textSecondary)
          }
        }
      }
      .listRowBackground(AppColors.surface)
    } header: {
      Text("Cache")
    } footer: {
      Text("O cache armazena resultados de buscas recentes para acelerar o carregamento.")
    }
  }

  // MARK: - About Section

  private var aboutSection: some View {
    Section {
      HStack {
        Label {
          Text("Versão")
            .foregroundStyle(AppColors.textPrimary)
        } icon: {
          Image(systemName: "info.circle")
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        Text(appVersion)
          .foregroundStyle(AppColors.textSecondary)
      }
      .listRowBackground(AppColors.surface)
    } header: {
      Text("Sobre")
    }
  }

  // MARK: - Helpers

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }

  private func clearCache() {
    NearbyCacheStore.clear()
    withAnimation {
      cacheCleared = true
    }
    // Reset após alguns segundos
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        cacheCleared = false
      }
    }
  }
}

// MARK: - Preview

#Preview {
  SettingsView()
}

