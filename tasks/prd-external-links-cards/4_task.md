# [4.0] Componente UI: RestaurantCard (Deliverio style) + ações rápidas (L)

## Objetivo
- Criar um card reutilizável e moderno para restaurantes/lugares, com imagem, informações essenciais e ações rápidas (TripAdvisor/iFood/99/rota).

## Subtarefas
- [x] 4.1 Definir layout e estados (loading/placeholder) alinhados ao design system do app
- [x] 4.2 Implementar botões de ação rápida (com acessibilidade e touch targets)
- [x] 4.3 Integrar carregamento de imagem (manual/OpenGraph) sem travar UI

## Critérios de Sucesso
- Card consistente e reutilizável em “Minha base” e “Perto de mim”.
- Ações rápidas funcionam com fallback 99 → rota no Maps.

## Dependências
- 2.0 Editor de links (para curadoria)
- 3.0 OpenGraph resolver (para imagem)

## Observações
- Não importar assets do pacote UI8; apenas estilo/layout/cores com assets próprios.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/ui</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 4.0: RestaurantCard (Deliverio style) + ações rápidas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa entrega o componente visual central da feature. O card deve ter hierarquia clara e permitir ações rápidas. Deve funcionar tanto para `Restaurant` (minha base) quanto para resultados do Apple Maps (via `NearbyPlace` ou wrapper).

<requirements>
- Card com imagem (1:1 ou 4:3), título, subtítulo (categoria/endereço), e badges (rating/distance quando disponível).
- Botões de ação rápida com ícone + label (TripAdvisor, iFood, 99/Mapa).
- Touch targets ≥ 44×44pt e `accessibilityLabel`/`accessibilityHint`.
- Suporte a loading/placeholder de imagem.
</requirements>

## Subtarefas

- [x] 4.1 Implementar `RestaurantCard` com layout e estilos (inspirado no Deliverio, usando `AppColors`)
- [x] 4.2 Implementar `ExternalLinkOpener`/helper e wiring dos botões
- [x] 4.3 Integrar imagem: `imageURL` manual → OpenGraph → placeholder

## Detalhes de Implementação

Referenciar `techspec.md` (seção “UI” e “Pontos de Integração”). Seguir o guia `.cursor/skills/design/skill-design.md` para cards, espaçamentos e acessibilidade.

## Critérios de Sucesso

- Card renderiza sem layout quebrado em diferentes tamanhos de tela.
- Botões aparecem somente quando aplicável; fallback de rota funciona.
- Performance: scroll fluido (cache + evitar recomputes excessivos).

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Components/` (novo componente)
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/DesignSystem/AppColors.swift`

