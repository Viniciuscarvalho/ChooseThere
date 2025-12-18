# [6.0] Testes e polimento final (S)

## Objetivo
Validar todas as implementações anteriores, corrigir bugs encontrados, garantir acessibilidade e consistência visual em todos os componentes.

## Subtarefas
- [ ] 6.1 Testar fluxo completo: Onboarding → TabBar → Sortear → Resultado → Avaliação
- [ ] 6.2 Verificar navegação entre abas preserva estado
- [ ] 6.3 Testar busca na lista de restaurantes
- [ ] 6.4 Validar layouts em iPhone SE, iPhone 15, iPhone 15 Pro Max
- [ ] 6.5 Verificar acessibilidade com VoiceOver
- [ ] 6.6 Corrigir warnings de compilação
- [ ] 6.7 Revisar consistência de cores e fontes

## Critérios de Sucesso
- Zero crashes durante navegação
- Todos os textos legíveis e sem cortes
- VoiceOver anuncia elementos corretamente
- Performance de scroll a 60fps
- Zero warnings de compilação

## Dependências
- 1.0, 2.0, 3.0, 4.0, 5.0 (todas as tasks anteriores)

## Observações
- Usar Xcode Accessibility Inspector
- Testar em simuladores de diferentes tamanhos
- Verificar memory leaks com Instruments

## status: pending

<task_context>
<domain>testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>Tasks 1.0-5.0</dependencies>
</task_context>

## Checklist de Validação

### Onboarding
- [ ] Aparece apenas na primeira abertura
- [ ] Botão "Pular" funciona em todos os slides
- [ ] Animações suaves
- [ ] Indicador de progresso atualiza

### TabBar
- [ ] 3 abas funcionais
- [ ] Aba central destacada
- [ ] Indicador de seleção visível
- [ ] Safe area respeitada

### Lista de Restaurantes
- [ ] Todos os 115+ restaurantes listados
- [ ] Busca filtra corretamente
- [ ] Categorias agrupadas
- [ ] Tap navega para detalhes

### Layout Resultado
- [ ] Mapa ocupa ~45% da tela
- [ ] Sem espaço vazio abaixo

### Layout Detalhe Histórico
- [ ] Nome completo visível
- [ ] Card expande corretamente

### Acessibilidade
- [ ] Todos os botões têm accessibilityLabel
- [ ] TabBar navegável por VoiceOver
- [ ] Contraste adequado

## Arquivos relevantes
- Todos os arquivos modificados nas tasks anteriores

