# [1.0] Consolidar regra de sorteio por proximidade + contexto de preferências (M)

## Objetivo
- Garantir que o fluxo de sorteio use um `PreferenceContext` real (tags, raio, rating priority e localização) e que a regra de negócio seja única para “Minha Lista” e “Perto de mim”.

## Subtarefas
- [ ] 1.1 Mapear quais filtros atuais existem em `PreferencesViewModel` e como eles devem valer para “Perto de mim”
- [ ] 1.2 Definir contrato do “contexto unificado” (campos obrigatórios e fallback quando faltarem dados)
- [ ] 1.3 Documentar comportamento de rating no Apple Maps (sem rating interno) e fallback de `.only`

## Critérios de Sucesso
- O `PreferenceContext` do sorteio fica claramente definido (inclusive `userLocation` e `radiusKm`).
- A regra de tags desejadas/evitar e de rating é consistente com o comportamento do sorteio atual.
- Fica explícito o que acontece quando o Apple Maps não oferece dados internos (ratings/tags).

## Dependências
- `tasks/prd-nearby-roulette-eden-ux/prd.md`
- `tasks/prd-nearby-roulette-eden-ux/techspec.md`

## Observações
- A implementação atual do `RouletteViewModel` monta `PreferenceContext` vazio; esta tarefa define como isso deve mudar.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/domain</domain>
<type>documentation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Consolidar regra de sorteio por proximidade + contexto de preferências

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Hoje o sorteio usa `RestaurantRandomizer` e `SmartRouletteService`, mas o contexto passado pela UI pode estar vazio. Precisamos formalizar quais filtros entram no sorteio em cada modo e como garantir comportamento consistente quando a fonte é Apple Maps.

<requirements>
- Definir `PreferenceContext` para ambos os modos (Minha Lista e Perto de mim).
- Definir como `desiredTags`/`avoidTags` são obtidos no modo “Perto de mim”.
- Definir fallback do filtro `.only` quando não houver rating interno.
</requirements>

## Subtarefas

- [ ] 1.1 Levantar filtros existentes (tags, avoid, raio, rating priority) e mapear para `PreferenceContext`
- [ ] 1.2 Especificar como o modo “Perto de mim” obtém `userLocation` e `radiusKm` no contexto
- [ ] 1.3 Especificar o fallback de rating (Apple Maps sem rating interno)

## Detalhes de Implementação

Referenciar a seção “Modelos de Dados” e “Decisões Principais” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Contexto de sorteio documentado e validável.
- Semântica de filtros e fallbacks explícita.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/PreferenceContext.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/RouletteViewModel.swift`


