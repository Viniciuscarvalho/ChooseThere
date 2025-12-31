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
  @Environment(\.openURL) private var openURL

  @State private var viewModel: PreferencesViewModel?
  @State private var nearbyViewModel: NearbyModeViewModel?
  @State private var locationManager = LocationManager()
  @State private var showNoResultsAlert = false
  @State private var enrichmentManager = LocationEnrichmentManager()
  @State private var showToolsSection = false
  @State private var showingSettings = false
  @State private var searchMode: SearchMode = AppSettingsStorage.searchMode

  private let radiusOptions: [Int?] = [nil, 1, 3, 5, 10]

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        VStack(spacing: 0) {
          ScrollView {
            VStack(alignment: .leading, spacing: 24) {
              headerSection

              // Segmento Minha Lista | Perto de mim
              searchModeSegment

              // Conteúdo baseado no modo selecionado
              if searchMode == .myList {
                myListContent(vm: vm)
              } else {
                nearbyContent
              }
            }
            .padding(20)
          }

          // Botão de sortear fixo acima da TabBar
          if searchMode == .myList && hasSelection(vm: vm) {
            sortButton(vm: vm)
              .transition(.move(edge: .bottom).combined(with: .opacity))
          } else if searchMode == .nearby {
            nearbyActionButton
              .transition(.move(edge: .bottom).combined(with: .opacity))
          }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hasSelection(vm: vm))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: searchMode)
      } else {
        ProgressView()
          .tint(AppColors.primary)
      }
    }
    .onAppear {
      initializeViewModel()
    }
    .sheet(isPresented: $showingSettings) {
      SettingsView()
    }
  }

  // MARK: - Header & Mode Segment

  private var headerSection: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Hoje estamos a fim de…")
          .font(.title2.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)

        Text("Selecione tags e ajuste filtros para sortear.")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
      }

      Spacer()

      // Botão de Configurações
      Button {
        showingSettings = true
      } label: {
        Image(systemName: "gearshape.fill")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(AppColors.textSecondary)
          .frame(width: 40, height: 40)
          .background(AppColors.surface, in: Circle())
          .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Configurações")
    }
  }

  private var searchModeSegment: some View {
    HStack(spacing: 0) {
      ForEach(SearchMode.allCases) { mode in
        Button {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            searchMode = mode
            AppSettingsStorage.searchMode = mode
          }
        } label: {
          HStack(spacing: 6) {
            Image(systemName: mode.icon)
              .font(.system(size: 14, weight: .medium))
            Text(mode.displayName)
              .font(.subheadline.weight(.semibold))
          }
          .foregroundStyle(searchMode == mode ? AppColors.textPrimary : AppColors.textSecondary)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 44) // Touch target mínimo HIG
          .background(
            searchMode == mode
              ? AppColors.primary
              : Color.clear,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
          )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.displayName)
        .accessibilityHint(searchMode == mode ? "Modo selecionado" : "Toque duas vezes para selecionar")
        .accessibilityAddTraits(searchMode == mode ? .isSelected : [])
      }
    }
    .padding(4)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Modo de busca")
  }

  // MARK: - My List Content

  @ViewBuilder
  private func myListContent(vm: PreferencesViewModel) -> some View {
    desiredTagsSection(vm: vm)
    radiusSection(vm: vm)
    priceTierSection(vm: vm)
    ratingPrioritySection(vm: vm)
    avoidTagsSection(vm: vm)
    toolsSection
    Spacer(minLength: 20)
  }

  // MARK: - Nearby Content

  @ViewBuilder
  private var nearbyContent: some View {
    if let nearbyVM = nearbyViewModel {
      VStack(spacing: 24) {
        // Info sobre cidade selecionada
        cityInfoCard

        // Filtros do Perto de mim
        nearbyFiltersSection(nearbyVM: nearbyVM)

        // Estado da busca
        nearbyStateView(nearbyVM: nearbyVM)

        Spacer(minLength: 20)
      }
    } else {
      ProgressView()
        .tint(AppColors.primary)
    }
  }

  private var cityInfoCard: some View {
    HStack(spacing: 12) {
      Image(systemName: "mappin.circle.fill")
        .font(.system(size: 28))
        .foregroundStyle(AppColors.accent)

      VStack(alignment: .leading, spacing: 2) {
        Text("Buscando em")
          .font(.caption)
          .foregroundStyle(AppColors.textSecondary)

        Text(currentCityDisplayName)
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
      }

      Spacer()

      Button {
        showingSettings = true
      } label: {
        Text("Alterar")
          .font(.subheadline.weight(.medium))
          .foregroundStyle(AppColors.primary)
      }
      .buttonStyle(.plain)
    }
    .padding(16)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
  }

  private func nearbyFiltersSection(nearbyVM: NearbyModeViewModel) -> some View {
    VStack(spacing: 16) {
      // Card: Fonte de dados
      VStack(alignment: .leading, spacing: 12) {
        Text("Fonte de dados")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
          .accessibilityAddTraits(.isHeader)

        HStack(spacing: 8) {
          ForEach(NearbySource.allCases) { source in
            let isSelected = nearbyVM.source == source
            Button {
              nearbyVM.source = source
            } label: {
              HStack(spacing: 6) {
                Image(systemName: source == .localBase ? "externaldrive.fill" : "map.fill")
                  .font(.system(size: 14))
                Text(source.displayName)
                  .font(.subheadline.weight(.medium))
              }
              .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
              .padding(.horizontal, 14)
              .frame(minHeight: 44) // Touch target mínimo HIG
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
            .accessibilityLabel(source.displayName)
            .accessibilityHint(sourceAccessibilityHint(for: source))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
          }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selecionar fonte de dados")
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      .shadow(color: AppColors.divider.opacity(0.3), radius: 2, y: 1)

      // Card: Raio de busca
      VStack(alignment: .leading, spacing: 12) {
        Text("Raio de busca")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)
          .accessibilityAddTraits(.isHeader)

        HStack(spacing: 8) {
          ForEach([1, 3, 5, 10], id: \.self) { km in
            let isSelected = nearbyVM.radiusKm == km
            Button {
              nearbyVM.radiusKm = km
            } label: {
              Text("\(km)km")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                .padding(.horizontal, 14)
                .frame(minHeight: 44) // Touch target mínimo HIG
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
            .accessibilityLabel("\(km) quilômetros")
            .accessibilityHint(isSelected ? "Raio selecionado" : "Toque duas vezes para selecionar este raio")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
          }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selecionar raio de busca")
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      .shadow(color: AppColors.divider.opacity(0.3), radius: 2, y: 1)
    }
    .padding(.horizontal, 20)
  }

  private func sourceAccessibilityHint(for source: NearbySource) -> String {
    switch source {
    case .localBase:
      return "Busca em restaurantes salvos localmente"
    case .appleMaps:
      return "Busca lugares no Apple Maps"
    }
  }

  @ViewBuilder
  private func nearbyStateView(nearbyVM: NearbyModeViewModel) -> some View {
    switch nearbyVM.searchState {
    case .idle:
      nearbyIdleView

    case .loading:
      nearbyLoadingView

    case .noPermission:
      nearbyNoPermissionView(nearbyVM: nearbyVM)

    case .noResults:
      nearbyNoResultsView

    case .error(let message):
      nearbyErrorView(message: message)

    case .localResults(let restaurants):
      nearbyResultsView(restaurants: restaurants, nearbyVM: nearbyVM)

    case .appleMapsResults(let places):
      appleMapsResultsView(places: places, nearbyVM: nearbyVM)
    }
  }

  private var nearbyIdleView: some View {
    StateView.idle(
      title: "Busca por proximidade",
      message: "Toque em \"Buscar\" para encontrar restaurantes próximos usando sua localização atual."
    )
  }

  private var nearbyLoadingView: some View {
    StateView.loading(
      message: nearbyViewModel?.source == .appleMaps
        ? "Buscando no Apple Maps..."
        : "Buscando restaurantes próximos..."
    )
  }

  private func nearbyNoPermissionView(nearbyVM: NearbyModeViewModel) -> some View {
    StateView.noPermission(
      title: "Localização necessária",
      message: "Para encontrar restaurantes próximos, precisamos de acesso à sua localização.",
      canRequest: nearbyVM.canRequestPermission,
      requestAction: {
        Task { @MainActor in
          nearbyVM.requestLocationPermission()
          // Pequeno delay para o sistema processar
          try? await Task.sleep(for: .milliseconds(100))
          // Tentar buscar novamente após solicitar permissão
          await nearbyVM.searchNearby()
        }
      },
      openSettingsAction: { nearbyVM.openSettings() }
    )
  }

  private var nearbyNoResultsView: some View {
    StateView.empty(
      title: "Nenhum restaurante encontrado",
      message: nearbyNoResultsMessage,
      primaryAction: nearbyViewModel?.source == .appleMaps
        ? .init(title: "Tentar Minha base", style: .secondary, action: switchToLocalBase)
        : nil
    )
  }

  private var nearbyNoResultsMessage: String {
    if nearbyViewModel?.source == .appleMaps {
      return "Não encontramos lugares próximos no Apple Maps. Tente aumentar o raio, mudar os filtros ou usar \"Minha base\"."
    }
    return "Tente aumentar o raio de busca ou mudar os filtros."
  }

  private func nearbyErrorView(message: String) -> some View {
    // Detectar se é erro de rede para mostrar fallback
    let isNetworkError = message.lowercased().contains("conexão") ||
                         message.lowercased().contains("rede") ||
                         message.lowercased().contains("internet")

    if isNetworkError && nearbyViewModel?.source == .appleMaps {
      return AnyView(
        StateView.networkError(
          retryAction: {
            Task {
              await nearbyViewModel?.searchNearby()
            }
          },
          switchToLocalAction: switchToLocalBase
        )
      )
    }

    return AnyView(
      StateView.error(
        title: "Ops! Algo deu errado",
        message: message,
        retryAction: .init(title: "Tentar novamente", style: .primary) {
          Task {
            await nearbyViewModel?.searchNearby()
          }
        },
        fallbackAction: nearbyViewModel?.source == .appleMaps
          ? .init(title: "Usar Minha base", style: .secondary, action: switchToLocalBase)
          : nil
      )
    )
  }

  /// Muda para fonte "Minha base" como fallback
  private func switchToLocalBase() {
    nearbyViewModel?.source = .localBase
    Task {
      await nearbyViewModel?.searchNearby()
    }
  }

  private func nearbyResultsView(restaurants: [Restaurant], nearbyVM: NearbyModeViewModel) -> some View {
    let linkOpener = ExternalLinkOpener(openURL: openURL)
    
    return VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("\(restaurants.count) restaurantes encontrados")
          .font(.headline)
          .foregroundStyle(AppColors.textPrimary)

        Spacer()

        Button {
          Task {
            await nearbyVM.searchNearby()
          }
        } label: {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(AppColors.primary)
        }
        .buttonStyle(.plain)
      }

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(restaurants.prefix(10)) { restaurant in
            nearbyRestaurantCardNew(restaurant: restaurant, nearbyVM: nearbyVM, linkOpener: linkOpener)
              .frame(width: 280)
          }
        }
      }
    }
    .padding(16)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
  }

  private func nearbyRestaurantCardNew(
    restaurant: Restaurant,
    nearbyVM: NearbyModeViewModel,
    linkOpener: ExternalLinkOpener
  ) -> some View {
    let distanceKm = nearbyVM.distanceKm(to: restaurant)
    
    return RestaurantCard(
      restaurant: restaurant,
      distance: distanceKm,
      onTap: {
        router.pushOverlay(.result(restaurantId: restaurant.id))
      },
      onQuickAction: { action in
        handleNearbyQuickAction(action, for: restaurant, linkOpener: linkOpener)
      }
    )
  }
  
  private func handleNearbyQuickAction(
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

  // MARK: - Apple Maps Results View

  private func appleMapsResultsView(places: [NearbyPlace], nearbyVM: NearbyModeViewModel) -> some View {
    let linkOpener = ExternalLinkOpener(openURL: openURL)
    
    return VStack(alignment: .leading, spacing: 12) {
      HStack {
        HStack(spacing: 6) {
          Image(systemName: "map.fill")
            .font(.system(size: 14))
            .foregroundStyle(AppColors.accent)

          Text("\(places.count) lugares encontrados")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
        }

        Spacer()

        Button {
          Task {
            await nearbyVM.refreshSearch()
          }
        } label: {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(AppColors.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Atualizar busca")
      }

      // Badge indicando fonte Apple Maps
      HStack(spacing: 4) {
        Image(systemName: "apple.logo")
          .font(.system(size: 10))
        Text("via Apple Maps")
          .font(.caption2)
      }
      .foregroundStyle(AppColors.textSecondary)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(AppColors.divider.opacity(0.5), in: Capsule())

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(places.prefix(15)) { place in
            appleMapsPlaceCardNew(place: place, nearbyVM: nearbyVM, linkOpener: linkOpener)
              .frame(width: 280)
          }
        }
      }
    }
    .padding(16)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
  }

  private func appleMapsPlaceCardNew(
    place: NearbyPlace,
    nearbyVM: NearbyModeViewModel,
    linkOpener: ExternalLinkOpener
  ) -> some View {
    let distanceKm = nearbyVM.distanceKm(to: place)
    
    return NearbyPlaceCard(
      place: place,
      distance: distanceKm,
      onTap: {
        router.pushOverlay(.nearbyPlaceResult(place))
      },
      onRouteAction: {
        linkOpener.openRouteInMaps(
          name: place.name,
          latitude: place.latitude,
          longitude: place.longitude
        )
      }
    )
  }

  private var nearbyActionButton: some View {
    Button {
      guard let nearbyVM = nearbyViewModel else { return }
      nearbyVM.resetSession()
      Task {
        await nearbyVM.searchNearby()
        // Se encontrou resultados, tentar sortear baseado na fonte
        if nearbyVM.source == .localBase {
          if !nearbyVM.nearbyRestaurants.isEmpty {
            if let restaurantId = nearbyVM.draw() {
              UserDefaults.standard.set(restaurantId, forKey: "pendingRestaurantId")
              router.pushOverlay(.roulette)
            }
          }
        } else {
          // Apple Maps: sortear um lugar e ir direto para detalhe
          if !nearbyVM.nearbyPlaces.isEmpty {
            if let place = nearbyVM.drawPlace() {
              // Navegar diretamente para o detalhe do lugar
              router.pushOverlay(.nearbyPlaceResult(place))
            }
          }
        }
      }
    } label: {
      HStack {
        if nearbyViewModel?.searchState.isLoading == true {
          ProgressView()
            .tint(AppColors.textPrimary)
        } else {
          Image(systemName: nearbyViewModel?.source == .appleMaps ? "map.fill" : "location.fill")
        }
        Text(nearbyActionButtonTitle)
      }
      .font(.headline)
      .foregroundStyle(AppColors.textPrimary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 14)
      .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
      .shadow(color: AppColors.accent.opacity(0.3), radius: 8, y: 4)
    }
    .disabled(nearbyViewModel?.searchState.isLoading == true)
    .padding(.horizontal, 32)
    .padding(.vertical, 12)
    .accessibilityLabel(nearbyActionButtonTitle)
    .accessibilityHint(nearbyActionAccessibilityHint)
    .accessibilityAddTraits(.isButton)
  }

  private var nearbyActionAccessibilityHint: String {
    guard let nearbyVM = nearbyViewModel else {
      return "Busca restaurantes próximos à sua localização"
    }
    if nearbyVM.searchState.isLoading {
      return "Busca em andamento, aguarde"
    }
    if nearbyVM.source == .appleMaps {
      return "Toque duas vezes para descobrir novos lugares no Apple Maps"
    }
    return "Toque duas vezes para buscar restaurantes próximos"
  }

  private var nearbyActionButtonTitle: String {
    guard let nearbyVM = nearbyViewModel else {
      return "Buscar perto de mim"
    }
    if nearbyVM.source == .appleMaps {
      return "Descobrir no Apple Maps"
    }
    return "Buscar perto de mim"
  }

  private var currentCityDisplayName: String {
    guard let key = AppSettingsStorage.selectedCityKey else {
      return "Qualquer lugar (Perto de mim)"
    }
    let parts = key.split(separator: "|", maxSplits: 1)
    guard parts.count == 2 else { return key }
    return "\(parts[0]), \(parts[1])"
  }

  // MARK: - My List Sections

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
            .foregroundStyle(enrichmentManager.isCancelling ? AppColors.warning : AppColors.textSecondary)
            .animation(.easeInOut, value: enrichmentManager.statusMessage)
        }
        
        Spacer()
        
        if enrichmentManager.isRunning {
          // Botão de cancelar durante execução
          Button {
            enrichmentManager.cancel()
          } label: {
            if enrichmentManager.isCancelling {
              ProgressView()
                .tint(AppColors.error)
                .frame(width: 36, height: 36)
            } else {
              Image(systemName: "stop.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.error)
                .frame(width: 36, height: 36)
                .background(AppColors.error.opacity(0.1), in: Circle())
            }
          }
          .buttonStyle(.plain)
          .disabled(enrichmentManager.isCancelling)
          .accessibilityLabel("Cancelar atualização")
          .accessibilityHint("Toque para interromper a atualização de localizações")
        } else {
          // Botão de iniciar
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
          .accessibilityLabel("Atualizar localizações")
          .accessibilityHint("Toque para iniciar a atualização de localizações via Apple Maps")
        }
      }
      
      // Barra de progresso
      if enrichmentManager.isRunning {
        ProgressView(value: enrichmentManager.progress)
          .tint(enrichmentManager.isCancelling ? AppColors.warning : AppColors.success)
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
          
          if result.cancelled {
            Label("Cancelado", systemImage: "exclamationmark.circle.fill")
              .font(.caption)
              .foregroundStyle(AppColors.warning)
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
    let visitRepo = SwiftDataVisitRepository(context: modelContext)
    
    // ViewModel para "Minha Lista" com SmartRouletteService (anti-repetição)
    let vm = PreferencesViewModel(restaurantRepository: repo, visitRepository: visitRepo)
    vm.loadTags()
    viewModel = vm
    
    // ViewModel para "Perto de mim"
    let nearbyVM = NearbyModeViewModel(
      locationManager: locationManager,
      restaurantRepository: repo
    )
    nearbyViewModel = nearbyVM
    
    // Configurar o manager de enriquecimento
    enrichmentManager.configure(with: repo)
  }
}

#Preview {
  PreferencesView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}
