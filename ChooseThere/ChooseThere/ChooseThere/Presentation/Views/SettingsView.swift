//
//  SettingsView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

// MARK: - SettingsView

/// Tela de Configurações do app
/// Permite alterar cidade, preferências do "Perto de mim" e limpar cache
struct SettingsView: View {
  // MARK: - Environment

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  // MARK: - State

  @State private var selectedCityKey: String? = AppSettingsStorage.selectedCityKey
  @State private var nearbySource: NearbySource = AppSettingsStorage.nearbySource
  @State private var nearbyRadiusKm: Int = AppSettingsStorage.nearbyRadiusKm
  @State private var showingCitySelection = false
  @State private var showingClearCacheAlert = false
  @State private var cacheCleared = false

  // Backup export
  @State private var showingPrivacyAlert = false
  @State private var isExporting = false
  @State private var exportError: String?
  @State private var showingExportError = false
  @State private var exportedBackup: BackupV1?
  @State private var showingFileExporter = false

  // Backup import
  @State private var showingFileImporter = false
  @State private var isImporting = false
  @State private var importError: String?
  @State private var showingImportError = false
  @State private var importPreview: BackupPreview?
  @State private var importedBackup: BackupV1?
  @State private var showingImportPreview = false
  @State private var pendingImportMode: BackupImportMode?
  @State private var showingReplaceConfirmation = false
  @State private var importResult: BackupImportResult?
  @State private var showingImportSuccess = false

  // Preference Learning
  @State private var learningEnabled: Bool = AppSettingsStorage.learningEnabled
  @State private var avoidRepeatsLimit: Int = AppSettingsStorage.avoidRepeatsLimit
  @State private var showingResetLearningAlert = false
  @State private var learningReset = false

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
    navigationContent
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
      .alert("Aviso de Privacidade", isPresented: $showingPrivacyAlert) {
        Button("Cancelar", role: .cancel) { }
        Button("Continuar") {
          performExport()
        }
      } message: {
        Text("O backup contém dados pessoais (histórico de visitas, avaliações e notas). Compartilhe apenas com pessoas de confiança.")
      }
      .alert("Erro ao Exportar", isPresented: $showingExportError) {
        Button("OK", role: .cancel) { }
      } message: {
        if let error = exportError {
          Text(error)
        }
      }
      .fileExporter(
        isPresented: $showingFileExporter,
        document: exportedBackup.map { BackupFileDocument(backup: $0) },
        contentType: .json,
        defaultFilename: BackupCodec.defaultFileName
      ) { result in
        switch result {
        case .success:
          break // Sucesso silencioso
        case .failure(let error):
          exportError = error.localizedDescription
          showingExportError = true
        }
      }
      .fileImporter(
        isPresented: $showingFileImporter,
        allowedContentTypes: [.json],
        allowsMultipleSelection: false
      ) { result in
        handleFileImport(result: result)
      }
      .alert("Erro ao Importar", isPresented: $showingImportError) {
        Button("OK", role: .cancel) { }
      } message: {
        if let error = importError {
          Text(error)
        }
      }
      .sheet(isPresented: $showingImportPreview) {
        if let preview = importPreview, let backup = importedBackup {
          BackupImportPreviewView(
            preview: preview,
            backup: backup,
            onCancel: {
              showingImportPreview = false
              importPreview = nil
              importedBackup = nil
            },
            onConfirm: { mode in
              showingImportPreview = false
              handleImportConfirmation(mode: mode)
            }
          )
        }
      }
      .alert("Substituir Tudo?", isPresented: $showingReplaceConfirmation) {
        Button("Cancelar", role: .cancel) {
          pendingImportMode = nil
        }
        Button("Substituir", role: .destructive) {
          if let mode = pendingImportMode {
            performImport(mode: mode)
          }
        }
      } message: {
        Text("Isso apagará TODOS os seus restaurantes e visitas atuais e substituirá pelos dados do backup. Esta ação não pode ser desfeita.")
      }
      .alert("Importação Concluída", isPresented: $showingImportSuccess) {
        Button("OK") {
          importResult = nil
          importPreview = nil
          importedBackup = nil
        }
      } message: {
        if let result = importResult {
          Text(result.summary)
        }
      }
      .alert("Resetar Aprendizado", isPresented: $showingResetLearningAlert) {
        Button("Cancelar", role: .cancel) { }
        Button("Resetar", role: .destructive) {
          resetLearning()
        }
      } message: {
        Text("Isso apagará todos os pesos aprendidos e voltará ao estado inicial. O app começará a aprender novamente a partir das próximas avaliações.")
      }
  }
  
  private var navigationContent: some View {
    NavigationStack {
      ZStack {
        AppColors.background.ignoresSafeArea()
        settingsList
      }
      .navigationTitle("Configurações")
      .navigationBarTitleDisplayMode(.large)
      .toolbarBackground(AppColors.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.light, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Fechar") {
            dismiss()
          }
          .foregroundStyle(AppColors.primary)
        }
      }
    }
  }

  // MARK: - Settings List
  
  private var settingsList: some View {
    List {
      // Seção: Cidade
      citySection

      // Seção: Perto de mim
      nearbySection

      // Seção: Coleção do casal
      backupSection

      // Seção: Preferências que aprendem
      preferenceLearningSection

      // Seção: Cache
      cacheSection

      // Seção: Sobre
      aboutSection
    }
    .listStyle(.insetGrouped)
    .scrollContentBackground(.hidden)
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
        .foregroundStyle(AppColors.textPrimary)
    } footer: {
      Text("A cidade selecionada é usada para filtrar restaurantes da sua lista.")
        .foregroundStyle(AppColors.textSecondary)
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
        .foregroundStyle(AppColors.textPrimary)
    } footer: {
      Text("Configurações padrão para o modo \"Perto de mim\". Você pode ajustar temporariamente durante a busca.")
        .foregroundStyle(AppColors.textSecondary)
    }
  }

  // MARK: - Backup Section

  private var backupSection: some View {
    Section {
      // Exportar backup
      Button {
        showingPrivacyAlert = true
      } label: {
        HStack {
          Label {
            Text("Exportar backup")
              .foregroundStyle(AppColors.textPrimary)
          } icon: {
            Image(systemName: "square.and.arrow.up")
              .foregroundStyle(AppColors.primary)
          }

          Spacer()

          if isExporting {
            ProgressView()
          }
        }
      }
      .disabled(isExporting)
      .listRowBackground(AppColors.surface)

      // Importar backup
      Button {
        showingFileImporter = true
      } label: {
        HStack {
          Label {
            Text("Importar backup")
              .foregroundStyle(AppColors.textPrimary)
          } icon: {
            Image(systemName: "square.and.arrow.down")
              .foregroundStyle(AppColors.secondary)
          }

          Spacer()

          if isImporting {
            ProgressView()
          }
        }
      }
      .disabled(isImporting)
      .listRowBackground(AppColors.surface)
    } header: {
      Text("Coleção do casal")
        .foregroundStyle(AppColors.textPrimary)
    } footer: {
      Text("Exporte sua coleção para compartilhar com outra pessoa, ou importe um backup recebido.")
        .foregroundStyle(AppColors.textSecondary)
    }
  }

  // MARK: - Preference Learning Section

  private var preferenceLearningSection: some View {
    Section {
      // Toggle: Preferências que aprendem
      Toggle(isOn: $learningEnabled) {
        Label {
          Text("Preferências que aprendem")
            .foregroundStyle(AppColors.textPrimary)
        } icon: {
          Image(systemName: "brain.head.profile")
            .foregroundStyle(AppColors.primary)
        }
      }
      .onChange(of: learningEnabled) { _, newValue in
        AppSettingsStorage.learningEnabled = newValue
      }
      .listRowBackground(AppColors.surface)

      // Ajuste do limite de repetições
      if learningEnabled {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Label {
              Text("Evitar repetidos")
                .foregroundStyle(AppColors.textPrimary)
            } icon: {
              Image(systemName: "arrow.counterclockwise")
                .foregroundStyle(AppColors.accent)
            }

            Spacer()

            Text("\(avoidRepeatsLimit) lugares")
              .font(.subheadline)
              .foregroundStyle(AppColors.textSecondary)
          }

          Stepper(
            value: $avoidRepeatsLimit,
            in: 0...50,
            step: 1
          ) {
            Text(avoidRepeatsLimit == 0 ? "Desativado" : "Últimos \(avoidRepeatsLimit) lugares")
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)
          }
          .onChange(of: avoidRepeatsLimit) { _, newValue in
            AppSettingsStorage.avoidRepeatsLimit = newValue
          }
        }
        .padding(.vertical, 4)
        .listRowBackground(AppColors.surface)

        // Botão: Resetar aprendizado
        Button(role: .destructive) {
          showingResetLearningAlert = true
        } label: {
          HStack {
            Label {
              Text("Resetar aprendizado")
                .foregroundStyle(AppColors.error)
            } icon: {
              Image(systemName: "arrow.counterclockwise.circle")
                .foregroundStyle(AppColors.error)
            }

            Spacer()

            if learningReset {
              Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.success)
            }
          }
        }
        .listRowBackground(AppColors.surface)
      }
    } header: {
      Text("Preferências que aprendem")
        .foregroundStyle(AppColors.textPrimary)
    } footer: {
      if learningEnabled {
        Text("O app ajusta suas preferências com base nas suas avaliações. Lugares que você gostou têm maior chance de serem sorteados.")
          .foregroundStyle(AppColors.textSecondary)
      } else {
        Text("Quando desativado, o sorteio funciona de forma aleatória, sem considerar suas avaliações anteriores.")
          .foregroundStyle(AppColors.textSecondary)
      }
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
        .foregroundStyle(AppColors.textPrimary)
    } footer: {
      Text("O cache armazena resultados de buscas recentes para acelerar o carregamento.")
        .foregroundStyle(AppColors.textSecondary)
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
        .foregroundStyle(AppColors.textPrimary)
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

  private func resetLearning() {
    AppSettingsStorage.resetLearningSettings()
    withAnimation {
      learningReset = true
    }
    // Reset após alguns segundos
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        learningReset = false
      }
    }
  }

  private func performExport() {
    isExporting = true
    exportError = nil

    Task {
      do {
        let service = BackupExportService.make(context: modelContext)
        let backup = try await service.generateBackup()

        await MainActor.run {
          exportedBackup = backup
          showingFileExporter = true
          isExporting = false
        }
      } catch {
        await MainActor.run {
          exportError = error.localizedDescription
          showingExportError = true
          isExporting = false
        }
      }
    }
  }

  private func handleFileImport(result: Result<[URL], Error>) {
    isImporting = true
    importError = nil

    Task {
      do {
        guard case .success(let urls) = result, let url = urls.first else {
          if case .failure(let error) = result {
            throw error
          }
          throw NSError(domain: "SettingsView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nenhum arquivo selecionado"])
        }

        // Garantir acesso ao arquivo
        guard url.startAccessingSecurityScopedResource() else {
          throw NSError(domain: "SettingsView", code: -2, userInfo: [NSLocalizedDescriptionKey: "Não foi possível acessar o arquivo"])
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // Ler dados do arquivo
        let data = try Data(contentsOf: url)

        // Validar e gerar preview
        let codec = BackupCodec()
        let backup = try codec.decodeAndValidate(from: data, strict: true)
        let preview = BackupPreview(from: backup)

        await MainActor.run {
          importedBackup = backup
          importPreview = preview
          showingImportPreview = true
          isImporting = false
        }
      } catch let error as BackupValidationError {
        await MainActor.run {
          importError = error.localizedDescription
          showingImportError = true
          isImporting = false
        }
      } catch {
        await MainActor.run {
          importError = "Erro ao importar: \(error.localizedDescription)"
          showingImportError = true
          isImporting = false
        }
      }
    }
  }

  private func handleImportConfirmation(mode: BackupImportMode) {
    if mode == .replaceAll {
      // Modo destrutivo requer confirmação adicional
      pendingImportMode = mode
      showingReplaceConfirmation = true
    } else {
      // Modo merge pode ser executado diretamente
      performImport(mode: mode)
    }
  }

  private func performImport(mode: BackupImportMode) {
    guard let backup = importedBackup else { return }

    isImporting = true
    importError = nil
    pendingImportMode = nil

    Task {
      do {
        let service = BackupImportService.make(context: modelContext)
        let result = try await service.apply(backup, mode: mode)

        await MainActor.run {
          importResult = result
          showingImportSuccess = true
          isImporting = false
        }
      } catch {
        await MainActor.run {
          importError = error.localizedDescription
          showingImportError = true
          isImporting = false
        }
      }
    }
  }
}

// MARK: - Preview

#Preview {
  SettingsView()
}

