# [4.0] Importação: Substituir tudo vs Mesclar por ID (M/L)

## Objetivo
- Implementar a escolha do modo de importação (substituir vs mesclar) e as regras de aplicação, garantindo que não haja perda de dados acidental.

## Subtarefas
- [ ] 4.1 Implementar UI de escolha do modo (Replace vs Merge) a partir do preview
- [ ] 4.2 Implementar confirmação explícita para “Substituir tudo” (ação destrutiva)
- [ ] 4.3 Definir regras de merge por ID para Restaurant e Visit (upsert, dedupe, conflitos)

## Critérios de Sucesso
- Usuário escolhe o modo antes de qualquer escrita em SwiftData.
- “Substituir tudo” exige confirmação e mostra impacto.
- “Mesclar por ID” não apaga dados que não estão no backup.

## Dependências
- 3.0 Import: seletor de arquivo + validação + preview

## Observações
- Preferir regras simples e previsíveis (ex.: upsert; visitas deduplicadas por `id`).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/backup</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 4.0: Importação: Substituir tudo vs Mesclar por ID

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa cobre o ponto mais sensível do fluxo: como aplicar o backup no banco local. O usuário precisa entender a diferença entre substituir e mesclar, e substituição precisa de confirmação.

<requirements>
- UI de escolha do modo de importação
- Confirmação para operação destrutiva
- Regras determinísticas de merge por ID
</requirements>

## Subtarefas

- [ ] 4.1 Tela/Sheet de escolha do modo (Replace vs Merge)
- [ ] 4.2 Confirmação “Substituir tudo” com copy clara
- [ ] 4.3 Documentar regras de merge (comentários + Tech Spec)

## Detalhes de Implementação

- Ver `techspec.md`: **Design de Implementação** (BackupImportMode) e **Considerações Técnicas** (riscos e mitigação).

## Critérios de Sucesso

- Não há “dead-end”: usuário sempre consegue cancelar.
- Operação destrutiva tem confirmação e não é acionada por engano.

## Arquivos relevantes
- `tasks/prd-casal-sync/techspec.md`

