# [5.0] Aplicar cards na lista “Minha base” (M)

## Objetivo
- Substituir a listagem atual de restaurantes da “Minha base” para usar `RestaurantCard`.

## Subtarefas
- [x] 5.1 Ajustar `RestaurantListView` para renderizar cards em vez de rows
- [x] 5.2 Garantir navegação para detalhe e estados (loading/empty/error) intactos
- [x] 5.3 Validar performance e acessibilidade na rolagem

## Critérios de Sucesso
- Lista “Minha base” exibe cards com imagem/ações rápidas quando disponíveis.
- Não há regressões nos filtros/busca/categorias.

## Dependências
- 4.0 RestaurantCard

## Observações
- Manter agrupamento por categoria, mas com cards (pode manter Section headers).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/ui</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 5.0: Aplicar cards na lista “Minha base”

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Integrar o componente `RestaurantCard` na tela de listagem da base local, preservando busca, filtros e navegação para o detalhe.

<requirements>
- Substituir `restaurantRow` por `RestaurantCard`.
- Manter comportamento de clique: card abre detalhe.
- Ações rápidas no card respeitam disponibilidade de links.
</requirements>

## Subtarefas

- [x] 5.1 Atualizar `RestaurantListView` para usar cards
- [x] 5.2 Garantir que filtros e agrupamento por categoria continuem funcionando
- [x] 5.3 Revisar acessibilidade (labels/hints/touch targets)

## Detalhes de Implementação

Referenciar `techspec.md` (seção “UI”). Para imagem, usar o mecanismo definido na task 3.0.

## Critérios de Sucesso

- Listagem renderiza com cards e scroll fluido.
- Busca e filtros continuam corretos.
- Ações rápidas abrem URLs/rota conforme esperado.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`

