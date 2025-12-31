//
//  ResultView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ResultView: View {
  let restaurantId: String

  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext

  @State private var viewModel: ResultViewModel?
  @State private var cameraPosition: MapCameraPosition = .automatic

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        if vm.isLoading {
          ProgressView()
            .tint(AppColors.primary)
        } else if let error = vm.errorMessage {
          errorView(message: error)
        } else if let restaurant = vm.restaurant {
          contentView(restaurant: restaurant, vm: vm)
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

  @ViewBuilder
  private func contentView(restaurant: Restaurant, vm: ResultViewModel) -> some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        VStack(spacing: 0) {
          // Map Section - 45% of screen height
          mapSection(restaurant: restaurant, vm: vm)
            .frame(height: geometry.size.height * 0.45)

          // Card overlapping the map
          VStack(spacing: 16) {
            restaurantCard(restaurant: restaurant, vm: vm)

            actionButtons(vm: vm)
          }
          .padding(.horizontal, 20)
          .padding(.top, -40)

          Spacer(minLength: 0)
        }
        
        // Botão de voltar
        backButton
          .padding(.top, 16)
          .padding(.leading, 20)
      }
    }
  }
  
  // MARK: - Back Button
  
  private var backButton: some View {
    BackButton(action: { router.popOverlay() }, style: .onMap)
  }

  // MARK: - Map

  private func mapSection(restaurant: Restaurant, vm: ResultViewModel) -> some View {
    let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lng)
    
    return Map(position: $cameraPosition) {
      Annotation(
        restaurant.name,
        coordinate: coordinate
      ) {
        pinView(isFavorite: restaurant.isFavorite)
      }
    }
    .mapStyle(.standard(elevation: .realistic))
    .onAppear {
      // Centralizar no pin usando as coordenadas do restaurante
      let region = MKCoordinateRegion(
        center: coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
      )
      cameraPosition = .region(region)
    }
    .onChange(of: restaurant.lat) { _, _ in
      // Atualizar câmera se coordenadas mudarem (ex: após enriquecimento)
      let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lng),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
      )
      cameraPosition = .region(region)
    }
  }

  private func pinView(isFavorite: Bool) -> some View {
    ZStack {
      Circle()
        .fill(isFavorite ? AppColors.success : AppColors.secondary)
        .frame(width: 44, height: 44)
        .shadow(color: (isFavorite ? AppColors.success : AppColors.secondary).opacity(0.4), radius: 8, y: 4)

      Image(systemName: isFavorite ? "heart.fill" : "fork.knife")
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(.white)
    }
  }

  // MARK: - Restaurant Card

  private func restaurantCard(restaurant: Restaurant, vm: ResultViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(restaurant.name)
            .font(.title3.weight(.bold))
            .foregroundStyle(AppColors.textPrimary)

          Text(restaurant.category.capitalized)
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        Button {
          vm.toggleFavorite()
        } label: {
          Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
            .font(.title2)
            .foregroundStyle(restaurant.isFavorite ? AppColors.secondary : AppColors.textSecondary)
        }
        .accessibilityLabel(restaurant.isFavorite ? "Remover dos favoritos" : "Adicionar aos favoritos")
      }

      Divider()
        .background(AppColors.divider)
      
      // Rating section
      RatingBadge(restaurant: restaurant, style: .full)

      HStack(spacing: 16) {
        Label(restaurant.city, systemImage: "mappin.and.ellipse")
          .font(.footnote)
          .foregroundStyle(AppColors.textSecondary)

        if !restaurant.tags.isEmpty {
          Text(restaurant.tags.prefix(3).joined(separator: ", "))
            .font(.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(1)
        }
      }

      if !restaurant.address.isEmpty {
        Text(restaurant.address)
          .font(.footnote)
          .foregroundStyle(AppColors.textSecondary)
          .lineLimit(2)
      }
    }
    .padding(20)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .shadow(color: Color.black.opacity(0.08), radius: 16, y: 8)
  }

  // MARK: - Action Buttons

  private func actionButtons(vm: ResultViewModel) -> some View {
    VStack(spacing: 12) {
      // Primary: Open in Maps
      Button {
        vm.openInMaps()
      } label: {
        HStack {
          Image(systemName: "map.fill")
          Text("Abrir no Maps")
        }
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
      }

      HStack(spacing: 12) {
        // Rate
        Button {
          router.pushOverlay(.rating(restaurantId: restaurantId))
        } label: {
          HStack {
            Image(systemName: "star.fill")
            Text("Avaliar")
          }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(AppColors.textPrimary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(AppColors.success, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }

        // Draw again
        Button {
          router.replaceOverlay(with: .roulette)
        } label: {
          HStack {
            Image(systemName: "arrow.clockwise")
            Text("Outro")
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
    }
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

      Button {
        router.pop()
      } label: {
        Text("Voltar")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
          .padding(.horizontal, 32)
          .padding(.vertical, 14)
          .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      }
    }
    .padding(20)
  }

  // MARK: - Helpers

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let repo = SwiftDataRestaurantRepository(context: modelContext)
    let vm = ResultViewModel(restaurantId: restaurantId, restaurantRepository: repo)
    vm.load()
    viewModel = vm
  }
}

#Preview {
  ResultView(restaurantId: "izakaya-matsu")
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}
