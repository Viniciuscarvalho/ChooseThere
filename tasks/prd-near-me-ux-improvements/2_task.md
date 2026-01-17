# [2.0] Create DistanceBracket Enum and Logic (S)

## Objetivo
- Criar o enum `DistanceBracket` que representa faixas de distância para agrupamento de resultados
- Implementar lógica para classificar distâncias em brackets apropriados
- Fornecer labels localizados para cada faixa de distância

## Subtarefas
- [ ] 2.1 Criar arquivo `DistanceBracket.swift` em `ChooseThere/Domain/Models/`
- [ ] 2.2 Definir enum `DistanceBracket` com casos: veryClose, close, medium, far
- [ ] 2.3 Implementar computed property `displayName` com labels em português
- [ ] 2.4 Implementar computed property `range` com intervalos de distância
- [ ] 2.5 Implementar método `contains(distanceKm:)` para classificação

## Critérios de Sucesso
- Enum compila e possui todos os casos especificados
- Ranges estão corretos: <1km, 1-3km, 3-5km, >5km
- Display names estão em português: "Muito perto", "Perto", "Média distância", "Mais distante"
- Método `contains` funciona corretamente para qualquer valor de distância
- Código segue Kodeco Swift Style Guide

## Dependências
- Nenhuma - Esta é uma tarefa foundation independente

## Observações
- Os thresholds foram definidos no PRD mas podem ser ajustados futuramente com dados de uso
- O enum usa `CaseIterable` para permitir iteração sobre todos os casos
- Range para "far" usa `Double.infinity` como limite superior
- Esta é uma model pura sem dependências de UIKit/SwiftUI

## status: pending

<task_context>
<domain>domain/models</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>none</dependencies>
</task_context>

# Tarefa 2.0: Create DistanceBracket Enum and Logic

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa implementa o sistema de agrupamento por distância que organiza restaurantes em categorias visuais ("Muito perto", "Perto", etc.). O enum `DistanceBracket` encapsula a lógica de classificação e fornece metadados para renderização de headers de seção.

<requirements>
- Enum deve cobrir todas as faixas de distância sem gaps
- Display names devem estar em português brasileiro
- Lógica de `contains` deve ser performática (usado em loops)
- Enum deve ser `CaseIterable` para permitir iteração
</requirements>

## Subtarefas

- [ ] 2.1 Criar arquivo `DistanceBracket.swift` em `ChooseThere/Domain/Models/`
- [ ] 2.2 Definir enum com conformidade a `CaseIterable`
- [ ] 2.3 Implementar `displayName` com labels localizados
- [ ] 2.4 Implementar `range` property com `ClosedRange<Double>`
- [ ] 2.5 Implementar método `contains(distanceKm:)` usando range

## Detalhes de Implementação

Consulte `techspec.md` seção "Enum DistanceBracket" (linhas 135-167) para especificação completa.

**Faixas de distância (conforme PRD):**
- `.veryClose`: < 1km (0...0.999)
- `.close`: 1-3km (1...2.999)
- `.medium`: 3-5km (3...4.999)
- `.far`: > 5km (5...Double.infinity)

**Implementação de contains:**
```swift
func contains(distanceKm: Double) -> Bool {
  range.contains(distanceKm)
}
```

**Display names:**
- veryClose: "Muito perto"
- close: "Perto"
- medium: "Média distância"
- far: "Mais distante"

## Critérios de Sucesso

- Enum compila sem erros
- Todos os 4 casos estão implementados: veryClose, close, medium, far
- Ranges cobrem toda a faixa de 0 a infinito sem overlaps
- Display names estão corretos e em português
- Método `contains` retorna valores corretos para casos de borda (0.999, 1.0, 2.999, 3.0, etc)
- Código formatado com 2-space indentation

## Arquivos relevantes
- Criar: `ChooseThere/Domain/Models/DistanceBracket.swift`
- Referência: `techspec.md` (linhas 135-167)
- Referência: `prd.md` (linhas 100-109 - definição de agrupamento)
