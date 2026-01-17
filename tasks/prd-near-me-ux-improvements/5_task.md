# [5.0] Create DataSourceBadge Component (S)

## Objetivo
- Criar componente SwiftUI reutilizável para exibir badge de fonte de dados
- Implementar tooltip interativo que explica a fonte ao tocar no badge
- Aplicar cores e ícones corretos para cada fonte (Minha Base vs Apple Maps)
- Garantir acessibilidade com labels apropriados

## Subtarefas
- [ ] 5.1 Criar arquivo `DataSourceBadge.swift` em `ChooseThere/Presentation/Components/`
- [ ] 5.2 Implementar SwiftUI view com HStack de ícone + texto
- [ ] 5.3 Adicionar state para controlar visibilidade do tooltip
- [ ] 5.4 Implementar popover com texto explicativo
- [ ] 5.5 Adicionar accessibility labels e hints
- [ ] 5.6 Criar SwiftUI preview com ambas fontes

## Critérios de Sucesso
- Badge renderiza com cores corretas (primary para localBase, accent para appleMaps)
- Ícones SF Symbols aparecem corretamente
- Tooltip aparece ao tocar no badge
- Popover se adapta bem em devices pequenos (usando `.presentationCompactAdaptation(.popover)`)
- Accessibility labels estão presentes e descritivos
- Preview mostra ambas variações lado a lado
- Código segue Kodeco Swift Style Guide

## Dependências
- **Task 1.0**: Enum `DataSource` deve estar definido com computed properties

## Observações
- Este é um componente visual puro, sem lógica de negócio
- Badge deve ser pequeno e discreto (11pt font, padding compacto)
- Usar `.buttonStyle(.plain)` para evitar efeitos de botão padrão
- Tooltip usa `.popover` ao invés de `.alert` para UX mais suave
- Teste em iPhone SE para garantir que popover cabe na tela

## status: pending

<task_context>
<domain>presentation/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>task_1</dependencies>
</task_context>

# Tarefa 5.0: Create DataSourceBadge Component

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Este componente visual exibe um badge compacto que indica a fonte de dados de um restaurante. O badge é interativo: ao tocar, exibe um popover explicando a origem dos dados (curadoria local vs Apple Maps).

<requirements>
- Badge deve ser visualmente discreto mas legível
- Cores devem vir de DataSource.badgeColor
- Ícones devem vir de DataSource.badgeIcon
- Tooltip deve usar texto de DataSource.tooltipText
- Accessibility deve descrever fonte e interação
</requirements>

## Subtarefas

- [ ] 5.1 Criar arquivo `DataSourceBadge.swift` em `ChooseThere/Presentation/Components/`
- [ ] 5.2 Implementar struct DataSourceBadge: View
- [ ] 5.3 Adicionar @State para showTooltip
- [ ] 5.4 Criar Button com HStack de ícone + texto
- [ ] 5.5 Aplicar styling (padding, background, corner radius)
- [ ] 5.6 Adicionar .popover com texto explicativo
- [ ] 5.7 Adicionar accessibility modifiers
- [ ] 5.8 Criar #Preview com ambas fontes

## Detalhes de Implementação

Consulte `techspec.md` seção "DataSourceBadge" (linhas 347-381) para implementação completa.

**Estrutura visual:**
```swift
Button {
  showTooltip.toggle()
} label: {
  HStack(spacing: 4) {
    Image(systemName: source.badgeIcon)
      .font(.system(size: 9, weight: .medium))
    Text(source.displayName)
      .font(.system(size: 11, weight: .medium))
  }
  .foregroundColor(.white)
  .padding(.horizontal, 8)
  .padding(.vertical, 4)
  .background(source.badgeColor)
  .clipShape(RoundedRectangle(cornerRadius: 8))
}
```

**Tooltip:**
```swift
.popover(isPresented: $showTooltip) {
  Text(source.tooltipText)
    .font(.caption)
    .padding()
    .presentationCompactAdaptation(.popover)
}
```

**Accessibility:**
```swift
.accessibilityLabel("Fonte: \(source.displayName)")
.accessibilityHint("Toque para mais informações")
```

**Cores esperadas:**
- Minha Base: AppColors.primary com opacity 0.9
- Apple Maps: AppColors.accent com opacity 0.9
- Texto: sempre branco para contraste

## Critérios de Sucesso

- Componente compila e renderiza sem erros
- Badge mostra ícone + texto lado a lado
- Cores estão corretas para ambas fontes
- Tooltip aparece ao tocar e desaparece ao tocar novamente
- Popover se adapta bem em iPhone SE (presentationCompactAdaptation)
- VoiceOver lê "Fonte: [nome]" e hint "Toque para mais informações"
- Preview mostra VStack com ambos badges (localBase e appleMaps)
- Código formatado com 2-space indentation
- Font sizes corretos: 9pt para ícone, 11pt para texto

## Arquivos relevantes
- Criar: `ChooseThere/Presentation/Components/DataSourceBadge.swift`
- Referência: `ChooseThere/Domain/Protocols/NearbyDisplayable.swift` (enum DataSource)
- Referência: `AppColors.swift` (cores primary e accent)
- Referência: `techspec.md` (linhas 347-381)
- Referência: `prd.md` (linhas 113-125 - requisitos de badges)
