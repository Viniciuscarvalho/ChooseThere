# [7.0] Testes unitários do backup/import (M)

## Objetivo
- Adicionar testes unitários para garantir que encode/decode, validação e importação (replace/merge) sejam estáveis e não dependam de UI ou rede.

## Subtarefas
- [ ] 7.1 Criar `BackupCodecTests` (roundtrip + schemaVersion inválida + JSON inválido)
- [ ] 7.2 Criar `BackupImportServiceTests` cobrindo replaceAll e mergeByID com dados sintéticos
- [ ] 7.3 Garantir testes determinísticos (sem MapKit, sem rede, sem dependência de ordem instável)

## Critérios de Sucesso
- Suite de testes passa e cobre cenários críticos (erro, replace, merge, dedupe).
- Testes rodam offline e não dependem de iOS UI.

## Dependências
- 1.0 Contrato do backup (schema v1) + codec/validação
- 5.0 Persistência SwiftData: upsert de Restaurant/Visit + integridade

## Observações
- Usar fakes/in-memory para repositórios ou SwiftData container em memória, conforme padrão do projeto.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 7.0: Testes unitários do backup/import

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Testes são essenciais para evoluir o schema e o fluxo sem quebrar import/export. O foco é cobertura de regras fáceis de regressão: versionamento, validação, replaceAll e mergeByID.

<requirements>
- Testar codec (encode/decode) e validações
- Testar import replaceAll e mergeByID
- Garantir determinismo e isolamento dos testes
</requirements>

## Subtarefas

- [ ] 7.1 Implementar testes do codec e validação
- [ ] 7.2 Implementar testes do serviço de importação
- [ ] 7.3 Cobrir casos de erro e conflitos simples

## Detalhes de Implementação

- Ver `techspec.md`: **Abordagem de Testes**.

## Critérios de Sucesso

- Testes passam localmente e em CI (quando configurado).
- Não há dependência de rede ou APIs externas.

## Arquivos relevantes
- `tasks/prd-casal-sync/techspec.md`
- `ChooseThere/ChooseThere/ChooseThereTests/*`

