# [7.0] UI polish (voltar branco, contraste) e testes (M)

## Objetivo
- Melhorar visibilidade/contraste do botão voltar (ícone branco em contextos sobre mapa) e consolidar testes unitários essenciais para rating e priorização, garantindo que as mudanças de UX/navegação não regredam.

## Subtarefas
- [ ] 7.1 Ajustar estilo do botão voltar em telas com mapa (ícone branco, background adequado)
- [ ] 7.2 Revisar acessibilidade (labels/hints, área mínima de toque)
- [ ] 7.3 Adicionar testes do agregador de rating interno
- [ ] 7.4 Adicionar testes do randomizador/priorização por rating (determinístico via RNG)

## Critérios de Sucesso
- Botão voltar fica claramente visível em backgrounds claros/escuros.
- Testes cobrem os principais cenários de rating e priorização, evitando regressões.

## Dependências
- 4.0 Rating interno (agregação a partir de VisitModel) + atualização incremental
- 5.0 Exibição e filtros/priorização por “bem avaliados”

## Observações
- Preferir centralizar estilo do botão voltar (componente reutilizável) para consistência.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/ux</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 7.0: UI polish (voltar branco, contraste) e testes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Consolidar os ajustes de UI solicitados (voltar mais visível) e garantir qualidade via testes para os componentes críticos adicionados (rating interno e priorização).

<requirements>
- Alterar o ícone do voltar para branco onde necessário (sobre mapa/material)
- Garantir contraste e área mínima de toque + acessibilidade
- Adicionar testes unitários de rating e priorização
</requirements>

## Subtarefas

- [ ] 7.1 Criar/ajustar componente de back button reutilizável (se fizer sentido) e aplicar em `ResultView`/`RatingView`
- [ ] 7.2 Revisar contraste (cores) e states (pressed/disabled)
- [ ] 7.3 Implementar testes do `RestaurantRatingAggregator`
- [ ] 7.4 Implementar testes do comportamento do `RestaurantRandomizer` com rating (RNG injetável)

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seção **Abordagem de Testes**

## Critérios de Sucesso

- Botão voltar visível e consistente nas telas
- Suite de testes passa e cobre cenários críticos:
  - sem avaliações
  - múltiplas avaliações
  - priorização por rating

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RatingView.swift`
- `ChooseThere/ChooseThereTests/RestaurantRandomizerTests.swift`
- `ChooseThere/ChooseThereTests/ChooseThereTests.swift`

