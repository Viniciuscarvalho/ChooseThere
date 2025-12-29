# [6.0] Integração em Configurações + UX de confirmação/feedback (M)

## Objetivo
- Expor o fluxo completo de export/import em `SettingsView` com UX clara: aviso de privacidade, preview, confirmação de substituição e feedback de sucesso/erro.

## Subtarefas
- [ ] 6.1 Adicionar seção “Coleção do casal” em `SettingsView` (Exportar/Importar)
- [ ] 6.2 Implementar telas/sheets necessárias (preview, escolha do modo, progresso)
- [ ] 6.3 Adicionar mensagens de sucesso/erro e logs básicos para debug

## Critérios de Sucesso
- Fluxo completo acessível a partir das Configurações.
- Não há dead-ends: sempre dá para cancelar ou voltar.
- Mensagens claras para erros comuns (arquivo inválido, versão incompatível).

## Dependências
- 2.0 Export: gerar `chooseThere_backup.json` + Share Sheet
- 3.0 Import: seletor de arquivo + validação + preview
- 4.0 Importação: Substituir tudo vs Mesclar por ID
- 5.0 Persistência SwiftData: upsert de Restaurant/Visit + integridade

## Observações
- Seguir HIG e manter consistência visual com `SettingsView` atual.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded
# Nota: Implementado como parte das Tasks 2.0, 3.0 e 4.0 (SettingsView completa)

<task_context>
<domain>ios/app/settings</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 6.0: Integração em Configurações + UX de confirmação/feedback

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Depois que os serviços existirem, precisamos integrar na UI e garantir uma experiência segura: avisar sobre privacidade, mostrar preview, confirmar substituição e dar feedback ao final.

<requirements>
- Export/Import acessíveis via Configurações
- Preview e escolha do modo antes de aplicar import
- Feedback de sucesso/erro com copy claro
</requirements>

## Subtarefas

- [ ] 6.1 Adicionar botões e navegação em Settings
- [ ] 6.2 Implementar sheets/overlays de preview e confirmação
- [ ] 6.3 Validar acessibilidade (labels/hints)

## Detalhes de Implementação

- Ver `techspec.md`: **Arquitetura do Sistema** (UI) e **Pontos de Integração** (SwiftUI).

## Critérios de Sucesso

- Fluxo completo executável por um usuário sem instrução extra.
- Mensagens guiam o usuário em erros comuns.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`

