# [8.0] UX: estados, permissões e acessibilidade (S/M)

## Objetivo
- Garantir que o modo “Perto de mim” e Configurações tenham estados de UI consistentes (loading/erro/sem permissão/sem resultados) e acessibilidade mínima (labels, targets, textos).

## Subtarefas
- [x] 8.1 Definir componentes/estados reutilizáveis (empty/error views)
- [x] 8.2 Copy e instruções para permissão negada + ação "Abrir Ajustes"
- [x] 8.3 Revisar acessibilidade (labels, hints, tamanhos de toque)

## Critérios de Sucesso
- O usuário entende porque não há resultados (sem permissão vs sem lugares).
- Fluxos principais não ficam “travados” sem saída.

## Dependências
- 5.0 “Perto de mim” (fonte: Minha base) — filtro por distância
- 6.0 “Perto de mim” (fonte: Apple Maps) — busca + cache
- 3.0 Configurações: alterar cidade e preferências

## Observações
- Seguir padrões HIG (skills de design).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/ux</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 8.0: UX: estados, permissões e acessibilidade

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Consolidar estados e mensagens para o novo fluxo, cobrindo o caso mais comum de fricção: permissão de localização negada e busca Apple Maps falhando/sem resultados.

<requirements>
- Estado “Sem permissão” com instrução e CTA para Ajustes
- Estado “Sem resultados” com sugestão de aumentar raio/trocar tipo/fonte
- Estado “Erro” para falhas do MapKit/camada de cache
- Acessibilidade: labels/hints e touch targets mínimos
</requirements>

## Subtarefas

- [x] 8.1 Implementar views de estado (empty/error) reutilizáveis
- [x] 8.2 Ajustar copy e CTAs de permissão
- [x] 8.3 Revisão de acessibilidade nas telas novas/alteradas

## Detalhes de Implementação

- Tech Spec: **Pontos de Integração** (CoreLocation/MapKit) e **Requisitos Especiais**
- Referências: `PreferencesView`, `OnboardingView`, e novas telas do “Perto de mim”

## Critérios de Sucesso

- Estados aparecem corretamente e guiam o usuário
- Não há dead-ends na navegação
- Acessibilidade mínima presente (labels/hints)

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/OnboardingView.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Components/*` (se necessário)

