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

              avoidTagsSection(vm: vm)

              // Extra space for TabBar
              Spacer(minLength: 100)
            }
            .padding(20)
          }

          // Botão de sortear fixo acima da TabBar
          sortButton(vm: vm)
        }
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

  private func sortButton(vm: PreferencesViewModel) -> some View {
    Button {
      vm.resetSession()
      if let restaurantId = vm.draw() {
        // Store picked id for roulette to consume
        UserDefaults.standard.set(restaurantId, forKey: "pendingRestaurantId")
        router.push(.roulette)
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
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 8)
    .background(AppColors.background)
    .accessibilityLabel("Sortear agora")
    .alert("Nenhum restaurante encontrado", isPresented: $showNoResultsAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Não encontramos restaurantes com os filtros selecionados. Tente ajustar as tags ou remover filtros.")
    }
  }

  // MARK: - Helpers

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let repo = SwiftDataRestaurantRepository(context: modelContext)
    let vm = PreferencesViewModel(restaurantRepository: repo)
    vm.loadTags()
    viewModel = vm
  }
}

#Preview {
  PreferencesView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}
