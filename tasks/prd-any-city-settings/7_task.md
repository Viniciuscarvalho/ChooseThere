# [7.0] Integração com roleta/detalhe para resultados Apple Maps (M)

## Objetivo
- Integrar resultados do Apple Maps (`NearbyPlace`) ao fluxo de roleta/detalhe sem precisar persistir como `RestaurantModel` nesta fase.

## Subtarefas
- [x] 7.1 Definir um modelo de UI para "resultado Apple Maps" (ex.: sheet/overlay dedicado)
- [x] 7.2 Adaptar a roleta para sortear entre `NearbyPlace` quando fonte for Apple Maps
- [x] 7.3 Implementar ação "Abrir no Maps" para `NearbyPlace`
- [x] 7.4 Garantir que o fluxo existente de `Restaurant` não seja quebrado

## Critérios de Sucesso
- Usuário consegue sortear um lugar vindo do Apple Maps e ver detalhes mínimos (nome/endereço) e abrir no Maps.

## Dependências
- 6.0 “Perto de mim” (fonte: Apple Maps) — busca + cache

## Observações
- Mantemos `NearbyPlace` como entidade transitória para evitar poluir a base local nesta fase.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/roulette</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 7.0: Integração com roleta/detalhe para resultados Apple Maps

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Hoje a roleta trabalha com `restaurantId` e o detalhe (`ResultView`) assume um `Restaurant`. Para suportar Apple Maps sem persistência, precisamos introduzir um caminho de UI dedicado para `NearbyPlace` e evitar quebrar o fluxo atual.

<requirements>
- Roleta deve suportar sorteio de `NearbyPlace` quando a fonte for Apple Maps
- Exibir um detalhe mínimo (nome/endereço) e ação “Abrir no Maps”
- Não impactar negativamente o fluxo existente de `Restaurant`
</requirements>

## Subtarefas

- [x] 7.1 Definir representação navegável para `NearbyPlace` (ex.: novo `OverlayRoute.nearbyResult(...)`)
- [x] 7.2 Implementar view de detalhe mínimo (`NearbyPlaceDetailView`)
- [x] 7.3 Wiring no modo "Perto de mim" para empurrar overlay correto após sorteio
- [x] 7.4 Testes manuais do fluxo completo (local e Apple Maps)

## Detalhes de Implementação

- Tech Spec: **Modelos de Dados** (`NearbyPlace`) e decisão de não persistir em `RestaurantModel`
- Referências existentes:
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppRoute.swift` (OverlayRoute)
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RouletteView.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`

## Critérios de Sucesso

- Sorteio Apple Maps leva para detalhe mínimo e abre Maps com coordenadas
- Sorteio local continua funcionando exatamente como antes

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppRoute.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RouletteView.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/NearbyPlaceDetailView.swift`

