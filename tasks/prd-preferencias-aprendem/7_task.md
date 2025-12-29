# [7.0] Testes unitários principais (M)

## Objetivo
- Cobrir com testes unitários os componentes críticos do aprendizado: store, regras de update, histórico recente e integração no randomizer.

## Subtarefas
- [x] 7.1 Testes do `LearnedPreferencesStore` (load/save/reset e versionamento)
- [x] 7.2 Testes do `PreferenceLearningService` (rating → delta + clamp)
- [x] 7.3 Testes do `RecentHistoryService` (últimos N) e do randomizer com pesos (RNG fixo)
- [x] 7.4 Testes de integração completos (rating → prefs → randomizer)

## Critérios de Sucesso
- Testes passam localmente e não dependem de rede.
- Cobertura suficiente para evoluir regras sem regressão.

## Dependências
- 1.0 Modelo + persistência de preferências aprendidas
- 2.0 Regras de aprendizado a partir de avaliações
- 3.0 Sorteio ponderado por “match” (RestaurantRandomizer)
- 4.0 Evitar repetidos (últimos N)
- 6.0 Integração no fluxo de avaliação (VisitModel)

## Observações
- Evitar testes flakey: preferir RNG determinístico e asserts estáveis.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 7.0: Testes unitários principais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Como o aprendizado mexe com probabilidade e exclusões, precisamos de testes para garantir determinismo e evitar regressões.

<requirements>
- Testar store (persistência + reset)
- Testar regras de aprendizado (delta + clamp)
- Testar histórico recente e integração no randomizer
</requirements>

## Subtarefas

- [x] 7.1 Testes de persistência e reset
- [x] 7.2 Testes das regras por rating
- [x] 7.3 Testes do randomizer com pesos e exclusões
- [x] 7.4 Testes de integração completos

## Detalhes de Implementação

- Ver `techspec.md`: **Abordagem de Testes**.

## Critérios de Sucesso

- Testes determinísticos e estáveis (sem flakiness).

## Arquivos relevantes
- `tasks/prd-preferencias-aprendem/techspec.md`
- `ChooseThere/ChooseThere/ChooseThereTests/*`

