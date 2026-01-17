# [9.0] Update PreferencesView with Vertical List Layout (L)

## Objetivo
- Substituir scroll horizontal de cards por lista vertical com LazyVStack
- Integrar agrupamento por distância com headers de seção
- Usar `UnifiedRestaurantCard` para renderizar todos os items
- Implementar limite de 15 resultados iniciais com opção "Ver mais"
- Adicionar estados de loading, empty, e error apropriados
- Garantir performance adequada (< 100ms renderização)

## Subtarefas
- [ ] 9.1 Abrir arquivo `PreferencesView.swift`
- [ ] 9.2 Localizar seção de resultados (nearbyContent ou similar)
- [ ] 9.3 Substituir HScrollView/ScrollView por LazyVStack
- [ ] 9.4 Implementar loop sobre `viewModel.visibleBrackets`
- [ ] 9.5 Para cada bracket, renderizar `DistanceGroupHeaderView`
- [ ] 9.6 Para cada item no bracket, renderizar `UnifiedRestaurantCard`
- [ ] 9.7 Implementar limite de 15 items com state para "Ver mais"
- [ ] 9.8 Adicionar espaçamento entre cards (12pt)
- [ ] 9.9 Adicionar padding horizontal (16pt)
- [ ] 9.10 Implementar handlers: onTap (navegar para detalhe), onQuickAction (abrir links)
- [ ] 9.11 Testar com dados reais de Restaurant e NearbyPlace
- [ ] 9.12 Validar performance em dispositivo real

## Critérios de Sucesso
- Lista vertical renderiza corretamente com grupos de distância
- Headers aparecem antes de cada grupo
- Cards usam largura total com padding correto
- Máximo 15 items exibidos inicialmente
- Botão "Ver mais" aparece quando há mais de 15 resultados
- Tap em card navega para tela de detalhe apropriada
- Quick actions abrem URLs corretas (TripAdvisor, iFood, Maps, etc)
- Performance < 100ms para renderizar 15 items
- Estados de loading/empty/error são exibidos adequadamente
- Scroll é suave em 60 FPS
- Layout se adapta a diferentes tamanhos de iPhone

## Dependências
- **Task 4.0**: ViewModel deve ter `groupedResults` e `visibleBrackets`
- **Task 5.0**: `DataSourceBadge` deve estar pronto
- **Task 6.0**: `DistanceGroupHeaderView` deve estar pronto
- **Task 7.0**: `UnifiedRestaurantCard` deve estar pronto

## Observações
- Esta é a maior integração da feature, junta todos os componentes
- LazyVStack é crítico para performance (lazy loading)
- Limite de 15 items previne scroll excessivo
- Quick actions devem abrir URLs usando `UIApplication.shared.open`
- Navegação para detalhe usa ResultView (Restaurant) ou NearbyPlaceDetailView (NearbyPlace)
- Testar em iPhone SE para garantir performance mínima

## status: pending

<task_context>
<domain>presentation/views</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>task_4,task_5,task_6,task_7</dependencies>
</task_context>

# Tarefa 9.0: Update PreferencesView with Vertical List Layout

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta é a tarefa de integração principal que transforma a UI de resultados de horizontal para vertical com agrupamento. Todos os componentes criados anteriormente (UnifiedRestaurantCard, DistanceGroupHeaderView, DataSourceBadge) são integrados aqui, consumindo dados de `NearbyModeViewModel.groupedResults`.

<requirements>
- Usar LazyVStack para performance (lazy loading)
- Renderizar headers de grupo antes de cada seção
- Limitar a 15 items iniciais, expandir com "Ver mais"
- Integrar navegação para detalhes e quick actions
- Manter estados de UI (loading, empty, error)
- Performance < 100ms para renderização
</requirements>

## Subtarefas

- [ ] 9.1 Localizar e abrir `ChooseThere/Presentation/Views/PreferencesView.swift`
- [ ] 9.2 Encontrar seção de renderização de resultados nearby
- [ ] 9.3 Adicionar @State para controle de limite de resultados
- [ ] 9.4 Substituir scroll horizontal por ScrollView + LazyVStack
- [ ] 9.5 Implementar loop sobre viewModel.visibleBrackets
- [ ] 9.6 Para cada bracket, renderizar header e cards
- [ ] 9.7 Implementar lógica de limite (15 items)
- [ ] 9.8 Adicionar botão "Ver mais" quando necessário
- [ ] 9.9 Implementar onTap handler (navegação para detalhe)
- [ ] 9.10 Implementar onQuickAction handler (abrir URLs)
- [ ] 9.11 Aplicar espaçamento e padding corretos
- [ ] 9.12 Testar fluxo completo end-to-end

## Detalhes de Implementação

Consulte `techspec.md` seção "PreferencesView Integration" (linhas 649-657) para contexto.

**State para controle de limite:**
```swift
@State private var showAllResults = false
private let initialResultLimit = 15
```

**Estrutura LazyVStack:**
```swift
ScrollView {
  LazyVStack(spacing: 12) {
    ForEach(viewModel.visibleBrackets, id: \.self) { bracket in
      // Header de seção
      DistanceGroupHeaderView(
        bracket: bracket,
        count: viewModel.groupedResults[bracket]?.count ?? 0
      )

      // Cards do grupo
      ForEach(itemsForBracket(bracket), id: \.displayId) { item in
        UnifiedRestaurantCard(
          item: item,
          onTap: { handleCardTap(item) },
          onQuickAction: { handleQuickAction($0, for: item) }
        )
      }
    }

    // Botão "Ver mais" se necessário
    if shouldShowMoreButton {
      Button("Ver mais") {
        showAllResults = true
      }
    }
  }
  .padding(.horizontal, 16)
}
```

**Limite de items:**
```swift
private func itemsForBracket(_ bracket: DistanceBracket) -> [any NearbyDisplayable] {
  guard let items = viewModel.groupedResults[bracket] else { return [] }

  if showAllResults {
    return items
  }

  // Calcular quantos items já foram exibidos
  let previousCount = previousBracketsCount(before: bracket)
  let remaining = max(0, initialResultLimit - previousCount)

  return Array(items.prefix(remaining))
}
```

**Handler de navegação:**
```swift
private func handleCardTap(_ item: any NearbyDisplayable) {
  if let restaurant = item as? Restaurant {
    // Navegar para ResultView
    navigationPath.append(NavigationDestination.result(restaurant))
  } else if let place = item as? NearbyPlace {
    // Navegar para NearbyPlaceDetailView
    navigationPath.append(NavigationDestination.nearbyDetail(place))
  }
}
```

**Handler de quick actions:**
```swift
private func handleQuickAction(_ action: QuickAction, for item: any NearbyDisplayable) {
  let url: URL?

  switch action {
  case .tripAdvisor:
    url = (item as? Restaurant)?.tripAdvisorLink.flatMap(URL.init)
  case .ifood:
    url = (item as? Restaurant)?.ifoodLink.flatMap(URL.init)
  case .ride99:
    url = (item as? Restaurant)?.ride99Link.flatMap(URL.init)
  case .maps:
    // Construir URL do Maps com coordenadas ou nome
    url = constructMapsURL(for: item)
  }

  if let url = url {
    UIApplication.shared.open(url)
  }
}
```

## Critérios de Sucesso

- ScrollView + LazyVStack substitui scroll horizontal
- Grupos de distância aparecem na ordem correta (veryClose → far)
- DistanceGroupHeaderView renderiza antes de cada grupo
- UnifiedRestaurantCard renderiza cada item corretamente
- Máximo 15 cards visíveis inicialmente
- Botão "Ver mais" aparece quando total > 15
- Clicar "Ver mais" expande lista completa
- Tap em card navega para tela de detalhe correta
- Quick actions abrem URLs corretas (validar manualmente)
- Spacing de 12pt entre cards
- Padding horizontal de 16pt
- Performance < 100ms medido com Instruments
- Scroll mantém 60 FPS em iPhone SE ou superior
- Estados de loading/empty/error não foram quebrados
- Layout se adapta a diferentes tamanhos de tela
- Código formatado seguindo Kodeco style guide
- MARK comments organizam seções

## Arquivos relevantes
- Modificar: `ChooseThere/Presentation/Views/PreferencesView.swift`
- Referência: `ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift` (groupedResults, visibleBrackets)
- Referência: `ChooseThere/Presentation/Components/UnifiedRestaurantCard.swift`
- Referência: `ChooseThere/Presentation/Components/DistanceGroupHeaderView.swift`
- Referência: `ChooseThere/Presentation/Components/DataSourceBadge.swift`
- Referência: `techspec.md` (linhas 649-657, 93-109 para agrupamento)
- Referência: `prd.md` (linhas 93-110 - FR3: Apresentação em Lista Vertical)
