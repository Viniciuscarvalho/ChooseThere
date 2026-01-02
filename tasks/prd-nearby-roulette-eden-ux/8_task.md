# [8.0] Testes unitários e regressão do fluxo Nearby Roulette (M)

## Objetivo
- Garantir que o sorteio por proximidade e as regras de fallback funcionem corretamente e permaneçam estáveis com testes unitários e regressões básicas.

## Subtarefas
- [ ] 8.1 Criar testes do serviço/orquestração do sorteio nearby (tags, avoid, raio, fallback de rating)
- [ ] 8.2 Criar testes de regra SP-only (UI/VM e execução)
- [ ] 8.3 Criar testes de montagem de `PreferenceContext` (principalmente no modo nearby)
- [ ] 8.4 Rodar suite e corrigir eventuais mocks quebrados

## Critérios de Sucesso
- Testes cobrindo cenários críticos (permite evolução sem regressões).
- Suite de testes passa no target de testes.

## Dependências
- Tarefa 2.0
- Tarefa 3.0
- Tarefa 4.0

## Observações
- Reusar padrões de mocks existentes (protocolos `LocationManaging`, `NearbySearching`, etc.).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>external_apis|database</dependencies>
</task_context>

# Tarefa 8.0: Testes unitários e regressão do fluxo Nearby Roulette

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar cobertura de testes para o novo fluxo de sorteio por proximidade, com foco em filtros e fallbacks (SP-only e rating).

<requirements>
- Tests para: tags desired/avoid, radius (10km), fallbacks (rating `.only`, SP-only, no-results).
- Mocks para `NearbySearching` e `LocationManaging`.
- Regressão: suite passa sem falhas.
</requirements>

## Subtarefas

- [ ] 8.1 Implementar testes do serviço de sorteio nearby
- [ ] 8.2 Implementar testes do gate SP-only e fallback
- [ ] 8.3 Implementar testes de montagem do contexto
- [ ] 8.4 Ajustar mocks e rodar suite

## Detalhes de Implementação

Referenciar “Abordagem de Testes” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Testes verdes e cobrindo cenários críticos.
- Sem regressões no comportamento do sorteio.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThereTests/`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/SmartRouletteService.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/AppleMapsNearbySearchService.swift`


