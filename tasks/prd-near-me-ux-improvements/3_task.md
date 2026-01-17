# [3.0] Extend Restaurant and NearbyPlace with NearbyDisplayable (M)

## Objetivo
- Implementar conformidade ao protocolo `NearbyDisplayable` para `Restaurant`
- Implementar conformidade ao protocolo `NearbyDisplayable` para `NearbyPlace`
- Mapear propriedades específicas de cada tipo para a interface comum
- Garantir que todas as propriedades estejam corretamente implementadas

## Subtarefas
- [ ] 3.1 Criar extension de `Restaurant` conformando a `NearbyDisplayable`
- [ ] 3.2 Implementar todas as propriedades do protocol para `Restaurant`
- [ ] 3.3 Implementar computed property `externalActions` baseado em links disponíveis
- [ ] 3.4 Criar extension de `NearbyPlace` conformando a `NearbyDisplayable`
- [ ] 3.5 Implementar todas as propriedades do protocol para `NearbyPlace`
- [ ] 3.6 Testar ambas as extensions com dados reais

## Critérios de Sucesso
- Ambas extensions compilam sem erros
- `Restaurant` retorna `.localBase` como `dataSource`
- `NearbyPlace` retorna `.appleMaps` como `dataSource`
- `externalActions` de Restaurant inclui apenas ações com links disponíveis
- `displayImageURL` de Restaurant converte string para URL corretamente
- Propriedades opcionais são tratadas adequadamente
- Código segue Kodeco Swift Style Guide

## Dependências
- **Task 1.0**: Protocol `NearbyDisplayable` deve estar definido

## Observações
- Extensions devem ser criadas no mesmo arquivo `NearbyDisplayable.swift` para coesão
- Restaurant possui mais dados ricos (rating, links externos) que NearbyPlace
- NearbyPlace possui apenas ação `.maps` disponível (sem TripAdvisor/iFood/99)
- Tratar casos onde `imageUrl` é string vazia retornando `nil`
- Category hint de NearbyPlace pode ser nil, usar "Restaurante" como fallback

## status: pending

<task_context>
<domain>domain/protocols</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>task_1</dependencies>
</task_context>

# Tarefa 3.0: Extend Restaurant and NearbyPlace with NearbyDisplayable

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa conecta os modelos de domínio existentes (`Restaurant` e `NearbyPlace`) ao novo protocolo unificado. As extensions mapeiam propriedades específicas de cada tipo para a interface comum, permitindo que ambos sejam renderizados pelo mesmo componente de UI.

<requirements>
- Restaurant deve mapear todos os dados disponíveis (rating, image, links)
- NearbyPlace deve usar defaults sensíveis para dados não disponíveis
- Conversão de URL deve ser segura (tratar strings vazias)
- externalActions deve refletir apenas links realmente disponíveis
</requirements>

## Subtarefas

- [ ] 3.1 Adicionar extension `Restaurant: NearbyDisplayable` em `NearbyDisplayable.swift`
- [ ] 3.2 Implementar todas as propriedades do protocol para Restaurant
- [ ] 3.3 Implementar lógica de `externalActions` verificando disponibilidade de links
- [ ] 3.4 Adicionar extension `NearbyPlace: NearbyDisplayable` no mesmo arquivo
- [ ] 3.5 Implementar todas as propriedades do protocol para NearbyPlace
- [ ] 3.6 Adicionar MARK comments para organização

## Detalhes de Implementação

Consulte `techspec.md` seção "Restaurant Extension" (linhas 220-245) e "NearbyPlace Extension" (linhas 247-262).

**Restaurant Extension - Pontos importantes:**
```swift
var displayImageURL: URL? {
  guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return nil }
  return URL(string: imageUrl)
}

var externalActions: [QuickAction] {
  var actions: [QuickAction] = []
  if let _ = tripAdvisorLink { actions.append(.tripAdvisor) }
  if let _ = ifoodLink { actions.append(.ifood) }
  if let _ = ride99Link { actions.append(.ride99) }
  actions.append(.maps) // Sempre disponível
  return actions
}

var dataSource: DataSource { .localBase }
```

**NearbyPlace Extension - Pontos importantes:**
```swift
var displayId: String { id.uuidString }
var displayCategory: String { categoryHint ?? "Restaurante" }
var displayImageURL: URL? { nil } // Apple Maps não fornece imagens
var displayRating: Double? { nil } // Apple Maps não fornece ratings
var externalActions: [QuickAction] { [.maps] } // Apenas Maps
var dataSource: DataSource { .appleMaps }
```

**Mapeamento de propriedades:**
- `displayId`: Restaurant usa `id` (String), NearbyPlace usa `id.uuidString`
- `displayName`: Ambos usam `name` direto
- `displayAddress`: Restaurant usa `address`, NearbyPlace também
- `distanceKm`: Ambos já possuem esta propriedade

## Critérios de Sucesso

- Extension `Restaurant: NearbyDisplayable` compila sem erros
- Extension `NearbyPlace: NearbyDisplayable` compila sem erros
- `Restaurant.dataSource` retorna `.localBase`
- `NearbyPlace.dataSource` retorna `.appleMaps`
- `Restaurant.externalActions` retorna array dinâmico baseado em links disponíveis
- `NearbyPlace.externalActions` retorna sempre `[.maps]`
- Conversão de imageUrl trata casos de string vazia retornando nil
- Category de NearbyPlace usa fallback "Restaurante" quando nil
- Código possui MARK comments separando extensions
- Formatação segue guia de estilo (2 spaces, golden path)

## Arquivos relevantes
- Modificar: `ChooseThere/Domain/Protocols/NearbyDisplayable.swift`
- Referência: `ChooseThere/Domain/Models/Restaurant.swift` (modelo existente)
- Referência: `ChooseThere/Domain/Models/NearbyPlace.swift` (modelo existente)
- Referência: `techspec.md` (linhas 220-262)
