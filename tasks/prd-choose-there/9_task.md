# [9.0] Avaliação pós-visita (M)

## Objetivo
- Implementar tela/flow para marcar como visitado e salvar avaliação (1–5, tags rápidas, comentário, match).

## Subtarefas
- [ ] 9.1 UI de avaliação (estrelas 1–5) e toggle match
- [ ] 9.2 Tags rápidas (Voltaria, Bom custo, etc.)
- [ ] 9.3 Persistir `VisitModel` via `VisitRepository`
- [ ] 9.4 Ação “Salvar” retorna ao resultado ou histórico

## Critérios de Sucesso
- Avaliação salva e aparece no histórico
- Campos opcionais funcionam sem travar fluxo

## Dependências
- 4.0 Repositórios + regras de sorteio
- 5.0 Router e navegação

## Observações
- Aplicar cores: match/sucesso Mint; avisos/erro Tomato.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/rating</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 9.0: Avaliação pós-visita

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Registrar a visita e avaliação do restaurante para alimentar histórico e filtros, mantendo o app offline-first.

<requirements>
- Nota 1–5
- Tags rápidas + comentário opcional
- “Foi match pro gosto dela?” (boolean)
</requirements>

## Subtarefas

- [ ] 9.1 UI de avaliação
- [ ] 9.2 Persistir visita
- [ ] 9.3 Integrar com Router

## Detalhes de Implementação
- Referência: `prd.md` (5.x) e `techspec.md` (VisitModel/VisitRepository)

## Critérios de Sucesso

- Visita aparece no histórico imediatamente

## Arquivos relevantes
- `tasks/prd-choose-there/prd.md`
- `tasks/prd-choose-there/techspec.md`

