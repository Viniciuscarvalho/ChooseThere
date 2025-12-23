# [5.0] Ajustar layout do Detalhe do Histórico (S)

## Objetivo
Corrigir o problema de corte do nome do restaurante na `HistoryDetailView`, garantindo que nomes longos sejam exibidos completamente.

## Subtarefas
- [ ] 5.1 Remover limite de linhas do título do restaurante
- [ ] 5.2 Ajustar padding do card para acomodar texto maior
- [ ] 5.3 Garantir altura dinâmica do card
- [ ] 5.4 Melhorar espaçamento entre elementos
- [ ] 5.5 Testar com nomes longos (ex: "Espaço Priceless Mastercard...")

## Critérios de Sucesso
- Nome do restaurante nunca é truncado
- Card expande verticalmente conforme necessário
- Layout permanece esteticamente agradável
- Scroll funciona corretamente com cards maiores

## Dependências
- Nenhuma (pode ser feita em paralelo com outras tasks)

## Observações
- O restaurante "Espaço Priceless Mastercard (NOTIÊ e ABARU – Chef Onildo Rocha)" é um bom caso de teste
- Verificar também o endereço que pode ser longo

## status: pending

<task_context>
<domain>presentation</domain>
<type>implementation</type>
<scope>performance</scope>
<complexity>low</complexity>
<dependencies>none</dependencies>
</task_context>

## Detalhes de Implementação

### Problema atual
```swift
Text(restaurant.name)
    .font(.title3.weight(.bold))
    // Sem lineLimit, mas o card não expande
```

### Solução
```swift
Text(restaurant.name)
    .font(.title3.weight(.bold))
    .foregroundStyle(AppColors.textPrimary)
    .fixedSize(horizontal: false, vertical: true) // Permite expansão vertical
```

### Também verificar
- O `restaurantCard` precisa ter altura dinâmica
- O `ScrollView` precisa acomodar cards maiores
- O mapa pode precisar de altura reduzida (200 em vez de 220)

## Arquivos relevantes
- `ChooseThere/Presentation/Views/HistoryDetailView.swift` (modificar)





