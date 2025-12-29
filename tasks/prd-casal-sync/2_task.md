# [2.0] Export: gerar `chooseThere_backup.json` + Share Sheet (M)

## Objetivo
- Implementar o fluxo de exportação do backup (gerar JSON e abrir Share Sheet/Files) a partir de `SettingsView`.

## Subtarefas
- [ ] 2.1 Implementar `BackupExportService` para montar `BackupV1` a partir de SwiftData (restaurants + visits)
- [ ] 2.2 Gerar arquivo `chooseThere_backup.json` e expor via Share Sheet (ShareLink/fileExporter conforme iOS)
- [ ] 2.3 Adicionar aviso/confirm de privacidade antes de compartilhar (copy simples)

## Critérios de Sucesso
- Usuário consegue exportar um arquivo `chooseThere_backup.json` via WhatsApp/AirDrop/Files.
- O arquivo contém restaurantes e visitas, com `schemaVersion` e `createdAt`.

## Dependências
- 1.0 Contrato do backup (schema v1) + codec/validação

## Observações
- Evitar travar UI: gerar JSON em Task e apresentar estado de loading/erro.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/backup</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 2.0: Export: gerar `chooseThere_backup.json` + Share Sheet

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O export deve ser um caminho feliz e rápido: um toque em “Exportar backup” gera o arquivo e abre o Share Sheet. Também precisamos deixar claro que o usuário está compartilhando dados pessoais (histórico e notas).

<requirements>
- Montar `BackupV1` a partir dos dados locais (SwiftData)
- Gerar `chooseThere_backup.json` e disponibilizar para share
- Exibir aviso de privacidade antes de exportar
</requirements>

## Subtarefas

- [ ] 2.1 Implementar montagem do payload (restaurants + visits)
- [ ] 2.2 Integrar com Share Sheet / Files (SwiftUI)
- [ ] 2.3 Feedback de sucesso/erro (UI)

## Detalhes de Implementação

- Ver `techspec.md`: **Pontos de Integração** (SwiftUI `ShareLink`/`fileExporter`) e **Arquitetura do Sistema**.

## Critérios de Sucesso

- O arquivo exportado abre e valida no importador do próprio app.
- A UI não fica travada durante a geração.

## Arquivos relevantes
- `tasks/prd-casal-sync/techspec.md`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataVisitRepository.swift`

