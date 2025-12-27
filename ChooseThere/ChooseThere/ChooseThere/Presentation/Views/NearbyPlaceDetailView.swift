//
//  NearbyPlaceDetailView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/26/25.
//

import MapKit
import SwiftUI

/// View de detalhe mínimo para lugares do Apple Maps (NearbyPlace)
/// Mostra nome, endereço, mapa e ação "Abrir no Maps"
struct NearbyPlaceDetailView: View {
  let place: NearbyPlace

  @Environment(AppRouter.self) private var router
  @State private var cameraPosition: MapCameraPosition = .automatic

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()
      contentView
    }
  }

  // MARK: - Content

  private var contentView: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        VStack(spacing: 0) {
          // Map Section - 45% of screen height
          mapSection
            .frame(height: geometry.size.height * 0.45)

          // Card overlapping the map
          VStack(spacing: 16) {
            placeCard

            actionButtons
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

  private var mapSection: some View {
    let coordinate = place.coordinate

    return Map(position: $cameraPosition) {
      Annotation(place.name, coordinate: coordinate) {
        pinView
      }
    }
    .mapStyle(.standard(elevation: .realistic))
    .onAppear {
      // Centralizar no pin usando as coordenadas do lugar
      let region = MKCoordinateRegion(
        center: coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
      )
      cameraPosition = .region(region)
    }
  }

  private var pinView: some View {
    ZStack {
      Circle()
        .fill(AppColors.accent)
        .frame(width: 44, height: 44)
        .shadow(color: AppColors.accent.opacity(0.4), radius: 8, y: 4)

      Image(systemName: "mappin.circle.fill")
        .font(.system(size: 24, weight: .semibold))
        .foregroundStyle(.white)
    }
  }

  // MARK: - Place Card

  private var placeCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header com nome e badge Apple Maps
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(place.name)
            .font(.title3.weight(.bold))
            .foregroundStyle(AppColors.textPrimary)
            .accessibilityAddTraits(.isHeader)

          if let categoryHint = place.categoryHint {
            Text(categoryHint)
              .font(.subheadline)
              .foregroundStyle(AppColors.textSecondary)
          }
        }

        Spacer()

        // Badge Apple Maps
        appleMapsSourceBadge
          .accessibilityLabel("Resultado do Apple Maps")
      }

      Divider()
        .background(AppColors.divider)
        .accessibilityHidden(true)

      // Endereço
      if let address = place.address, !address.isEmpty {
        HStack(spacing: 8) {
          Image(systemName: "mappin.and.ellipse")
            .font(.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .accessibilityHidden(true)

          Text(address)
            .font(.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .lineLimit(2)
            .accessibilityLabel("Endereço: \(address)")
        }
      }

      // Telefone (se disponível)
      if let phoneNumber = place.phoneNumber, !phoneNumber.isEmpty {
        HStack(spacing: 8) {
          Image(systemName: "phone.fill")
            .font(.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .accessibilityHidden(true)

          Button {
            callPhone(phoneNumber)
          } label: {
            Text(phoneNumber)
              .font(.footnote)
              .foregroundStyle(AppColors.accent)
          }
          .accessibilityLabel("Ligar para \(phoneNumber)")
          .accessibilityHint("Toque duas vezes para fazer uma ligação")
        }
      }
    }
    .padding(20)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .shadow(color: Color.black.opacity(0.08), radius: 16, y: 8)
    .accessibilityElement(children: .contain)
    .accessibilityLabel(placeCardAccessibilityLabel)
  }

  private var placeCardAccessibilityLabel: String {
    var label = place.name
    if let category = place.categoryHint {
      label += ", \(category)"
    }
    if let address = place.address {
      label += ". Endereço: \(address)"
    }
    return label
  }

  private var appleMapsSourceBadge: some View {
    HStack(spacing: 4) {
      Image(systemName: "apple.logo")
        .font(.system(size: 10))
      Text("Maps")
        .font(.caption2.weight(.medium))
    }
    .foregroundStyle(AppColors.textSecondary)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(AppColors.divider.opacity(0.5), in: Capsule())
  }

  // MARK: - Action Buttons

  private var actionButtons: some View {
    VStack(spacing: 12) {
      // Primary: Abrir no Maps
      Button {
        openInMaps()
      } label: {
        HStack {
          Image(systemName: "map.fill")
          Text("Abrir no Maps")
        }
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 52) // Touch target adequado
        .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
      }
      .accessibilityLabel("Abrir no Maps")
      .accessibilityHint("Abre o Apple Maps com direções até \(place.name)")

      HStack(spacing: 12) {
        // Botão para sortear outro
        Button {
          router.popOverlay()
        } label: {
          HStack {
            Image(systemName: "arrow.clockwise")
            Text("Sortear outro")
          }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(AppColors.textSecondary)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 48) // Touch target mínimo HIG
          .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .stroke(AppColors.divider, lineWidth: 1)
          )
        }
        .accessibilityLabel("Sortear outro lugar")
        .accessibilityHint("Volta para a busca e sorteia um novo lugar")

        // Botão Fechar
        Button {
          router.dismissAllOverlays()
        } label: {
          HStack {
            Image(systemName: "xmark")
            Text("Fechar")
          }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(AppColors.textSecondary)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 48) // Touch target mínimo HIG
          .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .stroke(AppColors.divider, lineWidth: 1)
          )
        }
        .accessibilityLabel("Fechar")
        .accessibilityHint("Fecha esta tela e volta para o início")
      }
    }
  }

  // MARK: - Actions

  private func openInMaps() {
    // Tentar usar URL externa se disponível
    if let url = place.externalLink {
      UIApplication.shared.open(url)
      return
    }

    // Fallback: abrir Apple Maps com coordenadas
    let coordinate = place.coordinate
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = place.name

    mapItem.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
  }

  private func callPhone(_ number: String) {
    // Remover caracteres não numéricos
    let cleaned = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    guard let url = URL(string: "tel://\(cleaned)") else { return }
    UIApplication.shared.open(url)
  }
}

#Preview {
  let samplePlace = NearbyPlace.create(
    name: "Restaurante Teste",
    address: "Rua das Flores, 123 - Centro",
    latitude: -23.5505,
    longitude: -46.6333,
    categoryHint: "Restaurante",
    phoneNumber: "(11) 99999-9999"
  )

  return NearbyPlaceDetailView(place: samplePlace)
    .environment(AppRouter())
}

