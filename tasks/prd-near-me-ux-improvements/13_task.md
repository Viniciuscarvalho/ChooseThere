# [13.0] Add Animations and Transitions (M)

## Objetivo
- Implementar animações suaves para aparecimento de lista de resultados
- Adicionar staggered animation nos cards (aparecem sequencialmente)
- Implementar fade in/out para transição de aba "Minha Lista"
- Aplicar spring animations para transições de modo
- Garantir 60 FPS em animações

## Subtarefas
- [ ] 13.1 Adicionar staggered animation para aparecimento de cards na lista
- [ ] 13.2 Implementar fade transition para aba "Minha Lista"
- [ ] 13.3 Aplicar spring animation na mudança de modo (SearchModeSegmentView)
- [ ] 13.4 Adicionar subtle animations em botões e interactive elements
- [ ] 13.5 Testar performance de animações com Instruments
- [ ] 13.6 Ajustar timing e easing para feel natural
- [ ] 13.7 Validar 60 FPS em iPhone SE

## Critérios de Sucesso
- Cards aparecem sequencialmente com delay de 0.05s entre cada
- Transição de aba usa fade com duração 0.25s linear
- Mudança de modo usa spring (response: 0.3, damping: 0.8)
- Animações mantêm 60 FPS em iPhone SE 2nd gen ou superior
- Não há jank ou stutter durante animações
- Timing parece natural (não muito rápido nem muito lento)
- Animações são interruptíveis (não bloqueiam UI)

## Dependências
- **Task 8.0**: SearchModeSegmentView deve estar modificado
- **Task 9.0**: PreferencesView com lista vertical deve estar pronto

## Observações
- Usar `.transition(.opacity)` para fade in/out
- Usar `.animation(.spring(...))` para mudanças de estado
- Staggered animation usa `.delay()` calculado baseado no índice
- Profile com Instruments: Time Profiler e Core Animation tool
- Animações devem respeitar "Reduce Motion" accessibility setting
- PRD especifica: response: 0.3, damping: 0.8 para spring, 0.25s para fade

## status: pending

<task_context>
<domain>presentation/views</domain>
<type>implementation</type>
<scope>performance</scope>
<complexity>medium</complexity>
<dependencies>task_8,task_9</dependencies>
</task_context>

# Tarefa 13.0: Add Animations and Transitions

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa adiciona polish visual através de animações cuidadosamente implementadas. Animações bem executadas melhoram percepção de qualidade e fornecem feedback visual de mudanças de estado. Foco em performance é crítico para manter 60 FPS.

<requirements>
- Staggered animation para cards (delay incremental)
- Fade transition para aparecimento/desaparecimento de aba
- Spring animations para mudanças de modo
- Performance mantida em 60 FPS
- Respeitar preferência "Reduce Motion"
</requirements>

## Subtarefas

- [ ] 13.1 Abrir PreferencesView e adicionar staggered animation aos cards
- [ ] 13.2 Abrir SearchModeSegmentView e implementar fade transition
- [ ] 13.3 Confirmar spring animation na mudança de selectedMode (já deve estar)
- [ ] 13.4 Adicionar subtle scale/opacity em botões ao tocar
- [ ] 13.5 Profile com Instruments (Time Profiler)
- [ ] 13.6 Profile com Core Animation tool (frame rate)
- [ ] 13.7 Ajustar durations se necessário
- [ ] 13.8 Testar com "Reduce Motion" ativado

## Detalhes de Implementação

Consulte `prd.md` seção "Considerações de UI/UX - Animações" (linhas 215-219) para especificações.

**Staggered animation para cards:**
```swift
// Em PreferencesView, dentro do ForEach de cards
ForEach(Array(items.enumerated()), id: \.element.displayId) { index, item in
  UnifiedRestaurantCard(...)
    .transition(.opacity.combined(with: .move(edge: .top)))
    .animation(
      .easeOut(duration: 0.3).delay(Double(index) * 0.05),
      value: viewModel.searchState
    )
}
```

**Fade transition para aba:**
```swift
// Em SearchModeSegmentView
ForEach(visibleModes) { mode in
  // tab button
}
.transition(.opacity)
.animation(.linear(duration: 0.25), value: visibleModes)
```

**Spring animation para modo (já implementado em task 8):**
```swift
withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
  selectedMode = .nearby
}
```

**Botões com feedback visual:**
```swift
Button {
  // action
} label: {
  // content
}
.buttonStyle(.plain)
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.easeInOut(duration: 0.1), value: isPressed)
```

**Respeitar Reduce Motion:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Condicional em animações
.animation(reduceMotion ? .none : .spring(...), value: state)
```

## Critérios de Sucesso

### Staggered Animation
- Cards aparecem sequencialmente de cima para baixo
- Delay de 0.05s entre cada card (primeiro 0s, segundo 0.05s, terceiro 0.1s, etc)
- Animação usa easeOut com duração total ~0.3s por card
- Máximo 15 cards iniciais, então animação total ~1s

### Fade Transition
- Aba "Minha Lista" fades out em 0.25s ao mudar para cidade fora de SP
- Aba fades in em 0.25s ao voltar para SP
- Transição é linear (não easeIn/easeOut)

### Spring Animation
- Mudança de modo selectedMode usa spring
- Response: 0.3s, dampingFraction: 0.8
- Animação se completa suavemente sem overshoot excessivo

### Performance
- Time Profiler mostra < 10% CPU durante animações
- Core Animation mostra consistente 60 FPS (16.67ms por frame)
- Sem frame drops durante scroll + animation
- Testado em iPhone SE 2nd gen (hardware mínimo)

### Accessibility
- Com "Reduce Motion" ativado: animações são desabilitadas ou reduzidas
- Funcionalidade não é afetada, apenas visual

### Feel
- Animações parecem naturais e polidas
- Não muito rápidas (jarring) nem muito lentas (sluggish)
- Cards não "pop in" abruptamente

## Arquivos relevantes
- Modificar: `ChooseThere/Presentation/Views/PreferencesView.swift` (staggered animation)
- Modificar: `ChooseThere/Presentation/Components/SearchModeSegmentView.swift` (fade transition)
- Referência: `prd.md` (linhas 215-219 - especificações de animação)
- Referência: `techspec.md` (linhas 664-669 - Fase 7: Polish & Animations)
- Tools: Xcode Instruments (Time Profiler, Core Animation)
