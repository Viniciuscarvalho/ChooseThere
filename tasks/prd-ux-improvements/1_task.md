# [1.0] Criar Onboarding com slides explicativos (M)

## Objetivo
Criar uma tela de onboarding com 3-4 slides que explique as funcionalidades do app (sorteio, avaliação, histórico) para novos usuários. A tela só aparece na primeira abertura do app.

## Subtarefas
- [ ] 1.1 Criar `OnboardingStorage` para gerenciar flag `hasSeenOnboarding` no UserDefaults
- [ ] 1.2 Redesenhar `OnboardingView` com TabView e PageTabViewStyle
- [ ] 1.3 Criar slides com ícones, títulos e descrições
- [ ] 1.4 Adicionar indicador de progresso (dots)
- [ ] 1.5 Implementar botão "Pular" e "Começar"
- [ ] 1.6 Adicionar animações sutis nos ícones
- [ ] 1.7 Integrar com RootView (verificar flag antes de mostrar)

## Critérios de Sucesso
- Onboarding aparece apenas na primeira abertura
- Usuário pode pular a qualquer momento
- Animações rodam a 60fps
- Texto legível e contrastante
- Botão "Começar" leva para MainTabView

## Dependências
- Nenhuma

## Observações
- Usar cores do DesignSystem (AppColors.primary, AppColors.accent)
- Ícones sugeridos: `tag.fill`, `dice.fill`, `star.fill`, `clock.arrow.circlepath`
- Textos devem ser curtos e objetivos

## status: pending

<task_context>
<domain>presentation</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>UserDefaults</dependencies>
</task_context>

## Detalhes de Implementação

Consultar `techspec.md` para:
- Estrutura do `OnboardingStorage`
- Integração com `RootView`

### Conteúdo dos Slides

1. **Slide 1**: "Escolha suas preferências"
   - Ícone: `tag.fill`
   - Descrição: "Selecione categorias e tags para filtrar restaurantes do seu jeito"

2. **Slide 2**: "Sorteie um restaurante"
   - Ícone: `dice.fill`
   - Descrição: "Deixe a sorte escolher entre os melhores lugares de São Paulo"

3. **Slide 3**: "Avalie sua experiência"
   - Ícone: `star.fill`
   - Descrição: "Registre sua visita e ajude a refinar futuras escolhas"

4. **Slide 4**: "Acompanhe seu histórico"
   - Ícone: `clock.arrow.circlepath`
   - Descrição: "Veja todos os lugares visitados e suas avaliações"

## Arquivos relevantes
- `ChooseThere/Presentation/Views/OnboardingView.swift` (modificar)
- `ChooseThere/Application/RootView.swift` (modificar)
- `ChooseThere/Application/OnboardingStorage.swift` (criar)







