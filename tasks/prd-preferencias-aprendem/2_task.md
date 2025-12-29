# [2.0] Regras de aprendizado a partir de avaliações (M)

## Objetivo
- Implementar `PreferenceLearningService` que atualiza pesos (tags/categorias) com base nas avaliações, com clamp e regras simples.

## Subtarefas
- [ ] 2.1 Definir regra inicial de atualização por rating (1–5) e clamp
- [ ] 2.2 Implementar atualização de pesos de tags e categoria a partir de um evento de avaliação
- [ ] 2.3 Garantir que o aprendizado respeite `learningEnabled` (se desligado, não altera nada)

## Critérios de Sucesso
- Pesos aumentam/diminuem conforme rating e ficam dentro do intervalo permitido.
- Com `learningEnabled == false`, nenhuma atualização ocorre.

## Dependências
- 1.0 Modelo + persistência de preferências aprendidas

## Observações
- Manter regras simples e iteráveis (ajustáveis por tuning futuro).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/preferences</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 2.0: Regras de aprendizado a partir de avaliações

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

As avaliações (visitas) são a fonte de sinal. Esta tarefa implementa regras de atualização de pesos que são transparentes e testáveis.

<requirements>
- Atualizar pesos por rating (1–5)
- Clamp para evitar extremos
- Respeitar toggle de habilitar/desabilitar
</requirements>

## Subtarefas

- [ ] 2.1 Implementar regra e clamp
- [ ] 2.2 Atualizar pesos de tags e categoria
- [ ] 2.3 Persistir no store após atualização

## Detalhes de Implementação

- Ver `techspec.md`: **Regras de atualização** e **Considerações Técnicas**.

## Critérios de Sucesso

- Testes unitários cobrem atualização e clamp.

## Arquivos relevantes
- `tasks/prd-preferencias-aprendem/techspec.md`

