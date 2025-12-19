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
      LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
        let grouped = vm.groupedByCategory()

        ForEach(grouped, id: \.category) { group in
          Section {
            ForEach(group.restaurants, id: \.id) { restaurant in
              restaurantRow(restaurant: restaurant, vm: vm)
            }
          } header: {
            sectionHeader(title: formatCategory(group.category))
          }
        }
      }
      .padding(.horizontal, 20)
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

  // MARK: - Restaurant Row

  private func restaurantRow(restaurant: Restaurant, vm: RestaurantListViewModel) -> some View {
    Button {
      router.pushOverlay(.result(restaurantId: restaurant.id))
    } label: {
      HStack(spacing: 14) {
        // Category icon
        ZStack {
          Circle()
            .fill(AppColors.primary.opacity(0.15))
            .frame(width: 48, height: 48)

          Image(systemName: categoryIcon(for: restaurant.category))
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(AppColors.primary)
        }

        // Info
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(restaurant.name)
              .font(.body.weight(.semibold))
              .foregroundStyle(AppColors.textPrimary)
              .lineLimit(1)
            
            // Rating badge (se tiver avaliações)
            if restaurant.hasRatings {
              RatingBadge(restaurant: restaurant, style: .compact)
            }
          }

          HStack(spacing: 4) {
            Text(formatCategory(restaurant.category))
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)

            if !restaurant.address.isEmpty {
              Text("•")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)

              Text(restaurant.address)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
            }
          }
        }

        Spacer()

        // Favorite button
        Button {
          vm.toggleFavorite(for: restaurant)
        } label: {
          Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
            .font(.system(size: 20))
            .foregroundStyle(restaurant.isFavorite ? AppColors.secondary : AppColors.textSecondary.opacity(0.5))
        }
        .buttonStyle(.plain)
      }
      .padding(16)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(restaurant.name), \(formatCategory(restaurant.category))\(restaurant.hasRatings ? ", avaliação \(String(format: "%.1f", restaurant.ratingAverage))" : "")")
    .accessibilityHint("Toque para ver detalhes")
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

  private func categoryIcon(for category: String) -> String {
    switch category.lowercased() {
    case "bar": return "wineglass.fill"
    case "brunch": return "cup.and.saucer.fill"
    case "cafe-dessert": return "birthday.cake.fill"
    case "burger": return "takeoutbag.and.cup.and.straw.fill"
    case "brasileira": return "leaf.fill"
    case "japanese": return "fish.fill"
    case "italian": return "fork.knife"
    case "arab-mediterranean": return "sun.max.fill"
    case "contemporary-fine": return "star.fill"
    default: return "fork.knife"
    }
  }
}

#Preview {
  RestaurantListView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}

