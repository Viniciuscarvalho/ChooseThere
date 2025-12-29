# [3.0] Import: seletor de arquivo + validação + preview (M)

## Objetivo
- Implementar o fluxo de importação: selecionar o `chooseThere_backup.json`, validar e apresentar um preview antes de aplicar a importação.

## Subtarefas
- [ ] 3.1 Implementar seleção de arquivo (fileImporter) para `.json`
- [ ] 3.2 Decodificar e validar backup (schema/version) usando `BackupCodec`
- [ ] 3.3 Criar `BackupImportPreviewView` (contagens, data, avisos) e navegação para escolha do modo de import

## Critérios de Sucesso
- Usuário consegue selecionar um `.json` e ver um preview com contagens (restaurantes/visitas).
- Backups inválidos não aplicam nenhuma mudança e exibem erro claro.

## Dependências
- 1.0 Contrato do backup (schema v1) + codec/validação

## Observações
- A importação deve ser segura: nenhuma escrita em SwiftData antes do usuário confirmar o modo (substituir vs mesclar).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/backup</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 3.0: Import: seletor de arquivo + validação + preview

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O import começa com a seleção do arquivo e passa por validação (JSON + schemaVersion). Antes de aplicar, o usuário precisa ver um preview e entender o impacto (contagens e avisos).

<requirements>
- Importar arquivo `.json` via seletor do sistema
- Validar e mostrar preview (sem aplicar mudanças ainda)
- Mensagens de erro claras e sem efeitos colaterais
</requirements>

## Subtarefas

- [ ] 3.1 Integrar `fileImporter` e leitura do arquivo
- [ ] 3.2 Decode + validação (BackupCodec)
- [ ] 3.3 View de preview + navegação para o passo seguinte

## Detalhes de Implementação

- Ver `techspec.md`: **Pontos de Integração** (SwiftUI file importer) e **Tratamento de erros**.

## Critérios de Sucesso

- Arquivo inválido não altera base local.
- Preview mostra dados suficientes para decidir (Substituir vs Mesclar).

## Arquivos relevantes
- `tasks/prd-casal-sync/techspec.md`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`

