# Tech Spec - Melhorias de UX e Navegação

## Resumo Executivo

Esta especificação técnica descreve a implementação de um sistema de navegação por TabBar, tela de onboarding, listagem de restaurantes e ajustes de layout. A abordagem principal é criar uma `MainTabView` que encapsula as 3 abas principais, mantendo o Router existente para navegação interna (modais e push).

## Arquitetura do Sistema

### Visão Geral dos Componentes

```
┌─────────────────────────────────────────────────────────┐
│                      RootView                            │
│  ┌─────────────────────────────────────────────────────┐│
│  │ if !hasSeenOnboarding → OnboardingView              ││
│  │ else → MainTabView                                   ││
│  │         ├── Tab 0: HistoryView                       ││
│  │         ├── Tab 1: PreferencesView (→ flow interno) ││
│  │         └── Tab 2: RestaurantListView                ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Componentes Principais

| Componente | Responsabilidade |
|------------|------------------|
| `MainTabView` | Container da TabBar com 3 abas |
| `OnboardingView` | Tela de primeiro acesso com slides |
| `RestaurantListView` | Lista de todos os restaurantes |
| `CustomTabBar` | Componente visual da TabBar customizada |
| `OnboardingStorage` | Wrapper para UserDefaults |

### Fluxo de Dados

1. **Inicialização**: `RootView` verifica `hasSeenOnboarding`
2. **Onboarding**: Se false, exibe `OnboardingView` → ao concluir, seta flag e navega para `MainTabView`
3. **MainTabView**: Gerencia estado da tab selecionada (`@State var selectedTab: Tab`)
4. **Navegação interna**: Router continua gerenciando fluxos modais (Roulette → Result → Rating)

## Design de Implementação

### Interfaces Principais

```swift
// Tab enum para navegação
enum Tab: Int, CaseIterable {
    case history = 0
    case draw = 1
    case restaurants = 2
    
    var icon: String {
        switch self {
        case .history: return "clock.arrow.circlepath"
        case .draw: return "dice.fill"
        case .restaurants: return "list.bullet"
        }
    }
    
    var title: String {
        switch self {
        case .history: return "Histórico"
        case .draw: return "Sortear"
        case .restaurants: return "Restaurantes"
        }
    }
}

// Storage para onboarding
enum OnboardingStorage {
    private static let key = "hasSeenOnboarding"
    
    static var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
```

### Modelos de Dados

Não há novos modelos de dados. A `RestaurantListView` reutiliza `Restaurant` e `RestaurantModel`.

### Estrutura de Arquivos

```
Presentation/
├── Views/
│   ├── MainTabView.swift         # Container principal
│   ├── OnboardingView.swift      # (atualizar existente)
│   ├── RestaurantListView.swift  # Nova tela
│   ├── ResultView.swift          # (ajustar layout)
│   └── HistoryDetailView.swift   # (ajustar layout)
├── Components/
│   └── CustomTabBar.swift        # TabBar customizada
└── ViewModels/
    └── RestaurantListViewModel.swift
```

## Pontos de Integração

### AppRouter

O Router existente continua funcionando para:
- Push de `RouletteView` → `ResultView` → `RatingView`
- Push de `HistoryDetailView`
- Navegação de volta (pop)

A `MainTabView` é independente do Router - ela gerencia apenas a troca de abas.

### SwiftData

`RestaurantListView` usa o mesmo `SwiftDataRestaurantRepository` para buscar restaurantes.

## Abordagem de Testes

### Testes Unitários

| Componente | O que testar |
|------------|--------------|
| `OnboardingStorage` | Get/set de flag em UserDefaults |
| `Tab` enum | Ícones e títulos corretos |
| `RestaurantListViewModel` | Filtro por busca e categoria |

### Cenários de Teste

1. **Onboarding**: Primeiro acesso mostra onboarding, segundo acesso não
2. **TabBar**: Troca de abas preserva estado interno
3. **Busca**: Digitar "sushi" filtra restaurantes japoneses
4. **Layout**: Nome do restaurante não é truncado

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **1.0 Onboarding** (independente) - Pode ser feito primeiro pois é entrada do app
2. **2.0 TabBar + MainTabView** - Estrutura central que conecta tudo
3. **3.0 RestaurantListView** - Nova aba que depende da TabBar
4. **4.0 Ajuste ResultView** - Correção de layout independente
5. **5.0 Ajuste HistoryDetailView** - Correção de layout independente
6. **6.0 Testes e polimento** - Validação final

### Dependências Técnicas

- Task 2.0 depende de 1.0 para o fluxo completo
- Task 3.0 depende de 2.0 (nova aba)
- Tasks 4.0 e 5.0 são independentes e podem ser paralelas

## Considerações Técnicas

### Decisões Principais

| Decisão | Justificativa | Alternativas Rejeitadas |
|---------|---------------|------------------------|
| TabBar customizada | Mais controle visual, aba central destacada | SwiftUI TabView (menos flexível) |
| State local para tabs | Simples, não precisa de Router | Integrar ao Router (mais complexo) |
| Onboarding via PageTabViewStyle | Nativo SwiftUI, gestos gratuitos | Custom carousel (mais código) |

### Riscos Conhecidos

1. **Risco**: TabBar pode conflitar com safe area em iPhones com notch
   - **Mitigação**: Usar `safeAreaInset(edge: .bottom)`

2. **Risco**: Lista de 115+ restaurantes pode ter scroll lento
   - **Mitigação**: LazyVStack com IDs estáveis

### Requisitos de Performance

- Lista de restaurantes: scroll a 60fps
- Transição de tabs: < 100ms
- Busca: debounce de 300ms

### Conformidade com Padrões

- Seguir Kodeco Swift Style Guide
- Usar DesignSystem existente (AppColors)
- Manter padrão MVVM da arquitetura

## Arquivos Relevantes

### Existentes (a modificar)
- `ChooseThere/Application/RootView.swift` - Adicionar lógica de onboarding
- `ChooseThere/Presentation/Views/OnboardingView.swift` - Redesign com slides
- `ChooseThere/Presentation/Views/ResultView.swift` - Ajuste de layout
- `ChooseThere/Presentation/Views/HistoryDetailView.swift` - Ajuste de layout

### Novos
- `ChooseThere/Presentation/Views/MainTabView.swift`
- `ChooseThere/Presentation/Views/RestaurantListView.swift`
- `ChooseThere/Presentation/Components/CustomTabBar.swift`
- `ChooseThere/Presentation/ViewModels/RestaurantListViewModel.swift`
- `ChooseThere/Application/OnboardingStorage.swift`


