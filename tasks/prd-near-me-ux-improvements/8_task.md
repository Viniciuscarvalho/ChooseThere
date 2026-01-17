# [8.0] Modify SearchModeSegmentView for Conditional Tab Visibility (M)

## Objetivo
- Adicionar lógica de filtragem de tabs baseada na cidade selecionada
- Aba "Minha Lista" deve aparecer apenas quando cidade é "São Paulo|SP"
- Aba "Perto de mim" deve estar sempre visível
- Implementar transição automática de modo quando aba fica invisível
- Aplicar animação suave (spring) na transição

## Subtarefas
- [ ] 8.1 Abrir arquivo `SearchModeSegmentView.swift`
- [ ] 8.2 Adicionar computed property `visibleModes` que filtra baseado em `AppSettingsStorage.isSaoPauloSelected`
- [ ] 8.3 Modificar ForEach para iterar sobre `visibleModes` ao invés de `SearchMode.allCases`
- [ ] 8.4 Adicionar `.onChange(of: visibleModes)` para detectar mudanças
- [ ] 8.5 Implementar lógica de mudança automática para `.nearby` quando modo atual não está visível
- [ ] 8.6 Aplicar animação spring (response: 0.3, damping: 0.8)
- [ ] 8.7 Testar mudança SP → outra cidade → SP

## Critérios de Sucesso
- Em São Paulo: ambas abas "Minha Lista" e "Perto de mim" são visíveis
- Fora de São Paulo: apenas "Perto de mim" é visível
- Ao mudar de SP para outra cidade com "Minha Lista" ativa, modo muda automaticamente para "Perto de mim"
- Transição é suave com animação spring
- Estado de modo é persistido em `AppSettingsStorage.searchMode`
- Não há warnings ou crashes ao mudar cidade
- Preview mostra ambos estados (SP e não-SP)

## Dependências
- Nenhuma nova - usa componentes existentes (`AppSettingsStorage`, `SearchMode`)

## Observações
- Esta é a implementação do requisito FR1 do PRD (visibilidade condicional de aba)
- `AppSettingsStorage.isSaoPauloSelected` já deve existir no código
- Não modificar o enum `SearchMode` - filtro acontece apenas na UI
- Preservar dados de "Minha Lista" mesmo quando oculta
- Animação spring proporciona transição natural (não abrupta)

## status: pending

<task_context>
<domain>presentation/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>none</dependencies>
</task_context>

# Tarefa 8.0: Modify SearchModeSegmentView for Conditional Tab Visibility

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa implementa a funcionalidade core de visibilidade condicional de abas. A aba "Minha Lista" só aparece em São Paulo, reduzindo confusão para usuários em outras cidades. Quando o usuário muda de cidade e a aba ativa desaparece, o app automaticamente muda para "Perto de mim".

<requirements>
- Filtrar modos exibidos baseado em AppSettingsStorage.isSaoPauloSelected
- Manter SearchMode.allCases intacto (filtro apenas na view)
- Detectar mudança de visibilidade e reagir apropriadamente
- Aplicar animação spring para transição suave
- Persistir modo selecionado em AppSettings
</requirements>

## Subtarefas

- [ ] 8.1 Localizar e abrir `ChooseThere/Presentation/Components/SearchModeSegmentView.swift`
- [ ] 8.2 Adicionar computed property `private var visibleModes: [SearchMode]`
- [ ] 8.3 Implementar lógica de filtro (SP: todos, outros: apenas .nearby)
- [ ] 8.4 Modificar ForEach para usar `visibleModes`
- [ ] 8.5 Adicionar `.onChange(of: visibleModes)` modifier
- [ ] 8.6 Implementar lógica de mudança automática de modo
- [ ] 8.7 Adicionar withAnimation(.spring(...)) na mudança
- [ ] 8.8 Testar fluxo completo de mudança de cidade

## Detalhes de Implementação

Consulte `techspec.md` seção "SearchModeSegmentView Modifications" (linhas 487-520) para implementação completa.

**Computed property visibleModes:**
```swift
private var visibleModes: [SearchMode] {
  if AppSettingsStorage.isSaoPauloSelected {
    return SearchMode.allCases
  } else {
    return [.nearby]
  }
}
```

**Modificação do ForEach:**
```swift
// Antes:
ForEach(SearchMode.allCases) { mode in
  // ...
}

// Depois:
ForEach(visibleModes) { mode in
  // ...
}
```

**Handler onChange:**
```swift
.onChange(of: visibleModes) { oldValue, newValue in
  if !newValue.contains(selectedMode) {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
      selectedMode = .nearby
      AppSettingsStorage.searchMode = .nearby
    }
  }
}
```

**Animação:**
- Spring animation com response: 0.3s, dampingFraction: 0.8
- Proporciona transição suave e natural
- Aplicada apenas quando modo muda automaticamente

## Critérios de Sucesso

- Computed property `visibleModes` retorna array correto baseado em isSaoPauloSelected
- ForEach itera sobre visibleModes ao invés de SearchMode.allCases
- Em São Paulo: vejo abas "Minha Lista" e "Perto de mim"
- Fora de São Paulo: vejo apenas aba "Perto de mim"
- Ao mudar de SP para outra cidade com "Minha Lista" ativa:
  - Aba desaparece suavemente
  - Modo muda automaticamente para "Perto de mim"
  - AppSettingsStorage é atualizado
- Ao voltar para SP: aba "Minha Lista" reaparece
- Não há crashes, warnings ou erros de UI
- Animação é suave e perceptível
- Código formatado seguindo Kodeco style guide

## Arquivos relevantes
- Modificar: `ChooseThere/Presentation/Components/SearchModeSegmentView.swift`
- Referência: `ChooseThere/Data/AppSettingsStorage.swift` (isSaoPauloSelected)
- Referência: `ChooseThere/Domain/Models/SearchMode.swift` (enum)
- Referência: `techspec.md` (linhas 487-520)
- Referência: `prd.md` (linhas 66-79 - FR1: Visibilidade Condicional)
