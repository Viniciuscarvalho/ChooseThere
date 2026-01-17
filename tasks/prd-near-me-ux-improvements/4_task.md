# [4.0] Enhance NearbyModeViewModel with Grouping Logic (M)

## Objetivo
- Adicionar computed property `groupedResults` que agrupa resultados por faixas de distância
- Adicionar computed property `visibleBrackets` que retorna brackets com resultados
- Implementar lógica de ordenação dentro de cada grupo (rating > alfabético)
- Preparar ViewModel para suportar apresentação em lista vertical agrupada

## Subtarefas
- [ ] 4.1 Abrir arquivo `NearbyModeViewModel.swift`
- [ ] 4.2 Adicionar computed property `groupedResults` retornando `[DistanceBracket: [any NearbyDisplayable]]`
- [ ] 4.3 Implementar lógica de agrupamento baseada em `distanceKm`
- [ ] 4.4 Implementar ordenação dentro de grupos (rating descendente, depois alfabético)
- [ ] 4.5 Adicionar computed property `visibleBrackets` retornando brackets ordenados
- [ ] 4.6 Adicionar tratamento para diferentes estados de `searchState`

## Critérios de Sucesso
- Computed property `groupedResults` agrupa corretamente items por distância
- Ordenação dentro de grupos prioriza rating quando disponível
- Items sem rating são ordenados alfabeticamente
- `visibleBrackets` retorna apenas brackets com itens (não vazios)
- Brackets são retornados na ordem correta (veryClose → close → medium → far)
- Código trata todos os casos de `searchState` adequadamente
- Performance adequada para 15-50 items

## Dependências
- **Task 1.0**: Protocol `NearbyDisplayable` deve estar definido
- **Task 2.0**: Enum `DistanceBracket` deve estar implementado
- **Task 3.0**: Extensions de Restaurant e NearbyPlace devem estar prontas

## Observações
- Esta é lógica de ViewModel pura, facilmente testável com dados sintéticos
- Computed property recalcula em cada acesso, mas performance é adequada para ~15 items
- Tratar items sem `distanceKm` (skip no agrupamento)
- Empty state é representado por dictionary vazio
- Esta tarefa não modifica UI, apenas prepara dados

## status: pending

<task_context>
<domain>presentation/viewmodels</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>task_1,task_2,task_3</dependencies>
</task_context>

# Tarefa 4.0: Enhance NearbyModeViewModel with Grouping Logic

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa adiciona a lógica de agrupamento e ordenação de resultados ao ViewModel. O `groupedResults` transforma a lista flat de restaurantes/places em um dicionário agrupado por faixas de distância, enquanto `visibleBrackets` fornece a ordem de renderização para a UI.

<requirements>
- Agrupar items por DistanceBracket baseado em distanceKm
- Ordenar items dentro de cada grupo por rating (desc) ou alfabeticamente
- Retornar apenas brackets não vazios
- Tratar todos os estados de searchState (localResults, appleMapsResults, idle, loading, error)
- Manter performance adequada para listas de até 50 items
</requirements>

## Subtarefas

- [ ] 4.1 Localizar e abrir `ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
- [ ] 4.2 Adicionar extension com computed property `groupedResults`
- [ ] 4.3 Implementar lógica de agrupamento usando `DistanceBracket.contains`
- [ ] 4.4 Implementar ordenação customizada dentro de cada grupo
- [ ] 4.5 Adicionar computed property `visibleBrackets`
- [ ] 4.6 Adicionar MARK comments para organização
- [ ] 4.7 Testar com dados reais de Restaurant e NearbyPlace

## Detalhes de Implementação

Consulte `techspec.md` seção "Grouping Logic Extension" (linhas 169-218) para implementação completa.

**Estrutura geral:**
```swift
extension NearbyModeViewModel {
  var groupedResults: [DistanceBracket: [any NearbyDisplayable]] {
    // 1. Extrair items baseado em searchState
    // 2. Agrupar por bracket usando contains(distanceKm:)
    // 3. Ordenar items dentro de cada grupo
    // 4. Retornar dictionary
  }

  var visibleBrackets: [DistanceBracket] {
    // Filtrar brackets com items, manter ordem natural
  }
}
```

**Lógica de agrupamento:**
```swift
for item in items {
  guard let distance = item.distanceKm else { continue }

  for bracket in DistanceBracket.allCases {
    if bracket.contains(distanceKm: distance) {
      grouped[bracket, default: []].append(item)
      break
    }
  }
}
```

**Lógica de ordenação:**
```swift
grouped[bracket]?.sort { item1, item2 in
  if let r1 = item1.displayRating, let r2 = item2.displayRating {
    return r1 > r2 // Maior rating primeiro
  }
  return item1.displayName < item2.displayName // Alfabético se sem rating
}
```

**Estados de searchState a tratar:**
- `.localResults(let restaurants)`: converter para `[any NearbyDisplayable]`
- `.appleMapsResults(let places)`: converter para `[any NearbyDisplayable]`
- `.idle`, `.loading`, `.error`: retornar dictionary vazio

## Critérios de Sucesso

- Computed property `groupedResults` compila sem erros
- Items são agrupados corretamente em seus respectivos brackets
- Items com rating são ordenados por rating descendente dentro do grupo
- Items sem rating são ordenados alfabeticamente
- `visibleBrackets` retorna apenas brackets não vazios
- `visibleBrackets` mantém ordem natural (veryClose, close, medium, far)
- Items sem `distanceKm` são ignorados (não crasham)
- Performance é adequada (< 10ms para 50 items)
- Código formatado seguindo Kodeco style guide
- MARK comments separam lógica de grouping

## Arquivos relevantes
- Modificar: `ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
- Referência: `ChooseThere/Domain/Protocols/NearbyDisplayable.swift` (protocol)
- Referência: `ChooseThere/Domain/Models/DistanceBracket.swift` (enum)
- Referência: `techspec.md` (linhas 169-218)
