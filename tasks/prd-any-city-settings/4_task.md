# [4.0] UI do modo “Minha Lista | Perto de mim” (M)

## Objetivo
- Criar a navegação/segmento que permite alternar entre “Minha Lista” (fluxo atual) e “Perto de mim” (novo modo), sem quebrar o fluxo de sorteio existente.

## Subtarefas
- [ ] 4.1 Definir onde o segmento vive (ex.: dentro de `PreferencesView` ou uma nova tela container)
- [ ] 4.2 Criar UI do segmento e persistir a seleção (UserDefaults/AppSettingsStorage)
- [ ] 4.3 Wiring para apresentar “Perto de mim” (placeholder inicialmente) e “Minha Lista” (existente)
- [ ] 4.4 Ajustar copy do onboarding/headers para remover hardcode “São Paulo”

## Critérios de Sucesso
- Usuário alterna entre modos sem crash e sem estados inconsistentes.
- Seleção do modo persiste.

## Dependências
- 1.0 Persistência de cidade e preferências globais
- 2.0 Onboarding: seleção de cidade no primeiro uso

## Observações
- O app já tem `MainTabView` e `PreferencesView` como ponto do sorteio; ideal é evoluir sem refatoração grande.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/navigation</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 4.0: UI do modo “Minha Lista | Perto de mim”

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Introduzir uma alternância clara (segment/tab interno) para que o usuário escolha o contexto: usar a base local (“Minha Lista”) ou buscar dinamicamente perto (“Perto de mim”). Nesta tarefa focamos em estrutura de UI e persistência da escolha do modo.

<requirements>
- Segmento “Minha Lista | Perto de mim”
- Persistir seleção do modo
- Remover texto fixo de cidade em strings do onboarding (ex.: “São Paulo”)
</requirements>

## Subtarefas

- [x] 4.1 Implementar container e segmento para alternar views
- [x] 4.2 Persistir seleção em settings
- [x] 4.3 Ajustar strings do onboarding para referenciar cidade selecionada (ou termo genérico)

## Detalhes de Implementação

- Tech Spec: **Arquitetura do Sistema** (Views impactadas) e **Sequenciamento de Desenvolvimento**
- Referências existentes:
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/OnboardingView.swift`

## Critérios de Sucesso

- Alternância aparece e funciona
- Modo selecionado persiste e restaura ao relaunch
- Copy não fica preso em uma cidade específica

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/OnboardingView.swift`

