//
//  RestaurantListView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftUI
import SwiftData

struct RestaurantListView: View {
  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext
  @Environment(\.openURL) private var openURL

  @State private var viewModel: RestaurantListViewModel?
  @State private var showCategoryFilter = false

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        if vm.isLoading {
          ProgressView()
            .tint(AppColors.primary)
        } else if let error = vm.errorMessage {
          errorView(message: error)
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

  private func contentView(vm: RestaurantListViewModel) -> some View {
    VStack(spacing: 0) {
      // Header
      headerSection(vm: vm)

      // Search bar
      searchBar(vm: vm)

      // Category filter chips
      categoryFilter(vm: vm)

      // Restaurant list
      restaurantList(vm: vm)
    }
  }

  // MARK: - Header

  private func headerSection(vm: RestaurantListViewModel) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Restaurantes")
        .font(.title.weight(.bold))
        .foregroundStyle(AppColors.textPrimary)

      Text("\(vm.filteredRestaurants.count) lugares para explorar")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 20)
    .padding(.top, 16)
    .padding(.bottom, 12)
  }

  // MARK: - Search Bar

  private func searchBar(vm: RestaurantListViewModel) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(AppColors.textSecondary)

      TextField("Buscar por nome ou categoria...", text: Binding(
        get: { vm.searchText },
        set: { vm.searchText = $0 }
      ))
      .font(.body)
      .foregroundStyle(AppColors.textPrimary)
      .autocorrectionDisabled()

      if !vm.searchText.isEmpty {
        Button {
          vm.searchText = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 18))
            .foregroundStyle(AppColors.textSecondary)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(AppColors.divider, lineWidth: 1)
    )
    .padding(.horizontal, 20)
    .padding(.bottom, 12)
  }

  // MARK: - Category Filter

  private func categoryFilter(vm: RestaurantListViewModel) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        // "All" chip
        categoryChip(title: "Todos", isSelected: vm.selectedCategory == nil) {
          vm.selectedCategory = nil
        }

        ForEach(vm.categories, id: \.self) { category in
          categoryChip(
            title: formatCategory(category),
            isSelected: vm.selectedCategory == category
          ) {
            vm.selectedCategory = vm.selectedCategory == category ? nil : category
          }
        }
      }
      .padding(.horizontal, 20)
    }
    .padding(.bottom, 16)
  }

  private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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

  // MARK: - Restaurant List

  private func restaurantList(vm: RestaurantListViewModel) -> some View {
    ScrollView {
      LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
        let grouped = vm.groupedByCategory()

        ForEach(grouped, id: \.category) { group in
          Section {
            ForEach(group.restaurants, id: \.id) { restaurant in
              restaurantCard(restaurant: restaurant, vm: vm)
            }
          } header: {
            sectionHeader(title: formatCategory(group.category))
          }
        }
      }
      .padding(.horizontal, 20)
    }
  }
  
  // MARK: - Restaurant Card
  
  private func restaurantCard(restaurant: Restaurant, vm: RestaurantListViewModel) -> some View {
    let linkOpener = ExternalLinkOpener(openURL: openURL)
    
    return RestaurantCard(
      restaurant: restaurant,
      distance: nil, // Distância não disponível na lista "Minha base"
      onTap: {
        router.pushOverlay(.result(restaurantId: restaurant.id))
      },
      onQuickAction: { action in
        handleQuickAction(action, for: restaurant, linkOpener: linkOpener)
      }
    )
  }
  
  // MARK: - Quick Action Handler
  
  private func handleQuickAction(
    _ action: QuickAction,
    for restaurant: Restaurant,
    linkOpener: ExternalLinkOpener
  ) {
    switch action {
    case .tripAdvisor:
      if let url = restaurant.tripAdvisorURL {
        linkOpener.openTripAdvisor(url: url)
      }
    case .iFood:
      if let url = restaurant.iFoodURL {
        linkOpener.openIFood(url: url)
      }
    case .rideOrRoute:
      linkOpener.openRideOrRoute(
        ride99URL: restaurant.ride99URL,
        restaurantName: restaurant.name,
        latitude: restaurant.lat,
        longitude: restaurant.lng
      )
    case .searchTripAdvisor:
      linkOpener.searchTripAdvisor(
        restaurantName: restaurant.name,
        city: restaurant.city
      )
    case .searchIFood:
      linkOpener.searchIFood(
        restaurantName: restaurant.name,
        city: restaurant.city
      )
    }
  }

  // MARK: - Section Header

  private func sectionHeader(title: String) -> some View {
    HStack {
      Text(title)
        .font(.headline.weight(.semibold))
        .foregroundStyle(AppColors.textPrimary)

      Spacer()
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
    .background(AppColors.background)
  }

  // MARK: - Error View

  private func errorView(message: String) -> some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.largeTitle)
        .foregroundStyle(AppColors.error)

      Text(message)
        .font(.body)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
    }
    .padding(20)
  }

  // MARK: - Helpers

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let repo = SwiftDataRestaurantRepository(context: modelContext)
    let vm = RestaurantListViewModel(restaurantRepository: repo)
    vm.loadRestaurants()
    viewModel = vm
  }

  private func formatCategory(_ category: String) -> String {
    // Convert kebab-case to title case
    category
      .replacingOccurrences(of: "-", with: " ")
      .capitalized
  }
}

#Preview {
  RestaurantListView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}

