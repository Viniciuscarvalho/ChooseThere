# [3.0] Criar tela de Lista de Restaurantes (M)

## Objetivo
Criar uma nova tela que exibe todos os ~115 restaurantes do JSON, permitindo busca por nome e filtro por categoria. Esta tela será a terceira aba da TabBar.

## Subtarefas
- [ ] 3.1 Criar `RestaurantListViewModel` com lógica de busca e filtro
- [ ] 3.2 Criar `RestaurantListView` com layout de lista
- [ ] 3.3 Implementar barra de busca no topo
- [ ] 3.4 Agrupar restaurantes por categoria
- [ ] 3.5 Exibir indicador de favoritos
- [ ] 3.6 Implementar tap para ver detalhes (navega para ResultView)
- [ ] 3.7 Usar LazyVStack para performance

## Critérios de Sucesso
- Todos os 115+ restaurantes listados
- Busca filtra por nome em tempo real (com debounce)
- Categorias visíveis como headers de seção
- Scroll suave a 60fps
- Favoritos indicados com coração

## Dependências
- 2.0 (TabBar para acomodar a nova aba)

## Observações
- Reutilizar `SwiftDataRestaurantRepository` existente
- Debounce de 300ms na busca para evitar lag
- Mostrar categoria e endereço resumido em cada item

## status: pending

<task_context>
<domain>presentation</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>Task 2.0, SwiftDataRestaurantRepository</dependencies>
</task_context>

## Detalhes de Implementação

Consultar `techspec.md` para:
- Estrutura do ViewModel
- Integração com SwiftData

### Layout do Item

```
┌────────────────────────────────────────┐
│ [🍕] Pizzaria Veridiana          [❤️] │
│      Italian • Rua José Maria...      │
└────────────────────────────────────────┘
```

### Categorias Disponíveis
- bar, brunch, cafe-dessert, burger
- brasileira, japanese, italian
- arab-mediterranean, contemporary-fine

## Arquivos relevantes
- `ChooseThere/Presentation/Views/RestaurantListView.swift` (criar)
- `ChooseThere/Presentation/ViewModels/RestaurantListViewModel.swift` (criar)
- `ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift` (reutilizar)

