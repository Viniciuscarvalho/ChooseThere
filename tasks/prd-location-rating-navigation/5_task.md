# [5.0] Exibição e filtros/priorização por “bem avaliados” (M)

## Objetivo
- Exibir rating interno na lista e no detalhe e permitir filtrar/priorizar a seleção (sorteio e/ou listagem) com base em “bem avaliados”.

## Subtarefas
- [ ] 5.1 Exibir rating (média + contagem) no `RestaurantListView` e `ResultView`
- [ ] 5.2 Definir UI de filtro/ordenação “bem avaliados” (ex.: toggle, chip, segment)
- [ ] 5.3 Implementar filtro/priorização no sorteio (randomizer) e/ou na lista (sort)
- [ ] 5.4 Ajustar estados de “sem avaliações” e acessibilidade

## Critérios de Sucesso
- Rating aparece corretamente quando existe, e estados sem rating são coerentes.
- Usuário consegue filtrar/priorizar por “bem avaliados” e isso afeta resultados.
- Sorteio continua respeitando filtros existentes (tags/radius) e não fica sem resultados inesperadamente.

## Dependências
- 4.0 Rating interno (agregação a partir de VisitModel) + atualização incremental

## Observações
- Priorização pode ser probabilística (mais chance para melhores) ou determinística (ordenar/filtrar). Decidir conforme PRD.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/ux</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 5.0: Exibição e filtros/priorização por “bem avaliados”

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Conectar o rating interno persistido aos principais pontos de UI (lista e detalhe) e permitir que o usuário use isso para encontrar e sortear restaurantes “bem avaliados”.

<requirements>
- Exibir rating (média e contagem) em lista e detalhe
- Adicionar um controle de filtro/ordem “bem avaliados”
- Aplicar filtro/priorização no sorteio e/ou listagem
- Tratar “sem avaliações” de forma clara
</requirements>

## Subtarefas

- [ ] 5.1 Atualizar `RestaurantListView` para mostrar rating no item
- [ ] 5.2 Atualizar `ResultView` para mostrar rating no card de detalhes
- [ ] 5.3 Implementar filtro/priorização no `RestaurantRandomizer` e nos ViewModels necessários
- [ ] 5.4 Ajustar textos e acessibilidade (labels, hints)

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seção **Fluxo de dados** e **Abordagem de Testes**

## Critérios de Sucesso

- UI exibe rating corretamente e não quebra com dados vazios
- Filtro/priorização altera resultados de forma verificável
- Testes cobrindo comportamento de priorização/filtro

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/PreferencesViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/RouletteViewModel.swift`

