# [6.0] Aplicar cards no “Perto de mim” (Apple Maps + Minha base) (M)

## Objetivo
- Exibir resultados do modo “Perto de mim” em cards com ações rápidas e comportamento consistente.

## Subtarefas
- [x] 6.1 Para fonte "Minha base": exibir `RestaurantCard` com distância/ações
- [x] 6.2 Para fonte "Apple Maps": criar card equivalente (NearbyPlaceCard) com rota no mapa e CTA "Adicionar links" quando aplicável
- [x] 6.3 Garantir estados de permissão/loading/noResults intactos

## Critérios de Sucesso
- Resultados próximos aparecem organizados e com ações rápidas.
- Fallback do 99 (rota no mapa) sempre funciona quando não há link.

## Dependências
- 4.0 RestaurantCard
- 2.0 Editor de links (para CTA “Adicionar links”)

## Observações
- Para resultados do Apple Maps, não existe entidade `Restaurant` persistida; decidir UX para salvar links (ex.: criar restaurante na base ou associar link depois).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/ui</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 6.0: Aplicar cards no “Perto de mim”

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O modo “Perto de mim” hoje já suporta fonte “Minha base” e “Apple Maps”. Esta tarefa coloca ambos no padrão visual de cards e adiciona ações rápidas/fallback.

<requirements>
- Para fonte localBase: cards de `Restaurant` com distância e ações rápidas.
- Para fonte appleMaps: card de `NearbyPlace` com rota e link externo quando existir.
- Manter estados (sem permissão / carregando / vazio / erro).
</requirements>

## Subtarefas

- [x] 6.1 Integrar cards nos resultados localBase (usando `RestaurantCard`)
- [x] 6.2 Criar card para `NearbyPlace` (ou adaptar `RestaurantCard` com modelo view) e integrar
- [x] 6.3 Revisar UX para "Adicionar links" a partir de um `NearbyPlace` (decisão: criar registro local ou apenas abrir busca/rota)

## Detalhes de Implementação

Referenciar `techspec.md` (seção “UI” e “Fallback 99”). Priorizar uma implementação simples e clara para o usuário.

## Critérios de Sucesso

- Cards aparecem em ambos os resultados.
- Rota no mapa funciona em Apple Maps e no fallback do 99.
- UX não conflita com fluxo atual de sorteio/detalhe.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/NearbyPlaceDetailView.swift`

