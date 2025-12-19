# [6.0] Tela Preferências + filtros (M)

## Objetivo
- Implementar a tela inicial de preferências com chips/tags e filtros (raio, preço, evitar) usando a identidade visual definida.

## Subtarefas
- [ ] 6.1 Implementar UI de chips/tags (seleção múltipla)
- [ ] 6.2 Implementar filtros de raio e faixa de preço
- [ ] 6.3 Implementar seleção de tags “Evitar”
- [ ] 6.4 Aplicar DesignSystem (CTA Mango, erro Tomato, sucesso Mint, background Porcelain)
- [ ] 6.5 Conectar com o fluxo de sorteio (aciona Router → Roleta)

## Critérios de Sucesso
- Tela define `PreferenceContext` e inicia sorteio
- UI consistente com a paleta e estados de erro/sucesso

## Dependências
- 4.0 Repositórios + regras de sorteio
- 5.0 Router e navegação

## Observações
- Se nenhuma tag desejada estiver selecionada, permitir sortear com universo completo (PRD 2.7).

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/preferences</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 6.0: Tela Preferências + filtros

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Criar a tela principal do app, responsável por definir o contexto do sorteio e disparar o fluxo.

<requirements>
- Chips/tags para “Hoje estamos a fim de…”
- Filtros: raio, preço, evitar
- Aplicar identidade visual do app
</requirements>

## Subtarefas

- [ ] 6.1 UI de chips/tags
- [ ] 6.2 Filtros básicos
- [ ] 6.3 Aplicar tema (cores)
- [ ] 6.4 Integrar com Router

## Detalhes de Implementação
- Referência: `prd.md` (2.x) e `techspec.md` (Presentation, DesignSystem)

## Critérios de Sucesso

- Botão principal “Sortear” com Mango e texto Ink
- Estados vazios/sem resultados comunicados com Tomato quando aplicável

## Arquivos relevantes
- `tasks/prd-choose-there/prd.md`
- `tasks/prd-choose-there/techspec.md`



