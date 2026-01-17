# [14.0] Implement Accessibility Features (M)

## Objetivo
- Garantir que todos os novos componentes são acessíveis via VoiceOver
- Implementar labels, hints e traits apropriados
- Testar ordem de navegação lógica com VoiceOver
- Suportar Dynamic Type (tamanhos de fonte variáveis)
- Validar contraste de cores (mínimo 4.5:1)
- Implementar todos os requisitos AR1-AR7 do PRD

## Subtarefas
- [ ] 14.1 Adicionar accessibility labels em DataSourceBadge
- [ ] 14.2 Adicionar accessibility labels em DistanceGroupHeaderView
- [ ] 14.3 Adicionar accessibility em UnifiedRestaurantCard (navegação lógica)
- [ ] 14.4 Adicionar accessibility em LocationOnboardingView
- [ ] 14.5 Testar ordem de foco com VoiceOver
- [ ] 14.6 Validar suporte a Dynamic Type em todos os componentes
- [ ] 14.7 Medir contraste de cores com ferramenta
- [ ] 14.8 Ajustar qualquer problema encontrado

## Critérios de Sucesso
- VoiceOver lê todos os elementos na ordem lógica
- DataSourceBadge anuncia "Fonte: [nome]" e hint "Toque para mais informações"
- DistanceGroupHeaderView combina elementos e anuncia "[bracket], [N] restaurantes"
- UnifiedRestaurantCard navega: imagem → nome → distância → rating → ações
- Quick action buttons têm hints descrevendo ação (ex: "Abre no TripAdvisor")
- Todos os textos são legíveis em tamanhos de fonte grandes (Dynamic Type)
- Contraste de texto sobre backgrounds é mínimo 4.5:1
- Nenhum elemento interativo é ignorado pelo VoiceOver

## Dependências
- **Tasks 5-7**: Componentes de UI devem estar implementados
- **Task 11**: LocationOnboardingView deve estar pronto

## Observações
- Usar `.accessibilityLabel()`, `.accessibilityHint()`, `.accessibilityElement()`
- Combinar elementos relacionados com `.accessibilityElement(children: .combine)`
- Testar com VoiceOver ativado em simulador ou device real
- Usar Accessibility Inspector no Xcode para validar contraste
- PRD especifica AR1-AR7 (linhas 231-240)
- Dynamic Type: usar fontes system com `.font(.body)`, etc (não sizes fixos onde possível)

## status: pending

<task_context>
<domain>presentation/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>task_5,task_6,task_7,task_11</dependencies>
</task_context>

# Tarefa 14.0: Implement Accessibility Features

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa garante que a feature é acessível para todos os usuários, incluindo aqueles com deficiências visuais. Implementa os 7 requisitos de acessibilidade do PRD (AR1-AR7), focando em VoiceOver, Dynamic Type, e contraste de cores.

<requirements>
- Todos os componentes devem ter labels descritivos
- Ordem de navegação deve ser lógica (top-to-bottom, left-to-right)
- Hints devem explicar ações interativas
- Suporte completo a Dynamic Type
- Contraste mínimo 4.5:1 para todo texto
- Estados de permissão claramente anunciados
</requirements>

## Subtarefas

- [ ] 14.1 Abrir DataSourceBadge.swift e adicionar/verificar accessibility modifiers
- [ ] 14.2 Abrir DistanceGroupHeaderView.swift e adicionar/verificar accessibility
- [ ] 14.3 Abrir UnifiedRestaurantCard.swift e implementar navegação lógica
- [ ] 14.4 Abrir LocationOnboardingView.swift e validar accessibility
- [ ] 14.5 Ativar VoiceOver e navegar por toda a feature
- [ ] 14.6 Testar Dynamic Type em Settings → Accessibility → Larger Text
- [ ] 14.7 Usar Accessibility Inspector para medir contrastes
- [ ] 14.8 Documentar issues e corrigir
- [ ] 14.9 Validar novamente após correções

## Detalhes de Implementação

Consulte `prd.md` seção "Requisitos de Acessibilidade" (linhas 231-240) para todos os requisitos.

**AR1: Badges com labels descritivos**
```swift
// DataSourceBadge
.accessibilityLabel("Fonte: \(source.displayName)")
.accessibilityHint("Toque para mais informações")
```

**AR2: Headers anunciam quantidade**
```swift
// DistanceGroupHeaderView
.accessibilityElement(children: .combine)
.accessibilityLabel("\(bracket.displayName), \(count) restaurantes")
```

**AR3: Botões com hints de ação**
```swift
// Quick action buttons em UnifiedRestaurantCard
Button { ... } label: { ... }
  .accessibilityLabel(action.displayName)
  .accessibilityHint(action.accessibilityHint)

// Ex: QuickAction.tripAdvisor
// displayName: "TripAdvisor"
// hint: "Abre no TripAdvisor"
```

**AR4: Navegação lógica em cards**
```swift
// UnifiedRestaurantCard
// Usar ordem natural do VStack/HStack
// VoiceOver segue ordem de declaração: imagem → nome → categoria → distância → rating → ações
// Garantir que cada elemento tem label apropriado
```

**AR5: Dynamic Type support**
```swift
// Usar font modifiers system:
.font(.body) // ao invés de .font(.system(size: 15))
.font(.headline)
.font(.caption)

// Para sizes customizadas, usar scaled metric:
@ScaledMetric(relativeTo: .body) var imageSize: CGFloat = 80
```

**AR6: Contraste de cores**
```swift
// Validar com Accessibility Inspector:
// Text primary sobre background: deve ser > 4.5:1
// Text secondary sobre background: deve ser > 4.5:1
// Badge text (white) sobre badge background: deve ser > 4.5:1

// Se necessário, ajustar opacidades ou cores
```

**AR7: Estados de permissão claramente anunciados**
```swift
// LocationOnboardingView
VStack {
  Image(...) .accessibilityHidden(true) // Decorativo
  Text("Descubra...") // Automaticamente lido
  Button("Permitir localização")
    .accessibilityLabel("Permitir acesso à localização")
    .accessibilityHint("Abre solicitação de permissão do sistema")
}

// Card de fallback em PreferencesView
.accessibilityLabel("Permissão de localização necessária. Toque em 'Ir para Configurações' para permitir acesso.")
```

## Critérios de Sucesso

### VoiceOver Testing
- [ ] Ativar VoiceOver: Settings → Accessibility → VoiceOver
- [ ] Navegar PreferencesView com resultados:
  - Headers são lidos com contagem correta
  - Cards são lidos: nome, categoria, distância, rating
  - Badges são lidos: "Fonte: Minha Base/Apple Maps"
  - Quick actions são lidas com hints de ação
- [ ] Navegar LocationOnboardingView:
  - Título e descrição são lidos
  - Botões têm labels e hints claros
- [ ] Navegar SearchModeSegmentView:
  - Tabs são lidas como "Minha Lista, aba" e "Perto de mim, aba"
  - Estado selecionado é anunciado

### Dynamic Type Testing
- [ ] Settings → Accessibility → Display & Text Size → Larger Text
- [ ] Mover slider para tamanhos grandes (XXXL)
- [ ] Abrir app e navegar feature:
  - Textos escalam apropriadamente
  - Layouts não quebram
  - Cards não cortam texto
  - Botões permanecem clicáveis

### Color Contrast Testing
- [ ] Xcode → Open Developer Tool → Accessibility Inspector
- [ ] Color Contrast Calculator tab
- [ ] Testar pares de cores:
  - AppColors.textPrimary sobre AppColors.background
  - AppColors.textSecondary sobre AppColors.background
  - White sobre AppColors.primary (badge)
  - White sobre AppColors.accent (badge)
- [ ] Todos devem ser > 4.5:1 (WCAG AA)

### Issues & Fixes
- Documentar qualquer elemento não acessível
- Priorizar correções críticas (ordem de foco, labels faltando)
- Re-validar após cada fix

## Arquivos relevantes
- Modificar: `ChooseThere/Presentation/Components/DataSourceBadge.swift`
- Modificar: `ChooseThere/Presentation/Components/DistanceGroupHeaderView.swift`
- Modificar: `ChooseThere/Presentation/Components/UnifiedRestaurantCard.swift`
- Modificar: `ChooseThere/Presentation/Views/LocationOnboardingView.swift`
- Referência: `prd.md` (linhas 231-240 - AR1-AR7)
- Referência: `techspec.md` (linhas 786-797 - testes de acessibilidade)
- Tools: Xcode Accessibility Inspector, VoiceOver (iOS Settings)
