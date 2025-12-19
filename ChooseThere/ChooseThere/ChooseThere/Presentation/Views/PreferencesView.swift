//
//  PreferencesView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext

  @State private var viewModel: PreferencesViewModel?
  @State private var showNoResultsAlert = false
  @State private var enrichmentManager = LocationEnrichmentManager()
  @State private var showToolsSection = false

  private let radiusOptions: [Int?] = [nil, 1, 3, 5, 10]

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        VStack(spacing: 0) {
          ScrollView {
            VStack(alignment: .leading, spacing: 24) {
              headerSection

              desiredTagsSection(vm: vm)

              radiusSection(vm: vm)

              priceTierSection(vm: vm)
              
              ratingPrioritySection(vm: vm)

              avoidTagsSection(vm: vm)
              
              // Seção de ferramentas (colapsável)
              toolsSection

              // Extra space at bottom
              Spacer(minLength: 20)
            }
            .padding(20)
          }

          // Botão de sortear fixo acima da TabBar - só aparece com seleção
          if hasSelection(vm: vm) {
            sortButton(vm: vm)
              .transition(.move(edge: .bottom).combined(with: .opacity))
          }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hasSelection(vm: vm))
      } else {
        ProgressView()
          .tint(AppColors.primary)
      }
    }
    .onAppear {
      initializeViewModel()
    }
  }

  // MARK: - Sections

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Hoje estamos a fim de…")
        .font(.title2.weight(.bold))
        .foregroundStyle(AppColors.textPrimary)

      Text("Selecione tags e ajuste filtros para sortear.")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
    }
  }

  private func desiredTagsSection(vm: PreferencesViewModel) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Categorias / Tags")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      FlowLayout(spacing: 8) {
        ForEach(vm.availableTags, id: \.self) { tag in
          TagChip(
            label: tag,
            isSelected: vm.selectedTags.contains(tag)
          ) {
            vm.toggleTag(tag)
          }
        }
      }
    }
  }

  private func radiusSection(vm: PreferencesViewModel) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Raio")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      HStack(spacing: 8) {
        ForEach(radiusOptions, id: \.self) { option in
          let label = option.map { "\($0)km" } ?? "Todos"
          let isSelected = vm.selectedRadius == option
          Button {
            vm.selectedRadius = option
          } label: {
            Text(label)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(
                isSelected ? AppColors.primary : AppColors.surface,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private func priceTierSection(vm: PreferencesViewModel) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Faixa de Preço")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      HStack(spacing: 8) {
        ForEach([nil] + PriceTier.allCases.map { Optional($0) }, id: \.self) { tier in
          let label = tier?.symbol ?? "Todos"
          let isSelected = vm.selectedPriceTier == tier
          Button {
            vm.selectedPriceTier = tier
          } label: {
            Text(label)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(
                isSelected ? AppColors.primary : AppColors.surface,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }
  
  private func ratingPrioritySection(vm: PreferencesViewModel) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 6) {
        Image(systemName: "star.fill")
          .font(.system(size: 14))
          .foregroundStyle(AppColors.primary)
        
        Text("Bem Avaliados")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
      }

      HStack(spacing: 8) {
        ForEach(RatingPriority.allCases) { priority in
          let isSelected = vm.ratingPriority == priority
          Button {
            vm.ratingPriority = priority
          } label: {
            Text(priority.label)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(
                isSelected ? AppColors.primary : AppColors.surface,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private func avoidTagsSection(vm: PreferencesViewModel) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Evitar")
        .font(.headline)
        .foregroundStyle(AppColors.error)

      FlowLayout(spacing: 8) {
        ForEach(vm.availableTags, id: \.self) { tag in
          TagChip(
            label: tag,
            isSelected: vm.avoidTags.contains(tag)
          ) {
            vm.toggleAvoidTag(tag)
          }
        }
      }
    }
  }
  
  // MARK: - Tools Section
  
  private var toolsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header colapsável
      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
          showToolsSection.toggle()
        }
      } label: {
        HStack {
          Image(systemName: "wrench.and.screwdriver")
            .font(.system(size: 16, weight: .medium))
          
          Text("Ferramentas")
            .font(.headline)
          
          Spacer()
          
          Image(systemName: showToolsSection ? "chevron.up" : "chevron.down")
            .font(.system(size: 14, weight: .medium))
        }
        .foregroundStyle(AppColors.textSecondary)
      }
      .buttonStyle(.plain)
      
      if showToolsSection {
        VStack(spacing: 12) {
          // Botão de enriquecer localizações
          enrichLocationButton
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .padding(16)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
  }
  
  private var enrichLocationButton: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text("Atualizar Localizações")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppColors.textPrimary)
          
          Text(enrichmentManager.statusMessage)
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }
        
        Spacer()
        
        if enrichmentManager.isRunning {
          ProgressView()
            .tint(AppColors.primary)
        } else {
          Button {
            Task {
              await enrichmentManager.startEnrichment()
            }
          } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(.system(size: 18, weight: .medium))
              .foregroundStyle(AppColors.primary)
              .frame(width: 36, height: 36)
              .background(AppColors.primary.opacity(0.1), in: Circle())
          }
          .buttonStyle(.plain)
        }
      }
      
      // Barra de progresso
      if enrichmentManager.isRunning {
        ProgressView(value: enrichmentManager.progress)
          .tint(AppColors.success)
          .animation(.easeInOut, value: enrichmentManager.progress)
      }
      
      // Resultado do último batch
      if let result = enrichmentManager.lastResult, !enrichmentManager.isRunning {
        HStack(spacing: 12) {
          Label("\(result.success)", systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundStyle(AppColors.success)
          
          Label("\(result.failed)", systemImage: "xmark.circle.fill")
            .font(.caption)
            .foregroundStyle(AppColors.error)
          
          Label("\(result.skipped)", systemImage: "arrow.right.circle.fill")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }
      }
    }
  }

  private func sortButton(vm: PreferencesViewModel) -> some View {
    Button {
      vm.resetSession()
      if let restaurantId = vm.draw() {
        // Store picked id for roulette to consume
        UserDefaults.standard.set(restaurantId, forKey: "pendingRestaurantId")
        router.pushOverlay(.roulette)
      } else {
        showNoResultsAlert = true
      }
    } label: {
      HStack {
        Image(systemName: "dice.fill")
        Text("Sortear agora")
      }
      .font(.headline)
      .foregroundStyle(AppColors.textPrimary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 14)
      .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      .shadow(color: AppColors.primary.opacity(0.3), radius: 8, y: 4)
    }
    .padding(.horizontal, 32) // Mesmo padding horizontal da TabBar
    .padding(.vertical, 12)
    .accessibilityLabel("Sortear agora")
    .alert("Nenhum restaurante encontrado", isPresented: $showNoResultsAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Não encontramos restaurantes com os filtros selecionados. Tente ajustar as tags ou remover filtros.")
    }
  }

  // MARK: - Helpers

  /// Verifica se há alguma seleção de tags (desejadas ou evitar)
  private func hasSelection(vm: PreferencesViewModel) -> Bool {
    !vm.selectedTags.isEmpty || !vm.avoidTags.isEmpty
  }

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let repo = SwiftDataRestaurantRepository(context: modelContext)
    let vm = PreferencesViewModel(restaurantRepository: repo)
    vm.loadTags()
    viewModel = vm
    
    // Configurar o manager de enriquecimento
    enrichmentManager.configure(with: repo)
  }
}

#Preview {
  PreferencesView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}
