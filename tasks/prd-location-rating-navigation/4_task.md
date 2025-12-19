# [4.0] Rating interno (agregação a partir de VisitModel) + atualização incremental (M)

## Objetivo
- Implementar cálculo de rating interno por restaurante usando `VisitModel` e persistir um snapshot no `RestaurantModel`, atualizando automaticamente após salvar uma nova avaliação.

## Subtarefas
- [ ] 4.1 Criar `RestaurantRatingAggregator` (Domain/Services) para média/contagem/recência
- [ ] 4.2 Implementar atualização incremental do snapshot quando `RatingViewModel.save()` for bem sucedido
- [ ] 4.3 Atualizar repositórios/queries para expor rating no domínio (`Restaurant`)
- [ ] 4.4 Definir comportamento para restaurantes sem avaliações (rating=0/sem exibir)

## Critérios de Sucesso
- Ao salvar uma visita, o rating do restaurante é recalculado/atualizado e persistido.
- Lista/detalhe conseguem ler o snapshot sem recomputar tudo a cada render.
- Agregação retorna valores corretos (incluindo contagem e última visita).

## Dependências
- 1.0 Modelos e persistência para localização/rating

## Observações
- Rating interno é local (do usuário). Evitar confundir com “rating global”.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/rating</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 4.0: Rating interno (agregação a partir de VisitModel) + atualização incremental

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar uma camada de agregação do histórico (`VisitModel`) para produzir um rating interno por restaurante e persistir isso em `RestaurantModel` para uso rápido em UI e filtros.

<requirements>
- Calcular média (1–5), contagem de avaliações e data da última visita por restaurante
- Persistir snapshot no `RestaurantModel`
- Atualizar snapshot automaticamente após salvar uma avaliação
- Definir UX para “sem avaliações” (ex.: esconder, ou mostrar “Sem avaliações”)
</requirements>

## Subtarefas

- [ ] 4.1 Criar `RestaurantRatingAggregator` e testes unitários (com repositório fake)
- [ ] 4.2 Atualizar `RatingViewModel` (ou fluxo equivalente) para disparar recomputação do rating do restaurante avaliado
- [ ] 4.3 Persistir `ratingAverage`, `ratingCount`, `ratingLastVisitedAt` no `RestaurantModel`
- [ ] 4.4 Validar impacto em performance (evitar recomputar em loops de render)

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seção **Abordagem de Testes** e **Modelos de Dados**

## Critérios de Sucesso

- Snapshot atualizado após `save()` e refletido na UI
- Testes cobrindo média/contagem/recência e casos sem visitas
- Sem regressões no salvamento de `VisitModel`

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/RatingViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataVisitRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`

