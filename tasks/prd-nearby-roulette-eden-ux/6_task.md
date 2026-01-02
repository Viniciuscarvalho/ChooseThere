# [6.0] Unificar seleção de tags/filtros entre “Minha Lista” e “Perto de mim” (M)

## Objetivo
- Garantir que as tags (desired/avoid) e filtros principais tenham comportamento consistente entre os modos, reduzindo duplicação de UI e divergência de regra.

## Subtarefas
- [ ] 6.1 Definir quais filtros são compartilhados entre modos (ex.: desiredTags/avoidTags/raio/rating priority)
- [ ] 6.2 Criar componentes reutilizáveis de seleção (chips/tags) para usar em ambos os modos
- [ ] 6.3 Garantir persistência coerente (AppSettingsStorage) e restauração de estado

## Critérios de Sucesso
- Usuário consegue selecionar tags para “Perto de mim” com a mesma UX do modo “Minha Lista”.
- O `PreferenceContext` gerado fica consistente e previsível.

## Dependências
- Tarefa 1.0
- Tarefa 5.0

## Observações
- Hoje o modo nearby usa `selectedCategory`; isso deve conviver ou ser substituído por seleção de tags, conforme definido na spec.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/swiftui</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 6.0: Unificar seleção de tags/filtros entre “Minha Lista” e “Perto de mim”

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Para que o sorteio “Perto de mim” respeite tags, precisamos expor uma seleção de tags clara também nesse modo e garantir que a UI gere o mesmo contexto de sorteio do modo “Minha Lista”.

<requirements>
- Expor seleção de tags desejadas e tags a evitar no modo “Perto de mim” (ou um equivalente consistente).
- Reusar componentes de UI de seleção sempre que possível.
- Persistir/restaurar valores via `AppSettingsStorage` com consistência.
</requirements>

## Subtarefas

- [ ] 6.1 Definir modelo de filtros compartilhados e suas fontes de verdade
- [ ] 6.2 Implementar componentes reutilizáveis de tags
- [ ] 6.3 Integrar persistência e restauração de estado

## Detalhes de Implementação

Referenciar “Modelos de Dados” e “Decisões Principais” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Seleção de tags funciona nos dois modos.
- Contexto de sorteio coerente e previsível.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/PreferencesViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppSettingsStorage.swift`


