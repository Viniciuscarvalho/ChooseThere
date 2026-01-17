# [10.0] Update AppSettingsStorage with Location Flags (S)

## Objetivo
- Adicionar propriedades para rastrear estado de onboarding de localização
- Flag para indicar se usuário já viu onboarding
- Flag para indicar se usuário pulou onboarding
- Usar UserDefaults para persistência

## Subtarefas
- [ ] 10.1 Abrir arquivo `AppSettingsStorage.swift`
- [ ] 10.2 Adicionar static var `hasShownLocationOnboarding: Bool`
- [ ] 10.3 Adicionar static var `hasSkippedLocationOnboarding: Bool`
- [ ] 10.4 Implementar getters e setters usando UserDefaults
- [ ] 10.5 Adicionar documentação inline explicando uso
- [ ] 10.6 Testar persistência (salvar, fechar app, reabrir)

## Critérios de Sucesso
- Propriedades compilam sem erros
- Valores persistem entre sessões do app
- Default value é `false` para ambas flags
- Documentação explica quando usar cada flag
- Código segue Kodeco Swift Style Guide
- Keys do UserDefaults seguem naming convention consistente

## Dependências
- Nenhuma - adiciona apenas storage simples

## Observações
- `hasShownLocationOnboarding`: marcado como `true` após exibir onboarding pela primeira vez
- `hasSkippedLocationOnboarding`: marcado como `true` quando usuário toca "Agora não"
- Se usuário concede permissão, ambas flags ficam `true` (já mostrou, não pulou)
- Flags são verificadas no app launch para decidir se mostra onboarding
- UserDefaults keys devem ser string literals, não mágicas

## status: pending

<task_context>
<domain>data/storage</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>low</complexity>
<dependencies>none</dependencies>
</task_context>

# Tarefa 10.0: Update AppSettingsStorage with Location Flags

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa adiciona flags de controle para o fluxo de onboarding de localização. As flags rastreiam se o usuário já viu a tela de onboarding e se optou por pular, permitindo que o app decida quando (re)apresentar a solicitação de permissão.

<requirements>
- Adicionar duas static properties com getters/setters
- Usar UserDefaults.standard para persistência
- Default value false para ambas
- Naming claro e autodocumentado
- Documentação inline explicando propósito
</requirements>

## Subtarefas

- [ ] 10.1 Localizar e abrir `ChooseThere/Data/AppSettingsStorage.swift`
- [ ] 10.2 Encontrar seção apropriada para adicionar properties (perto de outras configs de localização)
- [ ] 10.3 Adicionar extension ou seção com MARK comment
- [ ] 10.4 Implementar `hasShownLocationOnboarding` com get/set
- [ ] 10.5 Implementar `hasSkippedLocationOnboarding` com get/set
- [ ] 10.6 Adicionar documentação inline (/// comments)
- [ ] 10.7 Testar leitura e escrita via console/debugger

## Detalhes de Implementação

Consulte `techspec.md` seção "AppSettingsStorage" (linhas 542-560) para implementação completa.

**Implementação:**
```swift
extension AppSettingsStorage {
  /// Flag indicando se usuário pulou onboarding de localização
  /// Usado para decidir quando solicitar permissão novamente
  static var hasSkippedLocationOnboarding: Bool {
    get { UserDefaults.standard.bool(forKey: "hasSkippedLocationOnboarding") }
    set { UserDefaults.standard.set(newValue, forKey: "hasSkippedLocationOnboarding") }
  }

  /// Flag indicando se já exibiu onboarding de localização
  /// Marcado como true após primeira apresentação, nunca resetado
  static var hasShownLocationOnboarding: Bool {
    get { UserDefaults.standard.bool(forKey: "hasShownLocationOnboarding") }
    set { UserDefaults.standard.set(newValue, forKey: "hasShownLocationOnboarding") }
  }
}
```

**Uso esperado:**
- No app launch: checar `!hasShownLocationOnboarding` para decidir se mostra onboarding
- Após mostrar onboarding: setar `hasShownLocationOnboarding = true`
- Se usuário clica "Agora não": setar `hasSkippedLocationOnboarding = true`
- Se usuário concede permissão: ambas flags ficam true
- No modo "Perto de mim": checar `hasSkippedLocationOnboarding` para exibir card de configurações

## Critérios de Sucesso

- Extension ou seção compila sem erros
- Propriedades são static vars com get/set
- Keys do UserDefaults são strings consistentes (CamelCase)
- Default value é false (comportamento padrão de `.bool(forKey:)`)
- Documentação inline explica propósito de cada flag
- Código formatado com 2-space indentation
- MARK comment separa seção de location onboarding
- Teste manual: setar valor, reabrir app, valor persiste

## Arquivos relevantes
- Modificar: `ChooseThere/Data/AppSettingsStorage.swift`
- Referência: `techspec.md` (linhas 542-560)
- Referência: `prd.md` (linhas 128-146 - FR5: Fluxo Proativo de Permissão)
