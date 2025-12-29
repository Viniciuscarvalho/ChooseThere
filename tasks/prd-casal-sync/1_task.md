# [1.0] Contrato do backup (schema v1) + codec/validação (M)

## Objetivo
- Definir o formato versionado do `chooseThere_backup.json` (V1) e implementar encode/decode + validação robusta para garantir import/export determinísticos e seguros.

## Subtarefas
- [ ] 1.1 Definir modelos `BackupV1`, `BackupRestaurant`, `BackupVisit` (Codable) e campos mínimos
- [ ] 1.2 Implementar `BackupCodec` (encode/decode) e validações (schemaVersion, campos obrigatórios, integridade básica)
- [ ] 1.3 Definir `BackupImportMode` e `BackupImportResult` (tipos compartilhados)

## Critérios de Sucesso
- `chooseThere_backup.json` tem `schemaVersion` e `createdAt`.
- Decode falha de forma clara para JSON inválido ou versão incompatível.
- Validação detecta inconsistências básicas (ex.: visita sem `restaurantId`).

## Dependências
- PRD/Tech Spec desta pasta.

## Observações
- O backup desta fase inclui **lista inteira de restaurantes do usuário + favoritos + visitas/avaliações**.
- Evitar dependências de MapKit/rede e manter o contrato compatível com evoluções futuras (V2+).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/backup</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Contrato do backup (schema v1) + codec/validação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O contrato do backup é a base para export/import. Precisamos de um schema simples, versionado e validável. A validação deve impedir que um arquivo inválido aplique mudanças na base local.

<requirements>
- Definir `schemaVersion` (V1) e `createdAt`
- Modelar restaurantes e visitas de forma compatível com `RestaurantModel` e `VisitModel`
- Implementar encode/decode e validações com mensagens claras
</requirements>

## Subtarefas

- [ ] 1.1 Criar modelos Codable do backup (V1)
- [ ] 1.2 Implementar `BackupCodec` e validações de compatibilidade
- [ ] 1.3 Documentar regras de validação (comentários + Tech Spec)

## Detalhes de Implementação

- Ver `techspec.md`: **Modelos de Dados** e **Pontos de Integração** (SwiftUI, SwiftData).

## Critérios de Sucesso

- Backup V1 é gerado e validado localmente sem rede.
- Erros de parse/validação retornam mensagens de erro úteis.

## Arquivos relevantes
- `tasks/prd-casal-sync/techspec.md`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`

