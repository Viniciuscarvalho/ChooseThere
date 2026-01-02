# [7.0] Performance audit SwiftUI + ajustes de recomputação (S/M)

## Objetivo
- Identificar e corrigir pontos de recomputação/re-renderização excessiva na tela “Escolher” e no fluxo “Perto de mim”, garantindo boa responsividade.

## Subtarefas
- [ ] 7.1 Aplicar checklist de `@.cursor/skills/swiftui-performance-audit/` nos arquivos impactados
- [ ] 7.2 Reduzir trabalho no `body` (mover cálculos, usar subviews, evitar capturas desnecessárias)
- [ ] 7.3 Validar que mudanças de filtros não causam buscas redundantes nem “jank” no scroll

## Critérios de Sucesso
- Navegação/scroll suaves na tela “Escolher”.
- Mudanças de estado não geram recomputações caras.
- Sem regressões visuais.

## Dependências
- Tarefa 5.0

## Observações
- Usar medições simples (log/Instrumentos) quando necessário, sem over-engineering.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/performance</domain>
<type>testing</type>
<scope>performance</scope>
<complexity>medium</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 7.0: Performance audit SwiftUI + ajustes de recomputação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Com a refator do layout e a integração do fluxo nearby, é importante garantir que a tela “Escolher” continue performática. Esta tarefa aplica um audit focado e ajustes pontuais.

<requirements>
- Aplicar as recomendações das skills de performance/refactor SwiftUI.
- Evitar recomputações caras e estados derivados no `body`.
- Garantir que mudanças de filtros não disparem operações redundantes.
</requirements>

## Subtarefas

- [ ] 7.1 Rodar audit de performance (checklist)
- [ ] 7.2 Implementar otimizações pontuais (subviews, state derivado, Equatable quando fizer sentido)
- [ ] 7.3 Validar em device/simulador com scroll e mudanças de filtros

## Detalhes de Implementação

Referenciar “Riscos Conhecidos” e “Conformidade com Padrões” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- UX suave e responsiva.
- Sem regressões funcionais.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`


