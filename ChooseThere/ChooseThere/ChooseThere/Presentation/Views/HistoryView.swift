//
//  HistoryView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext

  @State private var viewModel: HistoryViewModel?

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        if vm.isLoading {
          ProgressView()
            .tint(AppColors.primary)
        } else if vm.isEmpty {
          emptyState
        } else {
          contentView(vm: vm)
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

  // MARK: - Content

  private func contentView(vm: HistoryViewModel) -> some View {
    VStack(spacing: 0) {
      headerSection(vm: vm)
        .padding(.horizontal, 20)
        .padding(.top, 20)

      filterSection(vm: vm)
        .padding(.top, 16)

      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(vm.filteredVisits) { visit in
            if let restaurant = vm.restaurant(for: visit) {
              visitCard(visit: visit, restaurant: restaurant)
            }
          }
        }
        .padding(20)
      }
    }
  }

  // MARK: - Sections

  private func headerSection(vm: HistoryViewModel) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Histórico")
        .font(.title.weight(.bold))
        .foregroundStyle(AppColors.textPrimary)

      Text("\(vm.visits.count) visita(s) registrada(s)")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func filterSection(vm: HistoryViewModel) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(HistoryViewModel.Filter.allCases, id: \.self) { filter in
          let isSelected = vm.selectedFilter == filter
          Button {
            vm.selectedFilter = filter
          } label: {
            Text(filter.rawValue)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
              .padding(.horizontal, 16)
              .padding(.vertical, 10)
              .background(
                isSelected ? AppColors.primary : AppColors.surface,
                in: Capsule()
              )
              .overlay(
                Capsule()
                  .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 20)
    }
  }

  private func visitCard(visit: Visit, restaurant: Restaurant) -> some View {
    Button {
      router.pushOverlay(.historyDetail(restaurantId: restaurant.id, visitId: visit.id))
    } label: {
      HStack(spacing: 14) {
        // Icon
        ZStack {
          Circle()
            .fill(visit.isMatch ? AppColors.success.opacity(0.15) : AppColors.primary.opacity(0.15))
            .frame(width: 48, height: 48)

          Image(systemName: visit.isMatch ? "heart.fill" : "fork.knife")
            .foregroundStyle(visit.isMatch ? AppColors.success : AppColors.primary)
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(restaurant.name)
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .lineLimit(1)

          HStack(spacing: 6) {
            // Rating stars
            HStack(spacing: 2) {
              ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= visit.rating ? "star.fill" : "star")
                  .font(.caption2)
                  .foregroundStyle(i <= visit.rating ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
              }
            }

            Text("•")
              .foregroundStyle(AppColors.textSecondary)

            Text(visit.dateVisited, style: .date)
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)
          }

          if visit.wouldReturn {
            Text("Voltaria ✓")
              .font(.caption)
              .foregroundStyle(AppColors.accent)
          }
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)
      }
      .padding(16)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
      .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
    .buttonStyle(.plain)
  }

  // MARK: - Empty State

  private var emptyState: some View {
    VStack(spacing: 20) {
      Image(systemName: "fork.knife.circle")
        .font(.system(size: 64))
        .foregroundStyle(AppColors.textSecondary.opacity(0.5))

      Text("Nenhuma visita ainda")
        .font(.title3.weight(.semibold))
        .foregroundStyle(AppColors.textPrimary)

      Text("Sorteie um restaurante e registre sua primeira visita!")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)

      Button {
        // Mudar para a tab de sorteio usando notificação
        Tab.draw.select()
      } label: {
        HStack {
          Image(systemName: "dice.fill")
          Text("Sortear agora")
        }
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 32)
        .padding(.vertical, 14)
        .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      }
    }
  }

  // MARK: - Helpers

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let visitRepo = SwiftDataVisitRepository(context: modelContext)
    let restRepo = SwiftDataRestaurantRepository(context: modelContext)
    let vm = HistoryViewModel(visitRepository: visitRepo, restaurantRepository: restRepo)
    vm.load()
    viewModel = vm
  }
}

#Preview {
  HistoryView()
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}
