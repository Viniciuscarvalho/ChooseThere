# [3.0] Backfill/batch de enriquecimento de localização (M)

## Objetivo
- Implementar um processo em lote (batch) para resolver localização de todos os restaurantes de forma controlada (throttling/concurrency), persistindo resultados e evitando impacto na UI.

## Subtarefas
- [ ] 3.1 Definir estratégia de batch (tamanho, concorrência, pausa entre chamadas)
- [ ] 3.2 Implementar execução em background (Task) e atualização incremental no SwiftData
- [ ] 3.3 Registrar progresso (quantos resolvidos, quantos falharam) e permitir reexecução segura
- [ ] 3.4 Definir gatilhos (ex.: manual em Settings/Preferences, ou após seed)

## Critérios de Sucesso
- Batch resolve restaurantes sem travar a UI e sem explodir concorrência.
- Execuções repetidas respeitam cache e só tentam novamente os não resolvidos/expirados.
- Progresso/estado é observável (mesmo que mínimo, via logs ou UI simples).

## Dependências
- 1.0 Modelos e persistência para localização/rating
- 2.0 Resolver localização via Apple Maps (MapKit) + cache

## Observações
- MapKit pode rate-limit implicitamente; manter concorrência baixa (ex.: 2–4).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/location</domain>
<type>implementation</type>
<scope>performance</scope>
<complexity>medium</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 3.0: Backfill/batch de enriquecimento de localização

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar uma rotina batch para enriquecer `lat/lng` de todos os restaurantes de forma segura, reaproveitando cache e permitindo reexecução.

<requirements>
- Processar restaurantes em batches pequenos com concorrência limitada
- Respeitar cache (`applePlaceResolvedAt`) e não repetir trabalho desnecessário
- Não bloquear UI; execução em background
- Expor um feedback mínimo de progresso/resultado
</requirements>

## Subtarefas

- [ ] 3.1 Criar método `enrichAll()` no `RestaurantLocationEnrichmentService` com throttling
- [ ] 3.2 Implementar persistência incremental e retry apenas para casos elegíveis
- [ ] 3.3 Adicionar gatilho de execução (manual em Preferences ou após seed)
- [ ] 3.4 Validar comportamento em base grande (~100+ restaurantes)

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seção **Requisitos Especiais** (performance) e **Sequenciamento**

## Critérios de Sucesso

- Batch completa sem travar UI
- Resultados persistidos e reaproveitados nas próximas execuções
- Falhas não quebram o processo (continua com próximos itens)

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Services/RestaurantSeeder.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`

