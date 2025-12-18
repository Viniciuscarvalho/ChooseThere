//
//  RouletteView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftUI
import SwiftData

struct RouletteView: View {
  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext

  @State private var viewModel: RouletteViewModel?
  @State private var cardRotation: Double = 0
  @State private var cardScale: CGFloat = 1
  @State private var previousIndex: Int = -1

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        contentView(vm: vm)
      } else {
        ProgressView()
          .tint(AppColors.primary)
      }
    }
    .onAppear {
      initializeViewModel()
    }
  }

  // MARK: - Content

  @ViewBuilder
  private func contentView(vm: RouletteViewModel) -> some View {
    VStack(spacing: 32) {
      headerSection(phase: vm.phase)

      Spacer()

      cardSection(vm: vm)

      Spacer()

      footerSection(vm: vm)
    }
    .padding(20)
    .onChange(of: vm.currentIndex) { _, newIndex in
      animateCardChange(oldIndex: previousIndex, newIndex: newIndex)
      previousIndex = newIndex
    }
    .onChange(of: vm.phase) { _, newPhase in
      handlePhaseChange(newPhase)
    }
  }

  // MARK: - Sections

  private func headerSection(phase: RouletteViewModel.Phase) -> some View {
    VStack(spacing: 8) {
      switch phase {
      case .idle, .spinning:
        Text("Sorteando…")
          .font(.title.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)

        Text("Preparando o destino perfeito para vocês!")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)

      case .finished:
        Text("E o escolhido é…")
          .font(.title.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)

      case .noResults:
        Text("Ops!")
          .font(.title.weight(.bold))
          .foregroundStyle(AppColors.error)

        Text("Nenhum restaurante encontrado com esses filtros.")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
      }
    }
    .multilineTextAlignment(.center)
  }

  private func cardSection(vm: RouletteViewModel) -> some View {
    ZStack {
      if !vm.displayedNames.isEmpty && vm.currentIndex < vm.displayedNames.count {
        let name = vm.displayedNames[vm.currentIndex]
        rouletteCard(name: name, isFinished: isFinished(vm.phase))
          .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
          )
          .scaleEffect(cardScale)
          .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cardRotation)
          .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cardScale)
      }
    }
    .frame(height: 200)
  }

  private func rouletteCard(name: String, isFinished: Bool) -> some View {
    VStack(spacing: 12) {
      Image(systemName: isFinished ? "checkmark.seal.fill" : "fork.knife")
        .font(.system(size: 40))
        .foregroundStyle(isFinished ? AppColors.success : AppColors.primary)

      Text(name)
        .font(.title2.weight(.semibold))
        .foregroundStyle(AppColors.textPrimary)
        .multilineTextAlignment(.center)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
    .padding(.horizontal, 24)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    .shadow(color: isFinished ? AppColors.success.opacity(0.3) : Color.black.opacity(0.08), radius: isFinished ? 20 : 12, y: 8)
    .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(isFinished ? AppColors.success : AppColors.divider, lineWidth: isFinished ? 3 : 1)
    )
  }

  private func footerSection(vm: RouletteViewModel) -> some View {
    VStack(spacing: 12) {
      if case .finished(let restaurantId) = vm.phase {
        Button {
          router.push(.result(restaurantId: restaurantId))
        } label: {
          HStack {
            Image(systemName: "map.fill")
            Text("Ver no mapa")
          }
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }

        if vm.canReRoll {
          Button {
            vm.reRoll()
          } label: {
            HStack {
              Image(systemName: "arrow.clockwise")
              Text("Sortear de novo (\(vm.maxReRolls - vm.reRollCount) restantes)")
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColors.divider, lineWidth: 1)
            )
          }
        }
      } else if case .noResults = vm.phase {
        Button {
          router.pop()
        } label: {
          HStack {
            Image(systemName: "arrow.left")
            Text("Voltar e ajustar filtros")
          }
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
      }
    }
  }

  // MARK: - Helpers

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let repo = SwiftDataRestaurantRepository(context: modelContext)
    let vm = RouletteViewModel(restaurantRepository: repo)
    let pendingId = UserDefaults.standard.string(forKey: "pendingRestaurantId")
    UserDefaults.standard.removeObject(forKey: "pendingRestaurantId")
    vm.loadAndSpin(pendingId: pendingId)
    viewModel = vm
  }

  private func animateCardChange(oldIndex: Int, newIndex: Int) {
    // Quick flip animation
    withAnimation(.easeOut(duration: 0.08)) {
      cardRotation = 90
      cardScale = 0.9
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
      withAnimation(.easeIn(duration: 0.08)) {
        cardRotation = 0
        cardScale = 1
      }
    }
  }

  private func handlePhaseChange(_ phase: RouletteViewModel.Phase) {
    if case .finished = phase {
      // Celebration animation
      withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
        cardScale = 1.05
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          cardScale = 1.0
        }
      }
    }
  }

  private func isFinished(_ phase: RouletteViewModel.Phase) -> Bool {
    if case .finished = phase { return true }
    return false
  }
}

#Preview {
  RouletteView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}
