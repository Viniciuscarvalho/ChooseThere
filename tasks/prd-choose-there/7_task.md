# [7.0] Tela Roleta (S/M)

## Objetivo
- Implementar a tela de roleta/animação do sorteio, simples e divertida, exibindo “quase escolhidos”.

## Subtarefas
- [ ] 7.1 Escolher e implementar uma animação (ex.: shuffle de cards)
- [ ] 7.2 Exibir 3–6 “quase escolhidos”
- [ ] 7.3 Implementar botão “Sortear de novo” com limite (ex.: 3)
- [ ] 7.4 Navegar automaticamente para Resultado ao finalizar

## Critérios de Sucesso
- Animação roda e finaliza em um restaurante
- Re-roll respeita limite e evita repetição

## Dependências
- 4.0 Repositórios + regras de sorteio
- 5.0 Router e navegação

## Observações
- Manter performance e simplicidade; sem complexidade excessiva.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/roulette</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 7.0: Tela Roleta

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Criar uma etapa divertida entre preferências e resultado, aumentando o engajamento sem aumentar complexidade.

<requirements>
- Mostrar “quase escolhidos”
- Re-roll limitado e opcional
</requirements>

## Subtarefas

- [ ] 7.1 Implementar animação
- [ ] 7.2 Integrar re-roll
- [ ] 7.3 Navegar para resultado

## Detalhes de Implementação
- Referência: `prd.md` (3.x) e `techspec.md` (Presentation)

## Critérios de Sucesso

- Roleta retorna um restaurante selecionado e navega ao resultado

## Arquivos relevantes
- `tasks/prd-choose-there/prd.md`
- `tasks/prd-choose-there/techspec.md`






