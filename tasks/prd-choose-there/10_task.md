# [10.0] Histórico (M)

## Objetivo
- Implementar o histórico de visitas com filtros e tela de detalhes (mapa + avaliação), permitindo editar.

## Subtarefas
- [ ] 10.1 Lista de visitas (ordem por data)
- [ ] 10.2 Filtros: melhores avaliados, voltaria, não repetir, por categoria/tag
- [ ] 10.3 Tela de detalhe com mapa e ações (editar avaliação, abrir rota)
- [ ] 10.4 Edição de avaliação (update no SwiftData)

## Critérios de Sucesso
- Histórico navegável e filtrável
- Edição persiste e reflete imediatamente

## Dependências
- 9.0 Avaliação pós-visita
- 5.0 Router e navegação

## Observações
- Estado vazio deve ter CTA para sortear.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/history</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 10.0: Histórico

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Exibir e gerenciar o histórico de visitas, incluindo filtros úteis e detalhe completo com mapa e avaliação.

<requirements>
- Lista + filtros
- Detalhe + mapa + editar avaliação
</requirements>

## Subtarefas

- [ ] 10.1 Listagem e filtros
- [ ] 10.2 Detalhe e edição

## Detalhes de Implementação
- Referência: `prd.md` (6.x) e `techspec.md` (VisitRepository, Mapas)

## Critérios de Sucesso

- Filtros funcionam e edição persiste

## Arquivos relevantes
- `tasks/prd-choose-there/prd.md`
- `tasks/prd-choose-there/techspec.md`







