# [1.0] Modelo + persistência de preferências aprendidas (S/M)

## Objetivo
- Criar o modelo `LearnedPreferences` e um store de persistência local (UserDefaults) com versionamento e reset.

## Subtarefas
- [ ] 1.1 Definir `LearnedPreferences` (weights de tags/categorias) + versionamento
- [ ] 1.2 Implementar `LearnedPreferencesStore` (load/save/reset) em UserDefaults
- [ ] 1.3 Definir settings globais: `learningEnabled` e `avoidRepeatsLimit`

## Critérios de Sucesso
- Preferências aprendidas persistem entre relaunch.
- Reset limpa pesos e volta ao estado padrão.
- Versionamento permite evoluções futuras.

## Dependências
- PRD/Tech Spec desta pasta.

## Observações
- Manter encode/decode simples (JSON Codable) para inspeção e debug.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/preferences</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Modelo + persistência de preferências aprendidas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Precisamos de um lugar único para armazenar pesos aprendidos e configurações globais (toggle e limite N). Isso servirá de base para aprendizado, randomizer e UX.

<requirements>
- Criar `LearnedPreferences` versionado e Codable
- Persistir em `UserDefaults` com API simples
- Implementar reset e valores default
</requirements>

## Subtarefas

- [ ] 1.1 Modelos e defaults
- [ ] 1.2 Store (load/save/reset)
- [ ] 1.3 Chaves de settings e migração simples (se necessário)

## Detalhes de Implementação

- Ver `techspec.md`: **Modelos de Dados** e **Persistência**.

## Critérios de Sucesso

- Load/save/reset funcionam e são testáveis.

## Arquivos relevantes
- `tasks/prd-preferencias-aprendem/techspec.md`

