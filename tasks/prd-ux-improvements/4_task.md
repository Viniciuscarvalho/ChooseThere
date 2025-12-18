# [4.0] Ajustar layout da tela de Resultado (S)

## Objetivo
Otimizar o layout da `ResultView` para que o mapa ocupe mais espaço na tela, removendo gaps desnecessários e melhorando a experiência visual.

## Subtarefas
- [ ] 4.1 Aumentar altura do mapa de 280 para ~45% da tela
- [ ] 4.2 Remover espaçamentos extras abaixo dos botões
- [ ] 4.3 Ajustar sobreposição do card no mapa
- [ ] 4.4 Garantir que botões ficam próximos ao bottom
- [ ] 4.5 Testar em diferentes tamanhos de tela

## Critérios de Sucesso
- Mapa ocupa aproximadamente 45% da altura da tela
- Sem espaço vazio visível abaixo dos botões
- Card sobrepõe suavemente o mapa
- Layout funciona em iPhone SE até iPhone 15 Pro Max

## Dependências
- Nenhuma (pode ser feita em paralelo com outras tasks)

## Observações
- Usar `GeometryReader` para calcular altura proporcional
- Manter a estética atual, apenas otimizar espaçamentos
- Considerar safe area do bottom

## status: pending

<task_context>
<domain>presentation</domain>
<type>implementation</type>
<scope>performance</scope>
<complexity>low</complexity>
<dependencies>none</dependencies>
</task_context>

## Detalhes de Implementação

### Antes (problema)
```
┌─────────────────┐
│      Mapa       │ 280px fixo
├─────────────────┤
│      Card       │
├─────────────────┤
│     Botões      │
├─────────────────┤
│   [espaço]      │ ← problema
└─────────────────┘
```

### Depois (solução)
```
┌─────────────────┐
│                 │
│      Mapa       │ 45% da tela
│                 │
├─────────────────┤
│      Card       │ (overlap -40)
├─────────────────┤
│     Botões      │
└─────────────────┘
```

### Código sugerido
```swift
GeometryReader { geometry in
    VStack(spacing: 0) {
        mapSection(restaurant: restaurant, vm: vm)
            .frame(height: geometry.size.height * 0.45)
        // ...
    }
}
```

## Arquivos relevantes
- `ChooseThere/Presentation/Views/ResultView.swift` (modificar)


