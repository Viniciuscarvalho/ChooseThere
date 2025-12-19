# [6.0] Navegação: TabBar no fluxo e retorno amigável (L)

## Objetivo
- Tornar o fluxo “sorteio -> detalhe -> avaliar” mais amigável, mantendo TabBar disponível e garantindo que “voltar” sempre leve para um estado consistente (sem retornar para uma animação confusa após abrir Maps externo).

## Subtarefas
- [ ] 6.1 Definir a estratégia de navegação (stack do `AppRouter` + tab selection) para o fluxo
- [ ] 6.2 Ajustar `RouletteView` para direcionar para detalhe com TabBar (ex.: `navigateFromTabs`)
- [ ] 6.3 Garantir que `ResultView` e `RatingView` não isolem o usuário (TabBar disponível e back previsível)
- [ ] 6.4 Revisar retornos após abrir Maps externo: voltar para detalhe/tab correta

## Critérios de Sucesso
- Usuário consegue trocar de aba em qualquer ponto do fluxo (exceto onboarding).
- Ao voltar do Maps externo, o app não “reabre” uma etapa confusa do sorteio; o retorno é previsível.
- Fluxos principais (lista -> detalhe, sorteio -> detalhe, detalhe -> avaliar) têm caminhos claros de retorno.

## Dependências
- Nenhuma obrigatória (mas pode depender de pequenos ajustes na arquitetura de Root/Router).

## Observações
- Hoje `RootView` troca views baseado em `router.current`. Pode ser necessário adaptar para sempre renderizar `MainTabView` e empilhar rotas sobre as tabs.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/navigation</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>configuration</dependencies>
</task_context>

# Tarefa 6.0: Navegação: TabBar no fluxo e retorno amigável

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Reestruturar/ajustar a navegação para que o usuário não fique preso em telas sem TabBar, e para que o fluxo do sorteio/detalhe seja consistente mesmo após abrir o Maps externo.

<requirements>
- TabBar disponível e funcional no fluxo principal (sorteio/detalhe/avaliação/lista/histórico)
- “Voltar” sempre funciona e retorna para o contexto correto
- Fluxo do sorteio deve permitir navegar para outras opções (ex.: lista) sem fricção
</requirements>

## Subtarefas

- [ ] 6.1 Mapear rotas atuais (`AppRoute`) e pontos de push/pop/reset no `AppRouter`
- [ ] 6.2 Ajustar `RouletteView` para navegar para detalhe a partir das tabs (ex.: `navigateFromTabs(to:)`) em vez de empilhar uma rota isolada
- [ ] 6.3 Ajustar `RootView/MainTabView` para suportar sobreposição de rotas sem perder TabBar
- [ ] 6.4 Revisar `ResultView`/`RatingView` para ter caminhos claros (back + troca de tabs)

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seção **Arquitetura do Sistema** e **Sequenciamento**

## Critérios de Sucesso

- Navegação consistente para os cenários:
  - Lista -> Detalhe -> Voltar (retorna para lista)
  - Sorteio -> Detalhe -> Voltar (retorna para tabs/contexto adequado, não para animação confusa)
  - Detalhe -> Avaliar -> Voltar/Salvar (retorno previsível)
- TabBar disponível durante o fluxo (quando apropriado)

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppRoute.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppRouter.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/RootView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/MainTabView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RouletteView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RatingView.swift`

