# [8.0] QA checklist + documentação (S)

## Objetivo
- Garantir que o fluxo de export/import seja fácil de testar manualmente e bem documentado para evitar dúvidas e erros do usuário.

## Subtarefas
- [ ] 8.1 Criar checklist de QA manual (casos felizes e erros) para export/import
- [ ] 8.2 Ajustar copy final (privacidade, confirmação de substituição, erros de versão)
- [ ] 8.3 Documentar formato do backup (V1) e regras de import (replace/merge) no `techspec.md` (se necessário)

## Critérios de Sucesso
- Checklist cobre cenários principais (export, import válido, import inválido, replace, merge).
- Mensagens de UI são claras e consistentes.

## Dependências
- 6.0 Integração em Configurações + UX de confirmação/feedback

## Observações
- Esta tarefa reduz suporte e acelera validação durante iteração.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/ux</domain>
<type>documentation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 8.0: QA checklist + documentação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Depois de implementar, precisamos validar rapidamente e garantir que o usuário entenda o que está acontecendo (principalmente no modo “Substituir tudo”).

<requirements>
- Checklist manual de QA
- Copy final consistente e claro
- Documentação mínima do formato e regras
</requirements>

## Subtarefas

- [ ] 8.1 Checklist de QA manual
- [ ] 8.2 Revisão de copy e acessibilidade
- [ ] 8.3 Atualizar documentação conforme necessário

## Detalhes de Implementação

- Ver `techspec.md`: **Riscos Conhecidos** e **Requisitos Especiais**.

## Critérios de Sucesso

- Checklist usado para validar o fluxo fim-a-fim.
- Usuário não fica preso sem saída em caso de erro.

## Arquivos relevantes
- `tasks/prd-casal-sync/prd.md`
- `tasks/prd-casal-sync/techspec.md`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`

