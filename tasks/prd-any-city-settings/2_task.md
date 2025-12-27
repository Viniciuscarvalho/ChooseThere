# [2.0] Onboarding: seleção de cidade no primeiro uso (M)

## Objetivo
- Evoluir o onboarding para capturar a cidade no primeiro uso (derivada do seed local + Any City) e persistir essa escolha antes de liberar o acesso às tabs.

## Subtarefas
- [ ] 2.1 Criar `CitySelectionView` reutilizável (onboarding e Configurações)
- [ ] 2.2 Integrar seleção de cidade ao fluxo do `OnboardingView`
- [ ] 2.3 Persistir seleção via `AppSettingsStorage` e marcar onboarding como visto
- [ ] 2.4 Validar fluxos: primeiro uso, reabertura, reset de onboarding (manual/teste)

## Critérios de Sucesso
- No primeiro uso, o usuário não consegue prosseguir sem selecionar uma cidade (ou Any City).
- Ao finalizar, o app navega para `MainTabView` e mantém a seleção persistida.

## Dependências
- 1.0 Persistência de cidade e preferências globais

## Observações
- O onboarding atual é um carousel; pode virar um fluxo com um passo extra ao final.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/onboarding</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 2.0: Onboarding: seleção de cidade no primeiro uso

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar um passo de seleção de cidade no onboarding para habilitar multi-cidade e Any City. A seleção deve ser persistida e usada como contexto para o modo “Perto de mim”.

<requirements>
- Tela de seleção com lista derivada do seed local (city/state) + Any City
- Persistir a seleção via `AppSettingsStorage`
- Manter `OnboardingStorage.markAsSeen()` como fonte de verdade do “primeiro uso”
</requirements>

## Subtarefas

- [x] 2.1 Implementar `CitySelectionView` (lista + busca opcional + checkmark)
- [x] 2.2 Atualizar `OnboardingView` para incluir o passo de cidade (sem quebrar o carousel)
- [x] 2.3 Ao concluir, setar `OnboardingStorage.hasSeenOnboarding = true` e navegar para `.mainTabs`
- [ ] 2.4 Testes manuais guiados (primeiro uso e reabertura)

## Detalhes de Implementação

- Tech Spec: **Arquitetura do Sistema** (Views novas) e **Sequenciamento de Desenvolvimento**
- Referências existentes:
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/OnboardingView.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/RootView.swift`

## Critérios de Sucesso

- No primeiro uso, a seleção de cidade ocorre e é persistida
- O onboarding continua suave e sem regressões visuais graves
- Após relaunch, não reabre onboarding e mantém a cidade escolhida

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/OnboardingView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/RootView.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/CitySelectionView.swift`

