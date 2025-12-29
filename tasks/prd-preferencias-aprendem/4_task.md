# [4.0] Evitar repetidos (últimos N) (M)

## Objetivo
- Evitar que o sorteio repita automaticamente restaurantes recentes (ex.: últimos 10), com fallback quando o conjunto é pequeno.

## Subtarefas
- [x] 4.1 Implementar `RecentHistoryService` para obter últimos N IDs (via VisitRepository)
- [x] 4.2 Integrar no fluxo de sorteio para adicionar `excludeRestaurantIDs`
- [x] 4.3 Implementar fallback quando não houver candidatos (ex.: reduzir N ou permitir repetição)

## Critérios de Sucesso
- Por padrão, não repete últimos N restaurantes quando houver candidatos suficientes.
- Em conjunto pequeno, não bloqueia o usuário (fallback previsível).

## Dependências
- 3.0 Sorteio ponderado por “match” (RestaurantRandomizer)

## Observações
- Definir claramente se “recente” vem de visitas, sorteios, ou ambos (MVP: visitas).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/roulette</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 4.0: Evitar repetidos (últimos N)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Repetição frequente reduz confiança no app. Esta tarefa adiciona uma regra automática de “não repetir os últimos N”, com fallback para não travar o fluxo.

<requirements>
- Identificar últimos N restaurantes (MVP: via histórico de visitas)
- Excluir esses IDs no sorteio
- Fallback quando a exclusão remove todos os candidatos
</requirements>

## Subtarefas

- [x] 4.1 Serviço de histórico recente (últimos N)
- [x] 4.2 Integração no sorteio (excludeRestaurantIDs)
- [x] 4.3 Regras de fallback determinísticas

## Detalhes de Implementação

- Ver `techspec.md`: **RecentHistoryService** e **Riscos** (conjunto pequeno).

## Critérios de Sucesso

- Evita repetição quando há variedade.
- Nunca bloqueia o usuário sem saída.

## Arquivos relevantes
- `tasks/prd-preferencias-aprendem/techspec.md`

