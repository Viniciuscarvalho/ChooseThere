# [4.0] Integrar fluxo “Sortear perto de mim” na UI e navegação para resultado (M)

## Objetivo
- Implementar o fluxo completo de UI: usuário toca em “Sortear perto de mim” → busca (até 10km) → sorteio → navega para `ResultView` do item sorteado, com estados claros.

## Subtarefas
- [ ] 4.1 Definir estados do fluxo (loading, noPermission, noResults, error, success) e mensagens
- [ ] 4.2 Integrar CTA do modo nearby para disparar o serviço de sorteio nearby
- [ ] 4.3 Garantir navegação consistente (router) para `ResultView`/overlay correto
- [ ] 4.4 Manter consistência com comportamento atual de “pendingId” quando aplicável

## Critérios de Sucesso
- Fluxo “Sortear perto de mim” funciona end-to-end com feedback de UI.
- Em caso de erro/sem permissão, o usuário sabe o que fazer (retry/abrir Settings).
- Ao sucesso, abre o resultado correto.

## Dependências
- Tarefa 2.0
- Tarefa 3.0

## Observações
- Evitar duplicar lógicas de busca/sorteio na View; a View deve orquestrar chamadas e estados.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/flow</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 4.0: Integrar fluxo “Sortear perto de mim” na UI e navegação para resultado

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

A tela “Escolher” deve oferecer um CTA claro no modo “Perto de mim”. Ao tocar, o app executa o pipeline de busca + sorteio e navega para o resultado, mostrando estados claros.

<requirements>
- CTA “Sortear perto de mim” no rodapé quando `searchMode == .nearby`.
- Estados visuais para loading/erro/sem permissão/sem resultados.
- Navegação para resultado consistente com o padrão do app (`AppRouter`).
</requirements>

## Subtarefas

- [ ] 4.1 Implementar state machine do fluxo de CTA no modo nearby
- [ ] 4.2 Integrar `NearbyRouletteServicing` (ou equivalente) a partir da ViewModel
- [ ] 4.3 Implementar navegação pós-sorteio para `ResultView`
- [ ] 4.4 Ajustar mensagens/UX e acessibilidade do CTA

## Detalhes de Implementação

Referenciar “Tratamento de erros e UX” e “Sequenciamento” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Fluxo funciona e é previsível para o usuário.
- Não há duplicidade de lógica de sorteio na camada de View.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppRouter.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`


