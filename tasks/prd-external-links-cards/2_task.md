# [2.0] Editor de links (TripAdvisor/iFood/99/imagem) + validação (M)

## Objetivo
- Criar uma UX simples para o usuário colar/editar links oficiais por restaurante e persistir no SwiftData.

## Subtarefas
- [x] 2.1 Criar `RestaurantLinksEditorView` (sheet) com campos e validação
- [x] 2.2 Adicionar CTA "Adicionar links" a partir do detalhe e/ou card
- [x] 2.3 Persistir alterações via `RestaurantRepository`

## Critérios de Sucesso
- Usuário consegue salvar URLs válidas e ver ações rápidas aparecerem.
- URLs inválidas mostram feedback claro e não quebram a navegação.

## Dependências
- 1.0 Modelos e persistência de links/imagem

## Observações
- Sem API paga: o editor é o ponto central da curadoria.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/ui</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 2.0: Editor de links + validação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O app precisa oferecer uma forma prática de salvar links oficiais (TripAdvisor/iFood/99) e uma URL de imagem manual. Essa tela deve ser rápida, com validação simples e UX alinhada ao design do app (cards, espaçamentos, acessibilidade).

<requirements>
- UI deve ser apresentada como sheet/modal (padrão do app).
- Campos: TripAdvisor, iFood, 99 (opcional), Imagem (opcional).
- Validar URL (mínimo: formato válido e preferir https).
- Persistir usando `RestaurantRepository`.
</requirements>

## Subtarefas

- [x] 2.1 Implementar `RestaurantLinksEditorView` com TextFields, botões "Cancelar/Salvar" e validação
- [x] 2.2 Adicionar CTA "Adicionar links" na UI (card/detalhe)
- [x] 2.3 Salvar e recarregar restaurante após update para refletir ações rápidas

## Detalhes de Implementação

Referenciar `techspec.md` (seção “UI” e “Modelos de Dados”). A abertura de links deve usar helper centralizado (task 6.0/parte da 4.0, conforme tasks.md).

## Critérios de Sucesso

- URLs salvas aparecem como ações rápidas nos cards.
- URLs inválidas não são persistidas; usuário recebe mensagem clara.
- Touch targets e labels de acessibilidade corretos.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift` (ponto natural para CTA)
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`

