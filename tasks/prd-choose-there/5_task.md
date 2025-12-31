# [5.0] Router e navegação (M)

## Objetivo
- Implementar navegação baseada em Router (sem `NavigationStack`) para suportar o fluxo: Preferências → Roleta → Resultado → Avaliação → Histórico.

## Subtarefas
- [ ] 5.1 Definir enum de rotas e parâmetros (ex.: resultado com restaurantId)
- [ ] 5.2 Implementar Router (push/pop/present) e estado observável
- [ ] 5.3 Conectar RootView e telas ao Router
- [ ] 5.4 Garantir transições simples e previsíveis (sem acoplamento)

## Critérios de Sucesso
- Fluxo navega entre telas sem usar `NavigationStack`
- Router testável (lógica sem dependência de View)

## Dependências
- 1.0 Fundação do projeto

## Observações
- Manter API do Router pequena e fácil de evoluir.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/routing</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 5.0: Router e navegação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Criar navegação customizada e explícita, evitando `NavigationStack`, para reduzir acoplamento e facilitar evolução do fluxo.

<requirements>
- Não usar `NavigationStack`
- Router como fonte de verdade do estado de navegação
</requirements>

## Subtarefas

- [ ] 5.1 Definir rotas e parâmetros
- [ ] 5.2 Implementar Router
- [ ] 5.3 Integrar com RootView

## Detalhes de Implementação
- Referência: `techspec.md` (Decisões Principais: Router)

## Critérios de Sucesso

- Navegação funcional entre telas principais

## Arquivos relevantes
- `tasks/prd-choose-there/techspec.md`






