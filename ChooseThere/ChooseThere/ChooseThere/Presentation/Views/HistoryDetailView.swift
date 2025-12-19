//
//  HistoryDetailView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import MapKit
import SwiftData
import SwiftUI

struct HistoryDetailView: View {
  let restaurantId: String
  let visitId: UUID

  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext

  @State private var restaurant: Restaurant?
  @State private var visit: Visit?
  @State private var cameraPosition: MapCameraPosition = .automatic
  @State private var isLoading = true
  @State private var isEnrichingLocation = false

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if isLoading {
        ProgressView()
          .tint(AppColors.primary)
      } else if let restaurant = restaurant, let visit = visit {
        contentView(restaurant: restaurant, visit: visit)
      } else {
        errorView
      }
    }
    .onAppear {
      loadData()
    }
  }

  // MARK: - Content

  private func contentView(restaurant: Restaurant, visit: Visit) -> some View {
    VStack(spacing: 0) {
      // Map + ScrollView com ZStack para garantir ordem visual correta
      ZStack(alignment: .top) {
        // Map - reduced height
        VStack(spacing: 0) {
          mapSection(restaurant: restaurant)
            .frame(height: 180)
          Spacer()
        }
        .zIndex(0)
        
        // ScrollView com o conteúdo
        ScrollView {
          VStack(spacing: 16) {
            // Restaurant Card - sobrepõe o mapa
            restaurantCard(restaurant: restaurant)
              .padding(.top, 156) // 180 - 24 para sobrepor o mapa

            // Visit Info
            visitInfoCard(visit: visit)

            // Tags
            if !visit.tags.isEmpty {
              tagsCard(tags: visit.tags)
            }

            // Note
            if let note = visit.note, !note.isEmpty {
              noteCard(note: note)
            }

            Spacer(minLength: 80)
          }
          .padding(.horizontal, 20)
        }
        .zIndex(1)
      }

      actionButtons(restaurant: restaurant)
    }
  }

  // MARK: - Map

  private func mapSection(restaurant: Restaurant) -> some View {
    // Usar coordenadas diretamente do restaurante
    let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lng)
    
    return Map(position: $cameraPosition) {
      Annotation(restaurant.name, coordinate: coordinate) {
        ZStack {
          Circle()
            .fill(restaurant.isFavorite ? AppColors.success : AppColors.secondary)
            .frame(width: 40, height: 40)
            .shadow(color: (restaurant.isFavorite ? AppColors.success : AppColors.secondary).opacity(0.4), radius: 6, y: 3)

          Image(systemName: restaurant.isFavorite ? "heart.fill" : "fork.knife")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
        }
      }
    }
    .mapStyle(.standard(elevation: .realistic))
  }

  // MARK: - Cards

  private func restaurantCard(restaurant: Restaurant) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(restaurant.name)
        .font(.title3.weight(.bold))
        .foregroundStyle(AppColors.textPrimary)
        .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically

      Text(restaurant.category.capitalized)
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)

      if !restaurant.address.isEmpty {
        Label(restaurant.address, systemImage: "mappin.and.ellipse")
          .font(.footnote)
          .foregroundStyle(AppColors.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
  }

  private func visitInfoCard(visit: Visit) -> some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Nota")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)

          HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
              Image(systemName: i <= visit.rating ? "star.fill" : "star")
                .foregroundStyle(i <= visit.rating ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
            }
          }
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text("Data")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)

          Text(visit.dateVisited, style: .date)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppColors.textPrimary)
        }
      }

      Divider()
        .background(AppColors.divider)

      HStack {
        Label(visit.isMatch ? "Match ✓" : "Não foi match", systemImage: visit.isMatch ? "heart.fill" : "heart")
          .font(.subheadline)
          .foregroundStyle(visit.isMatch ? AppColors.success : AppColors.textSecondary)

        Spacer()

        Label(visit.wouldReturn ? "Voltaria" : "Não voltaria", systemImage: visit.wouldReturn ? "arrow.uturn.left" : "xmark")
          .font(.subheadline)
          .foregroundStyle(visit.wouldReturn ? AppColors.accent : AppColors.error)
      }
    }
    .padding(20)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  private func tagsCard(tags: [String]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Tags")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      FlowLayout(spacing: 8) {
        ForEach(tags, id: \.self) { tag in
          Text(tag)
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.background, in: Capsule())
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  private func noteCard(note: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Comentário")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      Text(note)
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  // MARK: - Action Buttons

  private func actionButtons(restaurant: Restaurant) -> some View {
    HStack(spacing: 12) {
      Button {
        router.popOverlay()
      } label: {
        Image(systemName: "chevron.left")
          .font(.headline)
          .foregroundStyle(AppColors.textSecondary)
          .frame(width: 50, height: 50)
          .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .stroke(AppColors.divider, lineWidth: 1)
          )
      }

      Button {
        openInMaps(restaurant: restaurant)
      } label: {
        HStack {
          Image(systemName: "map.fill")
          Text("Abrir rota")
        }
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      }
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 8)
    .background(AppColors.background)
  }

  // MARK: - Error View

  private var errorView: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.largeTitle)
        .foregroundStyle(AppColors.error)

      Text("Visita não encontrada")
        .font(.body)
        .foregroundStyle(AppColors.textSecondary)

      Button {
        router.popOverlay()
      } label: {
        Text("Voltar")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
          .padding(.horizontal, 32)
          .padding(.vertical, 14)
          .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      }
    }
  }

  // MARK: - Helpers

  private func loadData() {
    isLoading = true
    let restRepo = SwiftDataRestaurantRepository(context: modelContext)
    let visitRepo = SwiftDataVisitRepository(context: modelContext)

    do {
      restaurant = try restRepo.fetch(id: restaurantId)
      let visits = try visitRepo.fetchVisits(for: restaurantId)
      visit = visits.first { $0.id == visitId }
      
      // Atualizar a câmera com as coordenadas do restaurante
      updateCameraPosition()
      
      // Enriquecer localização se necessário
      if let r = restaurant, !r.applePlaceResolved {
        Task {
          await enrichLocationIfNeeded(repository: restRepo)
        }
      }
    } catch {
      restaurant = nil
      visit = nil
    }
    isLoading = false
  }
  
  private func updateCameraPosition() {
    if let r = restaurant {
      let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: r.lat, longitude: r.lng),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
      )
      cameraPosition = .region(region)
    }
  }
  
  /// Enriquece a localização do restaurante via Apple Maps se ainda não foi resolvida
  private func enrichLocationIfNeeded(repository: SwiftDataRestaurantRepository) async {
    guard let r = restaurant, !r.applePlaceResolved else { return }
    
    isEnrichingLocation = true
    
    let placeResolver = MapKitPlaceResolver()
    let enrichmentService = RestaurantLocationEnrichmentService(
      placeResolver: placeResolver,
      restaurantRepository: repository
    )
    
    let result = await enrichmentService.resolve(restaurantId: restaurantId)
    
    switch result {
    case .success(_, _, _, _):
      // Recarregar restaurante para obter dados atualizados
      if let updated = try? repository.fetch(id: restaurantId) {
        restaurant = updated
        updateCameraPosition()
      }
      
    case .alreadyResolved, .cacheHit:
      // Recarregar para ter certeza
      if let updated = try? repository.fetch(id: restaurantId) {
        restaurant = updated
        updateCameraPosition()
      }
      
    case .notFound, .failed:
      break
    }
    
    isEnrichingLocation = false
  }

  private func openInMaps(restaurant: Restaurant) {
    let coord = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lng)
    let placemark = MKPlacemark(coordinate: coord)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = restaurant.name
    mapItem.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
  }
}

#Preview {
  HistoryDetailView(restaurantId: "izakaya-matsu", visitId: UUID())
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}

