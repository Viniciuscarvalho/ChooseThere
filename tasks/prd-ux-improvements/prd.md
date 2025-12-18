# PRD - Melhorias de UX e Navegação

## Visão Geral

Este documento descreve melhorias de experiência do usuário no app ChooseThere, incluindo um novo sistema de navegação por TabBar, onboarding explicativo, uma nova tela de listagem de restaurantes, e correções de layout nas telas existentes.

**Problema atual:**
- Não existe forma de navegar entre Histórico e Sortear facilmente
- Usuário não tem visibilidade de todos os restaurantes disponíveis
- Novos usuários não entendem como o app funciona
- Layout da tela de resultado tem espaço desperdiçado abaixo do mapa
- Layout do detalhe do histórico corta o nome do restaurante

## Objetivos

1. **Navegação intuitiva**: Permitir acesso rápido entre as 3 áreas principais do app
2. **Onboarding educativo**: Explicar as funcionalidades ao primeiro uso
3. **Descoberta de restaurantes**: Permitir visualizar todos os 115+ restaurantes
4. **Layout otimizado**: Corrigir problemas visuais nas telas existentes
5. **Métricas de sucesso**:
   - Tempo para primeiro sorteio < 30 segundos
   - Usuários conseguem acessar histórico sem sair do fluxo de sorteio
   - Zero cortes de texto visíveis

## Histórias de Usuário

### US-01: Navegação por TabBar
> Como usuário, eu quero ter uma barra de navegação fixa para que eu possa alternar entre Histórico, Sortear e Lista de Restaurantes sem perder meu contexto.

### US-02: Onboarding explicativo
> Como novo usuário, eu quero ver uma explicação de como o app funciona para que eu entenda o fluxo de sorteio, avaliação e histórico antes de usar.

### US-03: Lista de restaurantes
> Como usuário, eu quero ver todos os restaurantes disponíveis no app para que eu possa explorar opções e conhecer o catálogo completo.

### US-04: Layout do mapa otimizado
> Como usuário, eu quero que o mapa ocupe mais espaço na tela de resultado para ter uma melhor visualização da localização.

### US-05: Nome completo do restaurante
> Como usuário, eu quero ver o nome completo do restaurante no detalhe do histórico para identificar corretamente qual lugar visitei.

## Funcionalidades Principais

### 1. TabBar de Navegação

**O que faz:**
Barra de navegação fixa na parte inferior da tela com 3 abas.

**Por que é importante:**
Permite navegação rápida sem voltar várias telas.

**Como funciona:**
- Aba esquerda: Histórico (ícone `clock.arrow.circlepath`)
- Aba central (destacada): Sortear (ícone `dice.fill`)
- Aba direita: Restaurantes (ícone `list.bullet`)

**Requisitos funcionais:**
1. F1.1: TabBar visível nas telas principais (Preferences, History, RestaurantList)
2. F1.2: Ícone central maior/destacado como ação principal
3. F1.3: Indicador visual da aba selecionada
4. F1.4: Transição suave entre abas

### 2. Onboarding

**O que faz:**
Tela de boas-vindas com 3-4 passos explicando o app.

**Por que é importante:**
Reduz fricção para novos usuários.

**Como funciona:**
- Slide 1: "Escolha suas preferências" (ícone tags)
- Slide 2: "Sorteie um restaurante" (ícone dice)
- Slide 3: "Avalie sua experiência" (ícone star)
- Slide 4: "Acompanhe seu histórico" (ícone clock)
- Botão "Começar" no último slide
- Mostrar apenas na primeira abertura (UserDefaults)

**Requisitos funcionais:**
1. F2.1: 3-4 slides com animação de transição
2. F2.2: Indicador de progresso (dots)
3. F2.3: Botão "Pular" em todos os slides
4. F2.4: Flag `hasSeenOnboarding` em UserDefaults
5. F2.5: Animações sutis em cada slide

### 3. Lista de Restaurantes

**O que faz:**
Exibe todos os ~115 restaurantes do JSON em lista pesquisável.

**Por que é importante:**
Permite descoberta e exploração do catálogo.

**Como funciona:**
- Lista agrupada por categoria
- Barra de busca no topo
- Filtro por tags
- Tap navega para detalhes do restaurante

**Requisitos funcionais:**
1. F3.1: Lista com todos os restaurantes
2. F3.2: Busca por nome
3. F3.3: Filtro por categoria/tags
4. F3.4: Indicador de favoritos
5. F3.5: Tap abre detalhes (ResultView)

### 4. Ajuste de Layout - Tela de Resultado

**O que faz:**
Otimiza o espaço da tela de resultado do sorteio.

**Por que é importante:**
Melhor experiência visual e aproveitamento do mapa.

**Requisitos funcionais:**
1. F4.1: Mapa deve ocupar ~45% da altura da tela
2. F4.2: Remover espaçamentos desnecessários
3. F4.3: Card do restaurante com sobreposição suave no mapa

### 5. Ajuste de Layout - Detalhe do Histórico

**O que faz:**
Corrige o corte do nome do restaurante.

**Requisitos funcionais:**
1. F5.1: Nome do restaurante sem truncamento
2. F5.2: Card com altura dinâmica
3. F5.3: Melhor espaçamento entre elementos

## Experiência do Usuário

### Fluxo Principal (com TabBar)
```
[Onboarding] → [TabBar Principal]
                    ├── Tab Histórico → [Lista] → [Detalhe]
                    ├── Tab Sortear → [Preferências] → [Roleta] → [Resultado] → [Avaliação]
                    └── Tab Restaurantes → [Lista] → [Detalhe]
```

### Considerações de UI/UX
- TabBar usa cores do DesignSystem (Primary para selecionado)
- Aba central (Sortear) é destacada como FAB-style
- Transições entre abas são instantâneas
- Onboarding usa animações suaves e cores vibrantes

### Acessibilidade
- Todos os ícones têm `accessibilityLabel`
- TabBar navegável por VoiceOver
- Contraste mínimo de 4.5:1 em todos os textos

## Restrições Técnicas de Alto Nível

- **Navegação**: Manter compatibilidade com o Router atual para telas internas
- **Performance**: Lista de restaurantes deve usar LazyVStack
- **Persistência**: Flag de onboarding em UserDefaults (não SwiftData)
- **iOS mínimo**: iOS 17.0 (SwiftData, Observation)

## Não-Objetivos (Fora de Escopo)

- ❌ Dark mode (será implementado posteriormente)
- ❌ Animações complexas na TabBar
- ❌ Busca com fuzzy matching
- ❌ Mapa na lista de restaurantes
- ❌ Ordenação customizada na lista

## Questões em Aberto

1. **Q1**: Deve haver animação de transição entre tabs ou corte seco?
   - **Resposta proposta**: Crossfade simples (0.2s)

2. **Q2**: O onboarding deve ser pulável desde o primeiro slide?
   - **Resposta proposta**: Sim, botão "Pular" sempre visível

3. **Q3**: A aba Sortear deve manter estado se o usuário alternar abas?
   - **Resposta proposta**: Sim, preservar preferências selecionadas


