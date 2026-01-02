# [3.0] Implementar regras SP-only + fallback da base local (JSON) (S/M)

## Objetivo
- Garantir que a base local (seed/JSON) seja usada no modo “Perto de mim” apenas quando a cidade selecionada for São Paulo (SP), e apenas como fallback.

## Subtarefas
- [ ] 3.1 Definir critério de “São Paulo” com base em `AppSettingsStorage` (cidade/estado/selectedCityKey)
- [ ] 3.2 Ocultar/desabilitar “Minha base” fora de SP no modo “Perto de mim” e forçar Apple Maps
- [ ] 3.3 Implementar fallback em SP (Apple Maps falha/sem resultados → base local)

## Critérios de Sucesso
- Fora de SP, não existe caminho de UI nem de execução que use JSON/local base no modo nearby.
- Em SP, quando Apple Maps não retorna resultados, o app consegue cair no fallback local (se existir).

## Dependências
- Tarefa 2.0

## Observações
- O objetivo aqui é evitar confusão e garantir comportamento previsível; não é objetivo expandir o JSON para outras cidades.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/settings</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 3.0: Implementar regras SP-only + fallback da base local (JSON)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O modo “Perto de mim” deve usar Apple Maps como fonte primária. A base local (seed/JSON persistido) deve estar disponível apenas em São Paulo como fallback, e deve ser invisível/inacessível fora de SP.

<requirements>
- Definir o “gate” de SP com base no estado atual do app (settings).
- Ajustar UI do seletor de fonte no modo nearby para respeitar SP-only.
- Garantir fallback local em SP quando Apple Maps falhar/der vazio.
</requirements>

## Subtarefas

- [ ] 3.1 Implementar verificação “isSaoPauloSelected” centralizada
- [ ] 3.2 Ajustar seleção de fonte e UI (esconder/desabilitar)
- [ ] 3.3 Implementar fallback de execução (Apple Maps → local base)

## Detalhes de Implementação

Referenciar “Decisões Principais” e “Sequenciamento de Desenvolvimento” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Regra SP-only aplicada na UI e na execução.
- Fallback local em SP funciona e é previsível.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppSettingsStorage.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`


