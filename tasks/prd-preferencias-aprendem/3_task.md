# [3.0] Sorteio ponderado por “match” (RestaurantRandomizer) (M/L)

## Objetivo
- Integrar as preferências aprendidas no `RestaurantRandomizer` para aumentar a probabilidade de sorteio de restaurantes com maior match (tags/categoria), mantendo fallback estável.

## Subtarefas
- [ ] 3.1 Definir cálculo de score/peso (match) e fallback quando não houver prefs
- [ ] 3.2 Implementar sorteio ponderado (sem quebrar filtros existentes do `PreferenceContext`)
- [ ] 3.3 Garantir determinismo nos testes (RNG injetável) e evitar regressões no fluxo atual

## Critérios de Sucesso
- Restaurantes com maior match têm maior chance de serem sorteados.
- Sem prefs, o comportamento é equivalente ao atual.
- Testes com RNG fixo são determinísticos.

## Dependências
- 1.0 Modelo + persistência de preferências aprendidas
- 2.0 Regras de aprendizado a partir de avaliações

## Observações
- Evitar “tuning” complexo nesta fase; começar com fórmula simples e iterável.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/roulette</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 3.0: Sorteio ponderado por “match” (RestaurantRandomizer)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O randomizer hoje filtra e sorteia. Aqui adicionamos ponderação por match com base em pesos aprendidos, mantendo o comportamento atual como fallback.

<requirements>
- Implementar ponderação por match (tags/categoria)
- Preservar filtros e regras existentes do randomizer
- Manter testabilidade e determinismo
</requirements>

## Subtarefas

- [ ] 3.1 Modelar score e converter em peso de sorteio
- [ ] 3.2 Integrar no `RestaurantRandomizer` sem quebrar API
- [ ] 3.3 Testes unitários e validação de regressão

## Detalhes de Implementação

- Ver `techspec.md`: **Match scoring** e **Testabilidade**.

## Critérios de Sucesso

- Distribuição favorece match (teste controlado).
- Fallback mantém experiência atual quando prefs vazias.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/PreferenceContext.swift`
- `tasks/prd-preferencias-aprendem/techspec.md`

