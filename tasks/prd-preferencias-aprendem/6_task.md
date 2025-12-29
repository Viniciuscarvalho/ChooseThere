# [6.0] Integração no fluxo de avaliação (VisitModel) (M)

## Objetivo
- Integrar o aprendizado no momento em que o usuário avalia um restaurante (criação/atualização de `VisitModel`), atualizando pesos e persistindo.

## Subtarefas
- [ ] 6.1 Identificar o ponto de gravação de avaliação (RatingView/VisitRepository) e inserir hook do aprendizado
- [ ] 6.2 Atualizar pesos de forma assíncrona/segura (sem travar UI)
- [ ] 6.3 Garantir que o fluxo atual de avaliação não seja quebrado e que o aprendizado respeite o toggle

## Critérios de Sucesso
- Ao avaliar, pesos são atualizados (quando habilitado).
- Fluxo de avaliação continua funcionando exatamente como antes.

## Dependências
- 2.0 Regras de aprendizado a partir de avaliações
- 5.0 Configurações: toggle, reset e limite N

## Observações
- Evitar efeitos colaterais: atualização de pesos não deve falhar a avaliação.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/rating</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 6.0: Integração no fluxo de avaliação (VisitModel)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O sistema aprende principalmente de avaliações. A integração deve acontecer no ponto em que a visita é registrada, garantindo persistência do aprendizado e mantendo o fluxo atual intacto.

<requirements>
- Hook no fluxo de avaliação para aplicar aprendizado
- Não degradar UX (sem travar, sem erros visíveis)
- Respeitar toggle de habilitar/desabilitar
</requirements>

## Subtarefas

- [ ] 6.1 Identificar ponto de gravação e integrar serviço
- [ ] 6.2 Persistir preferências após update
- [ ] 6.3 Testes de regressão do fluxo

## Detalhes de Implementação

- Ver `techspec.md`: **Pontos de Integração** (VisitRepository/VisitModel).

## Critérios de Sucesso

- Pesos atualizam quando o usuário avalia.
- Se o aprendizado falhar, a avaliação ainda é salva.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`
- `tasks/prd-preferencias-aprendem/techspec.md`

