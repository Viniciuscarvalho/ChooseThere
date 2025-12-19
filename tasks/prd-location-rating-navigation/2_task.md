# [2.0] Resolver localização via Apple Maps (MapKit) + cache (L)

## Objetivo
- Implementar um resolvedor de place via `MKLocalSearch` e um serviço de enriquecimento para atualizar `lat/lng` e metadados no SwiftData, com cache para evitar buscas repetidas.

## Subtarefas
- [ ] 2.1 Criar `PlaceResolver` (protocol) e implementação `MapKitPlaceResolver`
- [ ] 2.2 Definir estratégia de query e heurísticas de aceitação do resultado
- [ ] 2.3 Implementar `RestaurantLocationEnrichmentService` (single resolve) com persistência e cache
- [ ] 2.4 Integrar enriquecimento on-demand em telas relevantes (detalhe/lista) sem travar UI

## Critérios de Sucesso
- Para um restaurante dado, o app consegue resolver e persistir coordenadas válidas via MapKit.
- O serviço não executa nova busca quando o cache (timestamp) ainda é válido.
- Falhas/ambiguidade não quebram UI e ficam registradas como “não resolvido”.

## Dependências
- 1.0 Modelos e persistência para localização/rating

## Observações
- Evitar dependência de localização do usuário; a busca textual deve ser suficiente.
- Se necessário, aplicar fallback removendo número do endereço ou usando apenas nome+cidade.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/location</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 2.0: Resolver localização via Apple Maps (MapKit) + cache

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar um resolvedor Apple Maps (MapKit) para corrigir coordenadas a partir de dados textuais do restaurante, persistindo no SwiftData e reutilizando resultados por cache.

<requirements>
- Resolver coordenadas com `MKLocalSearch` (query composta por nome/endereço/cidade/estado)
- Definir heurísticas para aceitar/rejeitar resultados ambíguos
- Persistir status/timestamp e dados normalizados no `RestaurantModel`
- Integração on-demand em `ResultView` e/ou `RestaurantListView` sem bloquear UI
</requirements>

## Subtarefas

- [ ] 2.1 Criar `PlaceResolver` e `MapKitPlaceResolver` usando `async/await`
- [ ] 2.2 Implementar heurísticas (ex.: match de endereço, distância, fallback de query)
- [ ] 2.3 Implementar `RestaurantLocationEnrichmentService.resolve(restaurantId:)` com cache por `applePlaceResolvedAt`
- [ ] 2.4 Expor estado para UI (loading/erro) e integrar em telas

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seções **Pontos de Integração** e **Modelos de Dados**

## Critérios de Sucesso

- Resolução bem sucedida atualiza `lat/lng` e marca `applePlaceResolved=true`
- Cache impede chamadas repetidas dentro de uma janela configurável
- UI permanece responsiva e apresenta fallback quando não resolvido

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`

