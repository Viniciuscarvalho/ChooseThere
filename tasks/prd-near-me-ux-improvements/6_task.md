# [6.0] Create DistanceGroupHeaderView Component (S)

## Objetivo
- Criar componente SwiftUI para header de seção de grupos de distância
- Exibir nome do bracket ("Muito perto", "Perto", etc) e contagem de restaurantes
- Aplicar styling sutil para diferenciar headers de cards
- Garantir acessibilidade combinando elementos para leitores de tela

## Subtarefas
- [ ] 6.1 Criar arquivo `DistanceGroupHeaderView.swift` em `ChooseThere/Presentation/Components/`
- [ ] 6.2 Implementar SwiftUI view recebendo `bracket` e `count`
- [ ] 6.3 Criar layout com HStack (nome • contador)
- [ ] 6.4 Adicionar separador visual (circle) entre nome e contador
- [ ] 6.5 Aplicar styling com background sutil
- [ ] 6.6 Adicionar accessibility element combinado
- [ ] 6.7 Criar SwiftUI preview com diferentes contagens

## Critérios de Sucesso
- Header renderiza nome do bracket e contagem corretamente
- Separador visual (circle) aparece entre elementos
- Pluralização está correta ("1 restaurante" vs "2 restaurantes")
- Background sutil diferencia header de cards
- VoiceOver lê header como elemento único combinado
- Preview mostra headers com contagens diferentes (1, 3, 10)
- Código segue Kodeco Swift Style Guide

## Dependências
- **Task 2.0**: Enum `DistanceBracket` deve estar implementado

## Observações
- Header deve ser discreto mas claramente separar seções
- Background usa `AppColors.surface.opacity(0.5)` para sutileza
- Circle separator tem 4pt de diâmetro, cor tertiary
- Font sizes: 15pt semibold para nome, 13pt regular para contador
- Accessibility combina children para leitura fluida

## status: pending

<task_context>
<domain>presentation/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>task_2</dependencies>
</task_context>

# Tarefa 6.0: Create DistanceGroupHeaderView Component

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Este componente renderiza os headers de seção que separam grupos de distância na lista vertical. Cada header mostra o nome do bracket ("Muito perto", "Perto") e a contagem de restaurantes naquele grupo.

<requirements>
- Layout horizontal com nome, separador, e contagem
- Styling sutil que não compete visualmente com cards
- Pluralização correta em português (restaurante/restaurantes)
- Accessibility combina elementos para leitura natural
</requirements>

## Subtarefas

- [ ] 6.1 Criar arquivo `DistanceGroupHeaderView.swift` em `ChooseThere/Presentation/Components/`
- [ ] 6.2 Implementar struct DistanceGroupHeaderView: View
- [ ] 6.3 Adicionar properties: bracket (DistanceBracket), count (Int)
- [ ] 6.4 Criar HStack com nome, circle separator, contador
- [ ] 6.5 Aplicar fonts e colors corretos
- [ ] 6.6 Adicionar padding e background
- [ ] 6.7 Adicionar accessibility modifiers
- [ ] 6.8 Criar #Preview com múltiplos exemplos

## Detalhes de Implementação

Consulte `techspec.md` seção "DistanceGroupHeaderView" (linhas 383-413) para implementação completa.

**Estrutura visual:**
```swift
HStack {
  Text(bracket.displayName)
    .font(.system(size: 15, weight: .semibold))
    .foregroundColor(AppColors.textPrimary)

  Circle()
    .fill(AppColors.textTertiary)
    .frame(width: 4, height: 4)

  Text("\(count) \(count == 1 ? "restaurante" : "restaurantes")")
    .font(.system(size: 13))
    .foregroundColor(AppColors.textSecondary)

  Spacer()
}
.padding(.horizontal, 16)
.padding(.vertical, 8)
.background(AppColors.surface.opacity(0.5))
```

**Accessibility:**
```swift
.accessibilityElement(children: .combine)
.accessibilityLabel("\(bracket.displayName), \(count) restaurantes")
```

**Pluralização:**
- 1 restaurante (singular)
- 2+ restaurantes (plural)
- Usar operador ternário inline para simplicidade

## Critérios de Sucesso

- Componente compila e renderiza corretamente
- Nome do bracket aparece em 15pt semibold
- Circle separator de 4pt aparece entre nome e contagem
- Contagem usa pluralização correta
- Background tem opacity 0.5 para sutileza
- Padding horizontal 16pt, vertical 8pt
- VoiceOver combina elementos e lê como frase única
- Preview mostra pelo menos 3 exemplos com contagens variadas
- Código formatado seguindo style guide
- Separador usa AppColors.textTertiary

## Arquivos relevantes
- Criar: `ChooseThere/Presentation/Components/DistanceGroupHeaderView.swift`
- Referência: `ChooseThere/Domain/Models/DistanceBracket.swift` (enum)
- Referência: `AppColors.swift` (cores)
- Referência: `techspec.md` (linhas 383-413)
- Referência: `prd.md` (linha 104 - formato de header com contador)
