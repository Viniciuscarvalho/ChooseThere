# [7.0] Create UnifiedRestaurantCard Component (M)

## Objetivo
- Criar componente de card unificado que renderiza tanto `Restaurant` quanto `NearbyPlace`
- Implementar layout completo: imagem, nome, categoria, distância, rating, badge, quick actions
- Garantir consistência visual independente da fonte de dados
- Suportar interações: tap no card, tap em quick actions
- Implementar acessibilidade completa

## Subtarefas
- [ ] 7.1 Criar arquivo `UnifiedRestaurantCard.swift` em `ChooseThere/Presentation/Components/`
- [ ] 7.2 Implementar struct com properties: item, onTap, onQuickAction
- [ ] 7.3 Criar seção de imagem/placeholder (80x80pt)
- [ ] 7.4 Criar seção de conteúdo (nome, categoria, distância, rating)
- [ ] 7.5 Integrar DataSourceBadge no canto superior direito
- [ ] 7.6 Adicionar row de quick actions
- [ ] 7.7 Implementar formatação de distância (km vs metros)
- [ ] 7.8 Aplicar styling (padding, background, border)
- [ ] 7.9 Adicionar gestures (onTapGesture)
- [ ] 7.10 Adicionar accessibility labels
- [ ] 7.11 Criar SwiftUI previews com Restaurant e NearbyPlace

## Critérios de Sucesso
- Card renderiza corretamente para ambos Restaurant e NearbyPlace
- Layout é consistente entre diferentes fontes
- Badge aparece no canto superior direito do conteúdo
- Quick actions aparecem e são clicáveis
- Distância formata corretamente: < 1km mostra metros, >= 1km mostra km
- Imagem/placeholder tem 80x80pt com corner radius 12pt
- Card tem largura total, padding 12pt, corner radius 16pt
- VoiceOver navega logicamente (imagem → nome → distância → ações)
- Preview mostra ambos tipos de items

## Dependências
- **Task 1.0**: Protocol `NearbyDisplayable` e enum `QuickAction`
- **Task 3.0**: Extensions de Restaurant e NearbyPlace
- **Task 5.0**: Componente `DataSourceBadge`

## Observações
- Card recebe closures para interações (onTap, onQuickAction)
- Imagem usa AsyncImage se URL disponível, caso contrário SF Symbol placeholder
- Rating só aparece se `displayRating` não é nil
- Quick actions usam SF Symbols: "safari" (TripAdvisor), "fork.knife" (iFood), "car" (99), "map" (Maps)
- Card height não é fixo, se adapta ao conteúdo
- Border sutil usa `AppColors.divider.opacity(0.5)`

## status: pending

<task_context>
<domain>presentation/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>task_1,task_3,task_5</dependencies>
</task_context>

# Tarefa 7.0: Create UnifiedRestaurantCard Component

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Este é o componente visual principal da feature. O `UnifiedRestaurantCard` renderiza qualquer item que conforme com `NearbyDisplayable`, seja `Restaurant` ou `NearbyPlace`, com layout consistente. É usado na lista vertical de resultados.

<requirements>
- Aceitar qualquer tipo `any NearbyDisplayable`
- Layout responsivo que se adapta a dados disponíveis
- Integrar DataSourceBadge para indicar fonte
- Suportar quick actions dinâmicas baseadas em item
- Formatação inteligente de distância (m vs km)
- Accessibility completa com navegação lógica
</requirements>

## Subtarefas

- [ ] 7.1 Criar arquivo `UnifiedRestaurantCard.swift` em `ChooseThere/Presentation/Components/`
- [ ] 7.2 Definir struct com properties: item, onTap closure, onQuickAction closure
- [ ] 7.3 Implementar computed property `itemImage` para imagem/placeholder
- [ ] 7.4 Criar HStack principal (imagem + conteúdo)
- [ ] 7.5 Implementar VStack de conteúdo (nome+badge, categoria, distância, rating)
- [ ] 7.6 Adicionar HStack de quick actions
- [ ] 7.7 Implementar private func `formatDistance`
- [ ] 7.8 Implementar private func `quickActionButton`
- [ ] 7.9 Aplicar styling completo (background, corner radius, overlay border)
- [ ] 7.10 Adicionar onTapGesture no card
- [ ] 7.11 Adicionar accessibility modifiers
- [ ] 7.12 Criar #Preview com Restaurant e NearbyPlace mockados

## Detalhes de Implementação

Consulte `techspec.md` seção "UnifiedRestaurantCard" (linhas 265-345) para implementação completa.

**Properties:**
```swift
let item: any NearbyDisplayable
let onTap: () -> Void
let onQuickAction: (QuickAction) -> Void
```

**Estrutura principal:**
```swift
HStack(spacing: 12) {
  itemImage
    .frame(width: 80, height: 80)
    .clipShape(RoundedRectangle(cornerRadius: 12))

  VStack(alignment: .leading, spacing: 4) {
    // Nome + Badge
    // Categoria
    // Distância
    // Rating (condicional)
    // Quick actions
  }
}
.padding(12)
.background(AppColors.surface)
.clipShape(RoundedRectangle(cornerRadius: 16))
.overlay(border)
```

**Formatação de distância:**
```swift
private func formatDistance(_ km: Double) -> String {
  if km < 1 {
    return String(format: "%.0f m", km * 1000)
  }
  return String(format: "%.1f km", km)
}
```

**Quick action button:**
- Usar SF Symbols: "safari", "fork.knife", "car.fill", "map"
- Tamanho consistente: 32x32pt
- Background circle com AppColors.surface
- Mapear QuickAction para símbolo correto

**Tipografia (conforme PRD):**
- Nome: 17pt semibold
- Categoria: 13pt regular, tertiary color
- Distância: 15pt regular, secondary color
- Rating: 13pt medium

## Critérios de Sucesso

- Card compila e renderiza sem erros
- Restaurant com imagem mostra AsyncImage
- NearbyPlace sem imagem mostra placeholder (SF Symbol "fork.knife.circle.fill")
- Badge aparece alinhado ao topo direito junto com nome
- Distância < 1km mostra em metros (ex: "850 m")
- Distância >= 1km mostra em km (ex: "2.3 km")
- Rating só aparece quando displayRating não é nil
- Quick actions mostram apenas ações disponíveis para o item
- Tap no card chama onTap closure
- Tap em quick action button chama onQuickAction com ação correta
- Border sutil de 1pt com AppColors.divider.opacity(0.5)
- Preview mostra pelo menos 2 cards: Restaurant completo e NearbyPlace básico
- VoiceOver navega elementos na ordem lógica
- Código formatado com 2-space indentation e MARK comments

## Arquivos relevantes
- Criar: `ChooseThere/Presentation/Components/UnifiedRestaurantCard.swift`
- Referência: `ChooseThere/Presentation/Components/DataSourceBadge.swift` (componente usado)
- Referência: `ChooseThere/Domain/Protocols/NearbyDisplayable.swift` (protocol e enums)
- Referência: `AppColors.swift` (cores)
- Referência: `techspec.md` (linhas 265-345)
- Referência: `prd.md` (linhas 80-92 - requisitos de design unificado)
