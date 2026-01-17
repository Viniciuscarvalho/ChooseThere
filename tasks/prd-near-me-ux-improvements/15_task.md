# [15.0] Write Unit Tests (L)

## Objetivo
- Escrever testes unitários para lógica crítica de negócio
- Testar NearbyModeViewModel (groupedResults, visibleBrackets)
- Testar conformidade ao protocolo NearbyDisplayable
- Testar lógica de DistanceBracket
- Testar SearchModeSegmentView filtering logic
- Atingir cobertura mínima de 80% em código crítico

## Subtarefas
- [ ] 15.1 Criar `NearbyModeViewModelTests.swift`
- [ ] 15.2 Escrever testes para `groupedResults` com múltiplos cenários
- [ ] 15.3 Escrever testes para `visibleBrackets`
- [ ] 15.4 Criar `NearbyDisplayableTests.swift`
- [ ] 15.5 Testar Restaurant e NearbyPlace conformance
- [ ] 15.6 Criar `DistanceBracketTests.swift`
- [ ] 15.7 Testar lógica de `contains(distanceKm:)`
- [ ] 15.8 Criar `SearchModeSegmentViewTests.swift` (se possível UI tests)
- [ ] 15.9 Executar test suite completa
- [ ] 15.10 Validar cobertura com Code Coverage tool

## Critérios de Sucesso
- Todos os testes passam sem falhas
- Cobertura de código > 80% para:
  - NearbyModeViewModel (grouping logic)
  - NearbyDisplayable extensions
  - DistanceBracket enum
- Testes são rápidos (< 5s para suite completa)
- Testes são determinísticos (não flaky)
- Testes usam dados sintéticos (não dependem de network/database)
- Nomes de testes são descritivos (testGroupedResults_emptyState_returnsEmptyDictionary)

## Dependências
- **Tasks 1-4**: Protocols, models, e ViewModel devem estar implementados
- **Task 8**: SearchModeSegmentView modifications

## Observações
- Foco em lógica de negócio (não UI tests nesta task)
- Usar XCTest framework nativo
- Criar mocks/stubs quando necessário
- Não testar código de terceiros (SwiftUI, MapKit)
- PRD não especifica cobertura mínima, usar 80% como target razoável
- Techspec lista cenários críticos (linhas 564-614)

## status: pending

<task_context>
<domain>testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>task_1,task_2,task_3,task_4,task_8</dependencies>
</task_context>

# Tarefa 15.0: Write Unit Tests

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa implementa a camada de testes que garante qualidade e previne regressões. Foca em testar lógica crítica de negócio que é complexa e propensa a bugs (agrupamento, ordenação, filtragem). UI tests são deixados para task 16.

<requirements>
- Testar toda lógica de agrupamento e ordenação
- Testar edge cases (listas vazias, valores limites, dados inválidos)
- Testes devem ser rápidos e determinísticos
- Usar dados sintéticos (não dependências externas)
- Naming claro seguindo convenção: test[Method]_[Scenario]_[ExpectedResult]
</requirements>

## Subtarefas

- [ ] 15.1 Criar arquivo `NearbyModeViewModelTests.swift` em `ChooseThereTests/Presentation/ViewModels/`
- [ ] 15.2 Implementar test cases para groupedResults
- [ ] 15.3 Implementar test cases para visibleBrackets
- [ ] 15.4 Criar arquivo `NearbyDisplayableTests.swift` em `ChooseThereTests/Domain/Protocols/`
- [ ] 15.5 Implementar conformance tests
- [ ] 15.6 Criar arquivo `DistanceBracketTests.swift` em `ChooseThereTests/Domain/Models/`
- [ ] 15.7 Implementar tests de lógica de ranges
- [ ] 15.8 Criar arquivo `SearchModeSegmentViewTests.swift` (opcional, se possível testar lógica)
- [ ] 15.9 Run all tests: Cmd+U
- [ ] 15.10 Check code coverage: Editor → Show Code Coverage

## Detalhes de Implementação

Consulte `techspec.md` seção "Testes Unitários" (linhas 562-614) para cenários críticos.

### NearbyModeViewModelTests

**Setup:**
```swift
import XCTest
@testable import ChooseThere

final class NearbyModeViewModelTests: XCTestCase {
  var sut: NearbyModeViewModel!

  override func setUp() {
    super.setUp()
    // Criar viewModel com mocks se necessário
    sut = NearbyModeViewModel()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }
}
```

**Cenários críticos (conforme techspec):**
```swift
func testGroupedResults_emptyState_returnsEmptyDictionary() {
  // Given: searchState = .idle
  // When: acessar groupedResults
  // Then: deve retornar [:]
}

func testGroupedResults_singleRestaurant_groupsCorrectly() {
  // Given: 1 restaurant a 0.5km
  // When: groupedResults
  // Then: deve estar em .veryClose bracket
}

func testGroupedResults_multipleBrackets_distributesProperly() {
  // Given: restaurants em 0.5km, 2km, 4km, 8km
  // When: groupedResults
  // Then: veryClose[1], close[1], medium[1], far[1]
}

func testGroupedResults_sortsByRatingWithinGroup() {
  // Given: 3 restaurants no mesmo bracket com ratings 4.5, 3.0, 5.0
  // When: groupedResults[bracket]
  // Then: ordem deve ser [5.0, 4.5, 3.0]
}

func testGroupedResults_sortsByNameWhenNoRating() {
  // Given: 3 restaurants sem rating: "Zara", "Apple", "Mango"
  // When: groupedResults[bracket]
  // Then: ordem deve ser ["Apple", "Mango", "Zara"]
}

func testVisibleBrackets_onlyReturnsNonEmptyBrackets() {
  // Given: items apenas em veryClose e far
  // When: visibleBrackets
  // Then: deve conter apenas [.veryClose, .far]
}

func testVisibleBrackets_ordersCorrectly() {
  // Given: items em far, veryClose, medium (ordem não natural)
  // When: visibleBrackets
  // Then: deve retornar [.veryClose, .medium, .far] (ordem correta)
}
```

### NearbyDisplayableTests

```swift
func testRestaurant_conformsToNearbyDisplayable() {
  let restaurant = Restaurant(/* mock data */)
  XCTAssertEqual(restaurant.dataSource, .localBase)
  XCTAssertEqual(restaurant.displayName, restaurant.name)
  // ... testar todas as properties
}

func testNearbyPlace_conformsToNearbyDisplayable() {
  let place = NearbyPlace(/* mock data */)
  XCTAssertEqual(place.dataSource, .appleMaps)
  XCTAssertNotNil(place.displayId)
  // ... testar todas as properties
}

func testDataSource_correctBadgeColorsAndIcons() {
  XCTAssertEqual(DataSource.localBase.badgeIcon, "externaldrive.fill")
  XCTAssertEqual(DataSource.appleMaps.badgeIcon, "map.fill")
  // ... testar cores e tooltips
}
```

### DistanceBracketTests

```swift
func testDistanceBracket_veryClose_containsCorrectRange() {
  XCTAssertTrue(DistanceBracket.veryClose.contains(distanceKm: 0.0))
  XCTAssertTrue(DistanceBracket.veryClose.contains(distanceKm: 0.5))
  XCTAssertTrue(DistanceBracket.veryClose.contains(distanceKm: 0.999))
  XCTAssertFalse(DistanceBracket.veryClose.contains(distanceKm: 1.0))
}

func testDistanceBracket_close_containsCorrectRange() {
  XCTAssertFalse(DistanceBracket.close.contains(distanceKm: 0.999))
  XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 1.0))
  XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 2.5))
  XCTAssertTrue(DistanceBracket.close.contains(distanceKm: 2.999))
  XCTAssertFalse(DistanceBracket.close.contains(distanceKm: 3.0))
}

// ... similar para medium e far

func testDistanceBracket_displayNames_areInPortuguese() {
  XCTAssertEqual(DistanceBracket.veryClose.displayName, "Muito perto")
  XCTAssertEqual(DistanceBracket.close.displayName, "Perto")
  XCTAssertEqual(DistanceBracket.medium.displayName, "Média distância")
  XCTAssertEqual(DistanceBracket.far.displayName, "Mais distante")
}
```

### SearchModeSegmentViewTests

```swift
// Nota: Testar SwiftUI views é complexo, considerar:
// - Testar lógica extraída para ViewModel se possível
// - Ou usar ViewInspector library
// - Ou apenas validar manualmente

func testVisibleModes_whenSaoPaulo_showsBothModes() {
  // Setup: Mock AppSettingsStorage.isSaoPauloSelected = true
  // Then: visibleModes deve conter [.myList, .nearby]
}

func testVisibleModes_whenNotSaoPaulo_showsOnlyNearby() {
  // Setup: Mock AppSettingsStorage.isSaoPauloSelected = false
  // Then: visibleModes deve conter apenas [.nearby]
}
```

## Critérios de Sucesso

### Test Execution
- [ ] Todos os testes passam: ✓ (verde)
- [ ] Nenhum teste falha ou é skipped
- [ ] Suite completa executa em < 5 segundos
- [ ] Testes são determinísticos (rodar 10x, todos passam)

### Code Coverage
- [ ] NearbyModeViewModel: > 80% coverage (grouping logic)
- [ ] NearbyDisplayable extensions: > 80% coverage
- [ ] DistanceBracket: 100% coverage (enum simples)
- [ ] Overall feature coverage: > 70%

### Test Quality
- [ ] Nomes seguem convenção: test[Method]_[Scenario]_[ExpectedResult]
- [ ] Cada test testa um único conceito (single responsibility)
- [ ] Testes usam Given-When-Then structure (ou Arrange-Act-Assert)
- [ ] Assertions são específicas (não apenas "not nil")
- [ ] Edge cases são cobertos (valores limite, listas vazias)

### Documentation
- [ ] Comentários explicam cenários complexos
- [ ] README ou docs mencionam como rodar testes
- [ ] CI/CD configurado para rodar testes (opcional)

## Arquivos relevantes
- Criar: `ChooseThereTests/Presentation/ViewModels/NearbyModeViewModelTests.swift`
- Criar: `ChooseThereTests/Domain/Protocols/NearbyDisplayableTests.swift`
- Criar: `ChooseThereTests/Domain/Models/DistanceBracketTests.swift`
- Criar: `ChooseThereTests/Presentation/Components/SearchModeSegmentViewTests.swift` (opcional)
- Referência: `techspec.md` (linhas 562-614 - cenários de teste)
- Tools: XCTest framework, Xcode Code Coverage
