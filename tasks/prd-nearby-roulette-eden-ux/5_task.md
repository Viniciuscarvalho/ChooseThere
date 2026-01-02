# [5.0] Refatorar tela “Escolher” (PreferencesView) no padrão Eden (L)

## Objetivo
- Reorganizar a tela “Escolher” para eliminar duplicidades e deixar o entendimento óbvio (modo → contexto → filtros → CTA), inspirando-se no UI kit Eden.

## Subtarefas
- [ ] 5.1 Mapear duplicidades e pontos confusos atuais (ex.: cards redundantes, labels repetidos, hierarquia)
- [ ] 5.2 Extrair subviews e componentes reutilizáveis (sections/cards) reduzindo tamanho do `body`
- [ ] 5.3 Reorganizar layout e espaçamentos (Eden-inspired), mantendo consistência com DesignSystem
- [ ] 5.4 Revisar acessibilidade (labels, hints, selected traits, touch targets)

## Critérios de Sucesso
- Tela mais curta e modular (subviews), sem informações duplicadas.
- Hierarquia clara: modo, cidade, filtros e CTA.
- Melhor legibilidade e consistência visual.

## Dependências
- Tarefa 4.0 (para garantir o fluxo final antes de refatorar layout grande)

## Observações
- A refator deve seguir boas práticas das skills de refactor/performance SwiftUI.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/swiftui</domain>
<type>implementation</type>
<scope>performance</scope>
<complexity>high</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 5.0: Refatorar tela “Escolher” (PreferencesView) no padrão Eden

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

A tela atual mistura muitos cards e estados em um único arquivo grande, o que causa confusão para o usuário e risco de performance (recomputações). Vamos reorganizar com uma arquitetura de subviews e uma hierarquia visual clara, inspirada no Eden UI kit.

<requirements>
- Remover redundâncias (mesmas informações em múltiplos lugares sem necessidade).
- Garantir CTA coerente por modo (Minha Lista vs Perto de mim).
- Refatorar para subviews com inputs explícitos, reduzindo recomputação.
- Garantir touch targets mínimos e acessibilidade.
</requirements>

## Subtarefas

- [ ] 5.1 Auditar layout atual e listar redundâncias
- [ ] 5.2 Extrair seções em subviews (header, segment, city card, filtros, CTA)
- [ ] 5.3 Ajustar spacing/typography/visual hierarchy com base no Eden
- [ ] 5.4 Validar acessibilidade e comportamento em diferentes tamanhos de fonte

## Detalhes de Implementação

Referenciar “Riscos Conhecidos” (SwiftUI performance) e “Conformidade com Padrões” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Tela organizada, sem duplicidades, e com CTA evidente.
- Código mais modular e fácil de manter.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/DesignSystem/AppColors.swift`


