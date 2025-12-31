# [7.0] QA + testes + polish de acessibilidade/performance (M)

## Objetivo
- Consolidar a feature com testes unitários essenciais, QA manual e ajustes de acessibilidade/performance.

## Subtarefas
- [ ] 7.1 Testes unitários: parser OpenGraph, validação de URLs
- [ ] 7.2 QA manual guiado (Minha base e Perto de mim) + checagem de regressões
- [ ] 7.3 Ajustes finais: acessibilidade, estados vazios, placeholders e cache

## Critérios de Sucesso
- Fluxos principais funcionam sem crashes.
- Cards e ações rápidas têm boa acessibilidade.
- UX consistente com o restante do app.

## Dependências
- 1.0–6.0 concluídas

## Observações
- Use o guia de crash debugging se aparecerem problemas em parsing/rede/UI.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 7.0: QA + testes + polish

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Depois de integrar modelos, OpenGraph e cards, precisamos garantir qualidade: testes de parsing e validação, além de QA manual para comportamentos de rede, cache e ações externas.

<requirements>
- Ter testes unitários para parsing de `og:image` e validação de URLs.
- Realizar QA manual com e sem links preenchidos.
- Confirmar que falhas de rede não degradam a UI (placeholder + retry implícito ao reabrir).
</requirements>

## Subtarefas

- [ ] 7.1 Criar testes unitários com fixtures HTML
- [ ] 7.2 Validar comportamento em dispositivos/tamanhos diferentes (incluindo Dynamic Type)
- [ ] 7.3 Revisar performance no scroll e reduzir recomputes desnecessários

## Detalhes de Implementação

Referenciar `techspec.md` (seção “Abordagem de Testes”). Seguir `.cursor/skills/ios-development-skill/skill-ios.md` para async tests e isolamento.

## Critérios de Sucesso

- Testes passam.
- Fluxo “Minha base” e “Perto de mim” sem regressões.
- Acessibilidade ok (touch targets, labels, contraste).

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThereTests/` (novos testes)
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`

