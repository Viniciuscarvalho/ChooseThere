# [2.0] Implementar TabBar de navegação principal (M)

## Objetivo
Criar uma TabBar customizada com 3 abas (Histórico, Sortear, Restaurantes) que permite navegação rápida entre as áreas principais do app. A aba central (Sortear) deve ser destacada visualmente.

## Subtarefas
- [ ] 2.1 Criar enum `Tab` com cases history, draw, restaurants
- [ ] 2.2 Criar componente `CustomTabBar` com design do app
- [ ] 2.3 Criar `MainTabView` que gerencia as abas
- [ ] 2.4 Integrar MainTabView no RootView (após onboarding)
- [ ] 2.5 Implementar aba central destacada (estilo FAB)
- [ ] 2.6 Adicionar transição suave entre abas
- [ ] 2.7 Garantir safe area em todos os iPhones

## Critérios de Sucesso
- TabBar visível nas 3 telas principais
- Aba central visivelmente destacada
- Indicador claro de aba selecionada
- Navegação preserva estado de cada aba
- Funciona corretamente em iPhone SE e iPhone 15 Pro Max

## Dependências
- 1.0 (para integração do fluxo completo)

## Observações
- Manter Router funcionando para navegação interna (Roulette → Result → Rating)
- TabBar não aparece durante fluxo de sorteio (apenas nas 3 telas principais)
- Usar `safeAreaInset(edge: .bottom)` para evitar conflitos

## status: pending

<task_context>
<domain>presentation</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>Task 1.0</dependencies>
</task_context>

## Detalhes de Implementação

Consultar `techspec.md` para:
- Enum `Tab` com ícones e títulos
- Estrutura da `MainTabView`
- Fluxo de navegação

### Design da TabBar

```
┌─────────────────────────────────────────┐
│                                         │
│     [🕐]        [🎲]        [📋]       │
│   Histórico   Sortear   Restaurantes   │
│               (maior)                   │
└─────────────────────────────────────────┘
```

- Aba central: círculo colorido maior (AppColors.primary)
- Outras abas: ícones menores com AppColors.textSecondary (inativo) ou AppColors.primary (ativo)
- Background: AppColors.surface com sombra sutil

## Arquivos relevantes
- `ChooseThere/Presentation/Views/MainTabView.swift` (criar)
- `ChooseThere/Presentation/Components/CustomTabBar.swift` (criar)
- `ChooseThere/Application/RootView.swift` (modificar)





