# Especificação Técnica
## Melhorias na UX do Fluxo "Perto de Mim"

## Resumo Executivo

Esta especificação detalha a implementação técnica das melhorias no fluxo "Perto de mim", focando em quatro áreas principais: (1) visibilidade condicional da aba "Minha Lista" baseada em localização, (2) design unificado de cards com apresentação vertical e agrupamento por distância, (3) indicadores visuais claros de fonte de dados, e (4) fluxo proativo de permissão de localização via onboarding.

A arquitetura proposta mantém a estrutura MVVM existente, introduzindo um novo componente `UnifiedRestaurantCard` que trabalha com protocol `NearbyDisplayable`, e adicionando lógica de agrupamento no `NearbyModeViewModel`. A implementação minimiza mudanças disruptivas ao reutilizar componentes existentes (`LocationManager`, `AppSettingsStorage`) e seguindo os padrões estabelecidos do projeto (Kodeco Swift Style Guide, SwiftUI patterns, `@Observable` ViewModels).

Decisões arquiteturais principais incluem: filtrar modos de busca diretamente no `SearchModeSegmentView` para clareza visual, agrupar resultados em computed properties do ViewModel para testabilidade, e criar um novo `LocationOnboardingView` standalone para flexibilidade de uso.

## Arquitetura do Sistema

### Visão Geral dos Componentes

#### Componentes Modificados

1. **SearchModeSegmentView** - Adiciona lógica de filtragem de tabs baseada em localização
   - Responsabilidade: Exibir apenas tabs relevantes (Minha Lista apenas em SP)
   - Mudança: Filtrar `SearchMode.allCases` usando `AppSettingsStorage.isSaoPauloSelected`
   - Relacionamento: Lê estado de `AppSettingsStorage`, controla `searchMode` binding

2. **PreferencesView** - Atualiza seção de resultados para layout vertical com grupos
   - Responsabilidade: Orquestrar UI de preferências e resultados
   - Mudança: Substituir HScrollView por LazyVStack com headers de seção
   - Relacionamento: Observa `NearbyModeViewModel`, renderiza `UnifiedRestaurantCard`

3. **NearbyModeViewModel** - Adiciona lógica de agrupamento e estados melhorados
   - Responsabilidade: Gerenciar busca, agrupar resultados, prover dados formatados
   - Mudança: Computed property `groupedResults`, enum `DistanceBracket`
   - Relacionamento: Consome `RestaurantRepository` e `AppleMapsNearbySearchService`

#### Componentes Novos

4. **UnifiedRestaurantCard** - Card unificado para Restaurant e NearbyPlace
   - Responsabilidade: Apresentar item com layout consistente, badge de fonte
   - Relacionamento: Consome `NearbyDisplayable` protocol, usado por `PreferencesView`

5. **NearbyDisplayable** - Protocol para unificar Restaurant e NearbyPlace
   - Responsabilidade: Definir interface comum para dados de exibição
   - Relacionamento: Implementado por `Restaurant` e `NearbyPlace` via extensions

6. **DataSourceBadge** - View reutilizável para badge de fonte de dados
   - Responsabilidade: Renderizar badge com cor, ícone, e tooltip
   - Relacionamento: Usado por `UnifiedRestaurantCard`

7. **DistanceGroupHeaderView** - Header de seção para grupos de distância
   - Responsabilidade: Exibir nome do grupo e contagem de restaurantes
   - Relacionamento: Usado por `PreferencesView` para separar seções

8. **LocationOnboardingView** - Tela de onboarding para permissão de localização
   - Responsabilidade: Educar usuário e solicitar permissão de forma contextualizada
   - Relacionamento: Apresentada no primeiro launch, usa `LocationManager`

### Fluxo de Dados

```
AppSettingsStorage.isSaoPauloSelected
  ↓
SearchModeSegmentView (filtra tabs visíveis)
  ↓
PreferencesView (renderiza conteúdo baseado em modo)
  ↓
NearbyModeViewModel.searchNearby()
  ↓
  ├─ effectiveSource == .localBase → RestaurantRepository
  └─ effectiveSource == .appleMaps → AppleMapsNearbySearchService
      ↓
NearbyModeViewModel.groupedResults (agrupa por distância)
  ↓
PreferencesView.LazyVStack (renderiza grupos)
  ↓
  ├─ DistanceGroupHeaderView (header de seção)
  └─ UnifiedRestaurantCard (card de item)
      ↓
      └─ DataSourceBadge (badge de fonte)
```

## Design de Implementação

### Interfaces Principais

#### Protocol NearbyDisplayable

```swift
/// Protocol para unificar Restaurant e NearbyPlace em UI comum
protocol NearbyDisplayable {
  var displayId: String { get }
  var displayName: String { get }
  var displayCategory: String { get }
  var displayImageURL: URL? { get }
  var displayRating: Double? { get }
  var displayAddress: String? { get }
  var distanceKm: Double? { get }
  var dataSource: DataSource { get }
  var externalActions: [QuickAction] { get }
}

enum DataSource {
  case localBase
  case appleMaps

  var displayName: String {
    switch self {
    case .localBase: return "Minha Base"
    case .appleMaps: return "Apple Maps"
    }
  }

  var badgeColor: Color {
    switch self {
    case .localBase: return AppColors.primary.opacity(0.9)
    case .appleMaps: return AppColors.accent.opacity(0.9)
    }
  }

  var badgeIcon: String {
    switch self {
    case .localBase: return "externaldrive.fill"
    case .appleMaps: return "map.fill"
    }
  }

  var tooltipText: String {
    switch self {
    case .localBase:
      return "Minha Base: restaurantes da curadoria local de São Paulo"
    case .appleMaps:
      return "Apple Maps: estabelecimentos do banco de dados Apple Maps"
    }
  }
}
```

#### Enum DistanceBracket

```swift
/// Faixas de distância para agrupamento de resultados
enum DistanceBracket: CaseIterable {
  case veryClose    // < 1km
  case close        // 1-3km
  case medium       // 3-5km
  case far          // > 5km

  var displayName: String {
    switch self {
    case .veryClose: return "Muito perto"
    case .close: return "Perto"
    case .medium: return "Média distância"
    case .far: return "Mais distante"
    }
  }

  var range: ClosedRange<Double> {
    switch self {
    case .veryClose: return 0...0.999
    case .close: return 1...2.999
    case .medium: return 3...4.999
    case .far: return 5...Double.infinity
    }
  }

  func contains(distanceKm: Double) -> Bool {
    range.contains(distanceKm)
  }
}
```

#### Grouping Logic Extension

```swift
extension NearbyModeViewModel {
  /// Agrupa resultados por faixas de distância
  /// Retorna apenas brackets com itens, ordenados por proximidade
  var groupedResults: [DistanceBracket: [any NearbyDisplayable]] {
    let items: [any NearbyDisplayable]

    switch searchState {
    case .localResults(let restaurants):
      items = restaurants.compactMap { $0 as NearbyDisplayable }
    case .appleMapsResults(let places):
      items = places.compactMap { $0 as NearbyDisplayable }
    default:
      return [:]
    }

    var grouped: [DistanceBracket: [any NearbyDisplayable]] = [:]

    for item in items {
      guard let distance = item.distanceKm else { continue }

      for bracket in DistanceBracket.allCases {
        if bracket.contains(distanceKm: distance) {
          grouped[bracket, default: []].append(item)
          break
        }
      }
    }

    // Ordenar itens dentro de cada grupo por rating/alfabético
    for bracket in grouped.keys {
      grouped[bracket]?.sort { item1, item2 in
        if let r1 = item1.displayRating, let r2 = item2.displayRating {
          return r1 > r2 // Maior rating primeiro
        }
        return item1.displayName < item2.displayName // Alfabético se sem rating
      }
    }

    return grouped
  }

  /// Brackets que possuem resultados, ordenados por proximidade
  var visibleBrackets: [DistanceBracket] {
    DistanceBracket.allCases.filter { groupedResults[$0]?.isEmpty == false }
  }
}
```

### Modelos de Dados

#### Restaurant Extension

```swift
extension Restaurant: NearbyDisplayable {
  var displayId: String { id }
  var displayName: String { name }
  var displayCategory: String { category }
  var displayImageURL: URL? {
    guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return nil }
    return URL(string: imageUrl)
  }
  var displayRating: Double? { averageRating }
  var displayAddress: String? { address }
  var dataSource: DataSource { .localBase }
  var externalActions: [QuickAction] {
    var actions: [QuickAction] = []
    if let _ = tripAdvisorLink { actions.append(.tripAdvisor) }
    if let _ = ifoodLink { actions.append(.ifood) }
    if let _ = ride99Link { actions.append(.ride99) }
    actions.append(.maps)
    return actions
  }
}
```

#### NearbyPlace Extension

```swift
extension NearbyPlace: NearbyDisplayable {
  var displayId: String { id.uuidString }
  var displayName: String { name }
  var displayCategory: String { categoryHint ?? "Restaurante" }
  var displayImageURL: URL? { nil }
  var displayRating: Double? { nil }
  var displayAddress: String? { address }
  var dataSource: DataSource { .appleMaps }
  var externalActions: [QuickAction] {
    return [.maps]
  }
}
```

### Component Views

#### UnifiedRestaurantCard

```swift
struct UnifiedRestaurantCard: View {
  let item: any NearbyDisplayable
  let onTap: () -> Void
  let onQuickAction: (QuickAction) -> Void

  var body: some View {
    HStack(spacing: 12) {
      // Imagem ou ícone placeholder
      itemImage
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))

      VStack(alignment: .leading, spacing: 4) {
        // Nome + Badge
        HStack(alignment: .top, spacing: 8) {
          Text(item.displayName)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppColors.textPrimary)
            .lineLimit(2)

          Spacer()

          DataSourceBadge(source: item.dataSource)
        }

        // Categoria
        Text(item.displayCategory)
          .font(.system(size: 13))
          .foregroundColor(AppColors.textTertiary)
          .lineLimit(1)

        // Distância
        if let distance = item.distanceKm {
          Text(formatDistance(distance))
            .font(.system(size: 15))
            .foregroundColor(AppColors.textSecondary)
        }

        // Rating (se disponível)
        if let rating = item.displayRating {
          HStack(spacing: 4) {
            Image(systemName: "star.fill")
              .font(.system(size: 12))
              .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
              .font(.system(size: 13, weight: .medium))
          }
        }

        // Quick actions
        HStack(spacing: 8) {
          ForEach(item.externalActions, id: \.self) { action in
            quickActionButton(action)
          }
        }
      }
    }
    .padding(12)
    .background(AppColors.surface)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColors.divider.opacity(0.5), lineWidth: 1)
    )
    .onTapGesture {
      onTap()
    }
  }

  private func formatDistance(_ km: Double) -> String {
    if km < 1 {
      return String(format: "%.0f m", km * 1000)
    }
    return String(format: "%.1f km", km)
  }
}
```

#### DataSourceBadge

```swift
struct DataSourceBadge: View {
  let source: DataSource
  @State private var showTooltip = false

  var body: some View {
    Button {
      showTooltip.toggle()
    } label: {
      HStack(spacing: 4) {
        Image(systemName: source.badgeIcon)
          .font(.system(size: 9, weight: .medium))
        Text(source.displayName)
          .font(.system(size: 11, weight: .medium))
      }
      .foregroundColor(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(source.badgeColor)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
    .popover(isPresented: $showTooltip) {
      Text(source.tooltipText)
        .font(.caption)
        .padding()
        .presentationCompactAdaptation(.popover)
    }
    .accessibilityLabel("Fonte: \(source.displayName)")
    .accessibilityHint("Toque para mais informações")
  }
}
```

#### DistanceGroupHeaderView

```swift
struct DistanceGroupHeaderView: View {
  let bracket: DistanceBracket
  let count: Int

  var body: some View {
    HStack {
      Text(bracket.displayName)
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(AppColors.textPrimary)

      Circle()
        .fill(AppColors.textTertiary)
        .frame(width: 4, height: 4)

      Text("\(count) \(count == 1 ? "restaurante" : "restaurantes")")
        .font(.system(size: 13))
        .foregroundColor(AppColors.textSecondary)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(AppColors.surface.opacity(0.5))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(bracket.displayName), \(count) restaurantes")
  }
}
```

#### LocationOnboardingView

```swift
struct LocationOnboardingView: View {
  @Environment(\.dismiss) private var dismiss
  let locationManager: LocationManager
  let onPermissionGranted: () -> Void
  let onSkip: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      // Ilustração
      Image(systemName: "location.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(AppColors.primary)
        .symbolRenderingMode(.hierarchical)

      // Título
      Text("Descubra restaurantes perto de você")
        .font(.title2.weight(.bold))
        .foregroundColor(AppColors.textPrimary)
        .multilineTextAlignment(.center)

      // Descrição
      Text("Permitir acesso à localização ajuda a encontrar as melhores opções próximas")
        .font(.body)
        .foregroundColor(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)

      Spacer()

      // Botões
      VStack(spacing: 12) {
        Button {
          Task {
            await locationManager.requestPermission()
            if locationManager.isAuthorized {
              onPermissionGranted()
              dismiss()
            }
          }
        } label: {
          Text("Permitir localização")
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }

        Button {
          onSkip()
          AppSettingsStorage.hasSkippedLocationOnboarding = true
          dismiss()
        } label: {
          Text("Agora não")
            .font(.subheadline)
            .foregroundColor(AppColors.textSecondary)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 32)
    }
    .padding()
  }
}
```

### SearchModeSegmentView Modifications

```swift
struct SearchModeSegmentView: View {
  @Binding var selectedMode: SearchMode

  // Computed property para modos visíveis baseado em localização
  private var visibleModes: [SearchMode] {
    if AppSettingsStorage.isSaoPauloSelected {
      return SearchMode.allCases
    } else {
      return [.nearby] // Apenas "Perto de mim" fora de SP
    }
  }

  var body: some View {
    HStack(spacing: 0) {
      ForEach(visibleModes) { mode in
        // ... resto do código existente
      }
    }
    // ... resto do código existente
    .onChange(of: visibleModes) { oldValue, newValue in
      // Se modo atual não está mais visível, mudar para .nearby
      if !newValue.contains(selectedMode) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
          selectedMode = .nearby
          AppSettingsStorage.searchMode = .nearby
        }
      }
    }
  }
}
```

## Pontos de Integração

### Serviços Externos

#### LocationManager (Existente)
- **Uso**: Permissão e coordenadas do usuário
- **Interface**: Propriedades `isAuthorized`, `currentLocation`
- **Método**: `requestPermission() async`
- **Tratamento de erro**: Verificar `authorizationStatus` antes de usar coordenadas

#### AppleMapsNearbySearchService (Existente)
- **Uso**: Buscar estabelecimentos próximos via MKLocalSearch
- **Interface**: `search(coordinate:radius:category:) async throws -> [NearbyPlace]`
- **Tratamento de erro**: Capturar `MKError`, exibir mensagem contextual, fallback para base local em SP

#### RestaurantRepository (Existente)
- **Uso**: Filtrar restaurantes da base local por distância
- **Interface**: `fetchRestaurants(filters:) async throws -> [Restaurant]`
- **Tratamento de erro**: Capturar erros de parsing/leitura, exibir estado de erro

### AppSettingsStorage

Novas propriedades necessárias:

```swift
extension AppSettingsStorage {
  /// Flag indicando se usuário pulou onboarding de localização
  static var hasSkippedLocationOnboarding: Bool {
    get { UserDefaults.standard.bool(forKey: "hasSkippedLocationOnboarding") }
    set { UserDefaults.standard.set(newValue, forKey: "hasSkippedLocationOnboarding") }
  }

  /// Flag indicando se já exibiu onboarding de localização
  static var hasShownLocationOnboarding: Bool {
    get { UserDefaults.standard.bool(forKey: "hasShownLocationOnboarding") }
    set { UserDefaults.standard.set(newValue, forKey: "hasShownLocationOnboarding") }
  }
}
```

## Abordagem de Testes

### Testes Unitários

#### NearbyModeViewModel Tests

**Componentes a testar**:
- `groupedResults` computed property
- `visibleBrackets` computed property
- Lógica de agrupamento por distância
- Ordenação dentro de grupos (rating vs alfabético)

**Cenários críticos**:
```swift
func testGroupedResults_emptyState_returnsEmptyDictionary()
func testGroupedResults_singleRestaurant_groupsCorrectly()
func testGroupedResults_multipleBrackets_distributesProperly()
func testGroupedResults_sortsByRatingWithinGroup()
func testGroupedResults_sortsByNameWhenNoRating()
func testVisibleBrackets_onlyReturnsNonEmptyBrackets()
func testVisibleBrackets_ordersCorrectly()
```

**Mocks necessários**: Não necessário - usar dados sintéticos (Restaurant/NearbyPlace structs)

#### NearbyDisplayable Protocol Tests

**Componentes a testar**:
- Extension conformances (Restaurant, NearbyPlace)
- Conversões de dados (imageURL, rating, etc)

**Cenários críticos**:
```swift
func testRestaurant_conformsToNearbyDisplayable()
func testNearbyPlace_conformsToNearbyDisplayable()
func testDataSource_correctBadgeColorsAndIcons()
```

#### SearchModeSegmentView Tests

**Componentes a testar**:
- Filtro de modos visíveis baseado em localização
- Mudança automática de modo ao filtrar
- Animações de transição

**Cenários críticos**:
```swift
func testVisibleModes_whenSaoPaulo_showsBothModes()
func testVisibleModes_whenNotSaoPaulo_showsOnlyNearby()
func testModeChange_whenMyListHiddenAndActive_switchesToNearby()
```

**Mocks necessários**: Mock de `AppSettingsStorage.isSaoPauloSelected` via injeção ou testing UserDefaults

### Testes de UI (SwiftUI Previews)

Criar previews para cada componente novo:
- `UnifiedRestaurantCard_Previews` - com Restaurant e NearbyPlace
- `DataSourceBadge_Previews` - ambas fontes
- `DistanceGroupHeaderView_Previews` - diferentes contagens
- `LocationOnboardingView_Previews` - estados de permissão

## Sequenciamento de Desenvolvimento

### Ordem de Construção

#### Fase 1: Foundation (Protocols & Models)
**Componentes**: `NearbyDisplayable`, `DataSource`, `DistanceBracket`, extensions
**Justificativa**: Define interfaces compartilhadas, permite desenvolvimento paralelo posterior
**Tempo estimado**: Pode ser implementado em paralelo após definição de interfaces
**Testes**: Protocol conformance tests

#### Fase 2: ViewModel Enhancement
**Componentes**: `NearbyModeViewModel.groupedResults`, `visibleBrackets`
**Justificativa**: Lógica de negócio deve estar pronta antes de UI
**Dependências**: Fase 1 completa
**Testes**: ViewModel tests com dados sintéticos

#### Fase 3: UI Components (Parallelizable)
**Componentes**: `UnifiedRestaurantCard`, `DataSourceBadge`, `DistanceGroupHeaderView`
**Justificativa**: Componentes visuais independentes podem ser desenvolvidos em paralelo
**Dependências**: Fase 1 completa (protocolo definido)
**Testes**: SwiftUI Previews e snapshot tests

#### Fase 4: SearchModeSegmentView Modification
**Componentes**: Adicionar `visibleModes`, lógica de filtro, onChange handler
**Justificativa**: Modifica componente existente, requer cuidado para não quebrar funcionalidade
**Dependências**: Nenhuma (independente)
**Testes**: SearchModeSegmentView tests

#### Fase 5: PreferencesView Integration
**Componentes**: Substituir HScrollView por LazyVStack, adicionar headers de grupo
**Justificativa**: Integra todos os componentes anteriores
**Dependências**: Fases 2, 3 completas
**Testes**: Integration tests, manual testing

#### Fase 6: Location Onboarding
**Componentes**: `LocationOnboardingView`, lógica de apresentação no app launch
**Justificativa**: Feature independente, pode ser desenvolvida separadamente
**Dependências**: Nenhuma (usa LocationManager existente)
**Testes**: Onboarding flow tests

#### Fase 7: Polish & Animations
**Componentes**: Staggered card animations, fade in/out de tab, transições suaves
**Justificativa**: Refinamento visual após funcionalidade core estar completa
**Dependências**: Fases 1-6 completas
**Testes**: Visual testing, performance profiling

### Dependências Técnicas

**Nenhuma dependência externa bloqueante** - toda implementação usa frameworks iOS nativos:
- SwiftUI para UI
- CoreLocation para localização
- MapKit para Apple Maps search (já integrado)

## Considerações Técnicas

### Decisões Principais

#### 1. Protocol-Based Unified Card vs Type Erasure

**Decisão**: Usar `any NearbyDisplayable` (existential type) ao invés de type erasure manual
**Justificativa**:
- SwiftUI moderna suporta existential types em views
- Código mais simples e legível
- Performance adequada para lista de 15 itens

**Trade-offs considerados**:
- ✅ Simplicidade do código
- ✅ Type safety mantido
- ⚠️ Pequeno overhead de dynamic dispatch (negligível para UI)

**Alternativa rejeitada**: AnyNearbyDisplayable wrapper type
**Por quê**: Adiciona complexidade desnecessária, Swift 5.7+ handle existentials bem

#### 2. Grouping Logic Location

**Decisão**: Computed property no ViewModel (`groupedResults`)
**Justificativa**:
- Testabilidade: fácil testar lógica isoladamente
- Separation of concerns: view não tem lógica de negócio
- Reusabilidade: pode ser usado em múltiplas views se necessário

**Trade-offs considerados**:
- ✅ Testabilidade alta
- ✅ Single responsibility principle
- ⚠️ Recalcula em cada acesso (mitigado por Swift performance e tamanho pequeno de dados)

**Alternativa rejeitada**: Grouping na View
**Por quê**: Dificulta testes, viola MVVM pattern

#### 3. Tab Visibility Implementation

**Decisão**: Filtrar em `SearchModeSegmentView` com computed property `visibleModes`
**Justificativa**:
- Localidade: lógica de UI fica no componente de UI
- Reatividade: muda automaticamente com `AppSettingsStorage.isSaoPauloSelected`
- Simplicidade: não requer mudanças no enum `SearchMode`

**Trade-offs considerados**:
- ✅ Fácil de entender e manter
- ✅ Não polui domain model (SearchMode)
- ⚠️ View tem alguma lógica (aceitável para lógica de apresentação)

**Alternativa rejeitada**: Static computed property em `SearchMode`
**Por quê**: SearchMode é domain model, não deve conhecer AppSettings

#### 4. Onboarding Presentation Strategy

**Decisão**: Standalone `LocationOnboardingView` apresentada no app launch
**Justificativa**:
- Flexibilidade: pode ser re-apresentada se usuário negar permissão
- Testabilidade: view isolada, fácil de testar
- Reusabilidade: pode ser usada em múltiplos contextos (onboarding, settings)

**Trade-offs considerados**:
- ✅ Máxima flexibilidade
- ✅ Não acopla com fluxo de onboarding existente
- ⚠️ Precisa gerenciar quando apresentar (mitigado por AppSettings flags)

### Riscos Conhecidos

#### 1. Performance de LazyVStack com Agrupamento
**Risco**: LazyVStack com múltiplas seções pode ter lag em dispositivos antigos
**Mitigação**:
- Limitar resultados iniciais a 15 (PRD requirement)
- Usar LazyVStack (não VStack) para lazy loading
- Profile em iPhone SE 2nd gen (target mínimo)
- Considerar virtualization se necessário

#### 2. Animação de Fade Tab Durante Navegação
**Risco**: Animação de desaparecimento de tab pode ser brusca ao mudar cidade
**Mitigação**:
- Usar `.onChange(of: visibleModes)` para detectar mudança
- Aplicar `.transition(.opacity)` com duração adequada (0.25s linear)
- Testar em múltiplos cenários de navegação

#### 3. Badge Tooltip em Devices Pequenos
**Risco**: Popover pode não caber bem em iPhones pequenos (SE)
**Mitigação**:
- Usar `.presentationCompactAdaptation(.popover)`
- Texto conciso no tooltip
- Testar em simuladores de devices pequenos

### Requisitos Especiais

#### Performance

1. **Renderização < 100ms** (PRD requirement)
   - Usar `LazyVStack` para lazy loading
   - Evitar computed properties pesadas em view body
   - Cachear `groupedResults` se necessário (via `@State`)

2. **Animações 60 FPS** (PRD requirement)
   - Usar animações nativas SwiftUI (spring, linear)
   - Evitar animações custom complexas
   - Profile com Instruments (Time Profiler, Core Animation)

3. **Busca < 2s em 4G** (PRD requirement)
   - Já atendido por serviços existentes
   - Adicionar timeout de 5s em `AppleMapsNearbySearchService` se não existir

#### Acessibilidade

Todos os novos componentes devem seguir requisitos do PRD:

- **UnifiedRestaurantCard**: VoiceOver labels para nome, categoria, distância, rating, ações
- **DataSourceBadge**: Accessibility label "Fonte: [nome]" e hint "Toque para mais informações"
- **DistanceGroupHeaderView**: Combine children, label descritivo com contagem
- **LocationOnboardingView**: Labels claros em botões, texto legível

Testes de acessibilidade:
- Rodar app com VoiceOver ativado
- Verificar ordem lógica de navegação
- Testar com Dynamic Type (tamanhos de fonte grandes)
- Verificar contraste de cores (mínimo 4.5:1)

### Conformidade com Padrões

#### Kodeco Swift Style Guide

**Aplicações específicas nesta implementação**:

1. **Naming** (Guideline: clarity over brevity)
   - ✅ `NearbyDisplayable` não `NearbyItem` (mais descritivo)
   - ✅ `groupedResults` não `grouped` (contexto claro)
   - ✅ `visibleBrackets` não `brackets` (indica filtro aplicado)

2. **Code Organization** (Guideline: MARK comments, protocol extensions)
   ```swift
   // MARK: - NearbyDisplayable Extension
   extension Restaurant: NearbyDisplayable {
     // ...
   }
   ```

3. **Spacing** (Guideline: 2-space indentation)
   - Configurar Xcode para 2 espaços (já configurado no projeto)

4. **Access Control** (Guideline: private by default)
   - `private var visibleModes` em SearchModeSegmentView
   - `private func formatDistance` em UnifiedRestaurantCard

5. **Computed Properties** (Guideline: omit get for read-only)
   ```swift
   var groupedResults: [DistanceBracket: [any NearbyDisplayable]] {
     // Sem "get {", diretamente implementação
   }
   ```

6. **Optional Binding** (Guideline: shadow original name)
   ```swift
   if let distance = item.distanceKm {
     Text(formatDistance(distance))
   }
   ```

7. **Golden Path** (Guideline: early returns, guard statements)
   ```swift
   func contains(distanceKm: Double) -> Bool {
     range.contains(distanceKm)
   }
   ```

#### SwiftUI Best Practices

1. **View Composition**: Quebrar views grandes em subviews privadas (`imageSection`, `contentSection`)
2. **Environment Objects**: Usar `@Environment` para serviços compartilhados
3. **State Management**: `@State` para estado local, `@Observable` para ViewModels
4. **Animations**: Usar animações nativas (spring, linear) com duração razoável

### Arquivos Relevantes

#### Arquivos a Modificar

1. **SearchModeSegmentView.swift** (`ChooseThere/Presentation/Components/`)
   - Adicionar computed `visibleModes`
   - Adicionar `.onChange(of: visibleModes)` handler

2. **PreferencesView.swift** (`ChooseThere/Presentation/Views/`)
   - Substituir HScrollView por LazyVStack na seção `nearbyContent`
   - Adicionar rendering de headers de grupo
   - Integrar `UnifiedRestaurantCard`

3. **NearbyModeViewModel.swift** (`ChooseThere/Presentation/ViewModels/`)
   - Adicionar `groupedResults` computed property
   - Adicionar `visibleBrackets` computed property

4. **AppSettingsStorage.swift** (`ChooseThere/Data/`)
   - Adicionar `hasSkippedLocationOnboarding` e `hasShownLocationOnboarding`

#### Arquivos a Criar

5. **NearbyDisplayable.swift** (`ChooseThere/Domain/Protocols/`)
   - Protocol definition
   - DataSource enum
   - Extensions for Restaurant e NearbyPlace

6. **DistanceBracket.swift** (`ChooseThere/Domain/Models/`)
   - Enum definition
   - Helper methods

7. **UnifiedRestaurantCard.swift** (`ChooseThere/Presentation/Components/`)
   - SwiftUI view component

8. **DataSourceBadge.swift** (`ChooseThere/Presentation/Components/`)
   - SwiftUI view component

9. **DistanceGroupHeaderView.swift** (`ChooseThere/Presentation/Components/`)
   - SwiftUI view component

10. **LocationOnboardingView.swift** (`ChooseThere/Presentation/Views/`)
    - SwiftUI view component

#### Arquivos de Teste a Criar

11. **NearbyModeViewModelTests.swift** (`ChooseThereTests/Presentation/ViewModels/`)
12. **NearbyDisplayableTests.swift** (`ChooseThereTests/Domain/Protocols/`)
13. **SearchModeSegmentViewTests.swift** (`ChooseThereTests/Presentation/Components/`)

---

**Documento criado em**: 2026-01-17
**Versão**: 1.0
**Baseado em**: PRD v1.0 "Melhorias na UX do Fluxo Perto de Mim"
**Aprovador técnico pendente**: Tech Lead / Arquiteto iOS
