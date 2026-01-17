# Documento de Requisitos de Produto (PRD)
## Melhorias na UX do Fluxo "Perto de Mim"

## Visão Geral

O modo "Perto de mim" é uma funcionalidade essencial do ChooseThere que ajuda usuários a descobrir restaurantes próximos à sua localização atual. Atualmente, o fluxo apresenta quatro problemas principais que impactam a experiência do usuário:

1. **Confusão visual**: Apresentação horizontal de 10-15 cards dificulta a navegação e comparação
2. **Inconsistência de abas**: A aba "Minha Lista" aparece em todas as cidades, mas só é relevante em São Paulo
3. **Confusão de fontes de dados**: Usuários não entendem quando estão vendo resultados da base local vs Apple Maps
4. **Fricção de permissões**: Solicitação de localização interrompe o fluxo no momento errado

Esta melhoria visa criar um fluxo mais claro, contextualizado e eficiente para que usuários encontrem e escolham restaurantes próximos com confiança.

**Público-alvo**: Usuários do ChooseThere em todo o Brasil que buscam descobrir restaurantes próximos à sua localização atual.

**Valor**: Aumentar a taxa de conclusão da jornada "Perto de mim" (clique no botão "Sortear") através de uma experiência mais clara e confiável.

## Objetivos

### Objetivo Principal
- **Aumentar em 25% o uso do botão "Sortear perto de mim"** nos próximos 60 dias após lançamento

### Objetivos Secundários
- Reduzir confusão do usuário: diminuir abandonos na tela de preferências em 40%
- Melhorar clareza de contexto: 100% dos usuários entendem qual fonte de dados estão visualizando
- Otimizar tempo até resultado: reduzir em 30% o tempo médio entre abrir "Perto de mim" e ver resultados

### Métricas de Acompanhamento
- Taxa de clique no botão "Sortear perto de mim"
- Taxa de abandono na tela PreferencesView (modo Nearby)
- Tempo médio até primeiro resultado
- Taxa de concessão de permissão de localização
- NPS específico para funcionalidade "Perto de mim"

## Histórias de Usuário

### Usuário em São Paulo (SP)

**US1**: Como usuário em São Paulo, eu quero ver a aba "Minha Lista" para que eu possa acessar meus restaurantes favoritos salvos localmente.

**US2**: Como usuário em SP usando "Perto de mim", eu quero entender claramente se estou vendo resultados da "Minha Base" ou "Apple Maps" para que eu saiba a origem das recomendações.

**US3**: Como usuário em SP, eu quero visualizar resultados em formato de lista vertical para que eu possa facilmente comparar distâncias, avaliações e detalhes de múltiplos restaurantes.

### Usuário Fora de São Paulo

**US4**: Como usuário fora de São Paulo, eu quero ver apenas a aba "Perto de mim" para que eu não fique confuso com opções que não se aplicam à minha localização.

**US5**: Como usuário em qualquer cidade brasileira, eu quero que o app solicite permissão de localização no onboarding para que o processo seja educativo e não interrompa meu fluxo de busca.

### Fluxo de Troca de Cidade

**US6**: Como usuário que troca de São Paulo para outra cidade, eu quero que minha "Minha Lista" seja preservada (mas oculta) para que eu não perca meus dados ao voltar para SP.

**US7**: Como usuário que volta para São Paulo após estar em outra cidade, eu quero que a aba "Minha Lista" reapareça automaticamente com meus dados intactos.

### Clareza Visual

**US8**: Como usuário visualizando resultados, eu quero ver cards de restaurantes com design unificado para que a experiência seja consistente independentemente da fonte de dados.

**US9**: Como usuário com muitos resultados, eu quero ver os restaurantes agrupados por relevância (distância, avaliação) para que eu possa focar nas melhores opções rapidamente.

## Funcionalidades Principais

### 1. Visibilidade Condicional da Aba "Minha Lista"

**O que faz**: Exibe ou oculta a aba "Minha Lista" com base na cidade selecionada pelo usuário.

**Por que é importante**: Reduz confusão ao mostrar apenas opções relevantes para a localização do usuário.

**Como funciona**:
- FR1.1: A aba "Minha Lista" deve ser visível APENAS quando a cidade selecionada é "São Paulo|SP"
- FR1.2: Quando o usuário seleciona qualquer outra cidade, a aba deve ser completamente ocultada
- FR1.3: A aba "Perto de mim" deve estar sempre visível para todos os usuários
- FR1.4: Ao ocultar a aba, o modo ativo deve automaticamente mudar para "Perto de mim"
- FR1.5: Os dados de "Minha Lista" devem ser preservados mesmo quando a aba está oculta
- FR1.6: Quando o usuário retorna para São Paulo, a aba deve reaparecer com todos os dados intactos

### 2. Design Unificado de Cards de Restaurantes

**O que faz**: Padroniza a apresentação visual de restaurantes independentemente da fonte de dados (Minha Base ou Apple Maps).

**Por que é importante**: Cria consistência visual e reduz carga cognitiva ao processar informações.

**Como funciona**:
- FR2.1: RestaurantCard e NearbyPlaceCard devem usar o mesmo layout base e hierarquia visual
- FR2.2: Todos os cards devem exibir: imagem/ícone, nome, distância, categoria, e avaliação (quando disponível)
- FR2.3: Fonte de dados deve ser indicada através de um badge discreto ("Minha Base" ou "Apple Maps")
- FR2.4: Badges devem usar cores distintas mas complementares (ex: Minha Base = primary color, Apple Maps = accent color)
- FR2.5: Ações rápidas (TripAdvisor, iFood, Maps, Rota) devem estar sempre na mesma posição

### 3. Apresentação em Lista Vertical com Agrupamento

**O que faz**: Transforma a visualização horizontal de cards em uma lista vertical scrollável com agrupamento inteligente.

**Por que é importante**: Facilita comparação e escaneamento rápido de múltiplas opções.

**Como funciona**:
- FR3.1: Substituir scroll horizontal por lista vertical (LazyVStack)
- FR3.2: Cards devem ocupar toda a largura disponível com altura consistente
- FR3.3: Resultados devem ser agrupados em seções:
  - "Muito perto" (< 1km)
  - "Perto" (1-3km)
  - "Média distância" (3-5km)
  - "Mais distante" (> 5km)
- FR3.4: Cada grupo deve ter um header com contador (ex: "Muito perto • 3 restaurantes")
- FR3.5: Dentro de cada grupo, ordenar por avaliação (quando disponível) ou alfabeticamente
- FR3.6: Máximo de 15 resultados exibidos inicialmente, com opção "Ver mais" se houver mais resultados

### 4. Indicadores Visuais de Fonte de Dados

**O que faz**: Mostra claramente de onde vêm os resultados apresentados.

**Por que é importante**: Aumenta transparência e confiança do usuário nas recomendações.

**Como funciona**:
- FR4.1: Badge de fonte no canto superior direito de cada card
- FR4.2: Cor do badge: "Minha Base" usa AppColors.primary, "Apple Maps" usa AppColors.accent
- FR4.3: Ícone do badge: "Minha Base" = disco/database icon, "Apple Maps" = logo Apple Maps
- FR4.4: Ao tocar no badge, exibir tooltip explicando a fonte:
  - "Minha Base: restaurantes da curadoria local de São Paulo"
  - "Apple Maps: estabelecimentos do banco de dados Apple Maps"
- FR4.5: Header da seção de resultados também deve indicar fonte ativa e quantidade

### 5. Fluxo Proativo de Permissão de Localização

**O que faz**: Solicita e educa sobre permissão de localização durante o onboarding, antes do usuário chegar ao modo "Perto de mim".

**Por que é importante**: Reduz interrupções no fluxo de busca e aumenta taxa de concessão de permissão.

**Como funciona**:
- FR5.1: Durante primeiro acesso ao app, incluir tela de onboarding explicando benefício da localização
- FR5.2: Tela deve mostrar:
  - Ilustração/animação de restaurante próximo
  - Título: "Descubra restaurantes perto de você"
  - Descrição: "Permitir acesso à localização ajuda a encontrar as melhores opções próximas"
  - Botão primário: "Permitir localização"
  - Botão secundário: "Agora não"
- FR5.3: Solicitar permissão apenas após usuário tocar no botão primário
- FR5.4: Se usuário escolher "Agora não", não solicitar novamente até que acesse "Perto de mim"
- FR5.5: No modo "Perto de mim", se permissão não concedida, exibir card informativo (não modal):
  - "Para usar esta função, precisamos acessar sua localização"
  - Botão: "Ir para Configurações"
- FR5.6: Estado de permissão deve ser persistido e verificado silenciosamente em segundo plano

## Experiência do Usuário

### Personas

**Persona 1: Marina - Exploradora de SP**
- Mora em São Paulo, usa o app semanalmente
- Mantém lista curada de favoritos
- Prioriza praticidade e confiabilidade
- Precisa: visualização clara da "Minha Lista" e diferenciação entre base local e Apple Maps

**Persona 2: Carlos - Viajante Ocasional**
- Usa o app em diferentes cidades do Brasil
- Não tem lista salva, busca descobertas rápidas
- Prioriza velocidade e facilidade
- Precisa: interface limpa sem opções irrelevantes, permissões sem fricção

### Fluxo Principal de Usuário

1. **Onboarding (primeira vez)**
   - Usuário abre app pela primeira vez
   - Vê tela de permissão de localização contextualizada
   - Concede permissão (ou pula)
   - Chega ao app com permissão já configurada

2. **Acesso ao "Perto de mim" (SP)**
   - Usuário vê duas abas: "Minha Lista" | "Perto de mim"
   - Seleciona "Perto de mim"
   - Vê cidade "São Paulo|SP" com opção de alterar
   - Escolhe fonte: "Minha base" ou "Apple Maps" (ou deixa default)
   - Ajusta raio de busca (default 3km)
   - Toca "Sortear perto de mim"

3. **Visualização de resultados**
   - Lista vertical aparece com grupos de distância
   - Cada card mostra badge de fonte claramente
   - Usuário escaneia opções facilmente
   - Pode tocar em card individual para detalhes OU
   - Toca "Sortear perto de mim" para seleção aleatória

4. **Acesso ao "Perto de mim" (fora de SP)**
   - Usuário vê apenas aba "Perto de mim"
   - Vê cidade selecionada (ex: "Rio de Janeiro|RJ")
   - Fonte automaticamente definida como "Apple Maps" (sem opção de escolha)
   - Ajusta raio, toca "Sortear perto de mim"
   - Resultados aparecem com badges "Apple Maps"

5. **Troca de cidade (SP → outra cidade)**
   - Usuário em SP com "Minha Lista" ativa
   - Vai em configurações e muda para "Curitiba|PR"
   - Volta para tela principal
   - Aba "Minha Lista" desaparece suavemente (fade out)
   - Modo ativo muda automaticamente para "Perto de mim"
   - Dados de "Minha Lista" preservados em segundo plano

6. **Retorno para SP**
   - Usuário muda cidade de volta para "São Paulo|SP"
   - Aba "Minha Lista" reaparece (fade in)
   - Todos os dados anteriores estão intactos

### Considerações de UI/UX

**Layout**:
- Lista vertical scrollável com safe area
- Cards com largura total (leading/trailing padding 16pt)
- Altura de card consistente (~120pt)
- Espaçamento entre cards: 12pt
- Separadores de seção com background sutil

**Animações**:
- Transição de aba: spring animation (response: 0.3, damping: 0.8)
- Fade in/out de aba condicional: 0.25s linear
- Aparecimento de lista: staggered animation (cards aparecem sequencialmente, 0.05s delay)

**Tipografia**:
- Nome do restaurante: 17pt, semibold
- Distância: 15pt, regular, secondary color
- Categoria: 13pt, regular, tertiary color
- Badge: 11pt, medium, white

**Cores**:
- Badge "Minha Base": AppColors.primary com opacidade 90%
- Badge "Apple Maps": AppColors.accent com opacidade 90%
- Headers de grupo: background AppColors.surface, texto primary

### Requisitos de Acessibilidade

- AR1: Todos os badges devem ter labels de acessibilidade descrevendo a fonte
- AR2: Headers de grupo devem anunciar quantidade de itens para leitores de tela
- AR3: Botões de ação rápida devem ter hints descrevendo ação (ex: "Abre no TripAdvisor")
- AR4: Cards devem ser navegáveis via VoiceOver com foco lógico (imagem → nome → distância → ações)
- AR5: Suporte a tamanhos de fonte dinâmicos (Dynamic Type)
- AR6: Contraste mínimo de 4.5:1 para todo texto sobre backgrounds
- AR7: Estados de permissão devem ser claramente anunciados para usuários com deficiência visual

## Restrições Técnicas de Alto Nível

### Integrações Existentes
- **LocationManager**: Manter interface atual de solicitação e gerenciamento de permissões
- **AppleMapsNearbySearchService**: Não modificar API de busca existente
- **RestaurantRepository**: Manter queries e filtros atuais para base local
- **AppSettingsStorage**: Utilizar sistema de persistência existente para configurações

### Performance
- Lista de resultados deve renderizar em < 100ms após receber dados
- Animações devem manter 60 FPS em dispositivos iOS 15+
- Busca deve completar em < 2s em conexão 4G típica

### Compatibilidade
- iOS 15.0 ou superior (requisito atual do app)
- Suporte a todos os tamanhos de iPhone (SE até Pro Max)
- Modo claro e escuro (seguir tema do sistema)

### Privacidade
- Permissão de localização "When In Use" (não solicitar "Always")
- Não armazenar coordenadas GPS precisas, apenas cidade selecionada
- Dados de "Minha Lista" armazenados localmente (não sincronizados)

### Dados
- JSON de restaurantes (`Restaurants.json`) continua sendo fonte única para base local de SP
- Não adicionar novas cidades ao JSON nesta iteração

## Não-Objetivos (Fora de Escopo)

### Funcionalidades Explicitamente Excluídas

1. **Animação de roleta**: RouletteView permanece inalterada
2. **Telas de detalhe**: ResultView e NearbyPlaceDetailView não serão modificadas
3. **Sistema de filtros**: Tags, categorias e seletor de raio permanecem como estão
4. **Novas fontes de dados**: Não adicionar TripAdvisor, iFood ou outros provedores além dos existentes
5. **Edição de "Minha Lista"**: Funcionalidades de adicionar/remover restaurantes da lista não serão alteradas
6. **Sincronização entre dispositivos**: "Minha Lista" continua sendo apenas local
7. **Histórico de buscas**: Não incluir histórico de restaurantes visualizados ou sorteados
8. **Compartilhamento**: Funcionalidades de compartilhar restaurantes não serão adicionadas
9. **Notificações**: Nenhuma notificação push relacionada a restaurantes próximos

### Considerações Futuras (Não Agora)

- Adicionar mais cidades à base local (Minha Base)
- Permitir usuários criarem múltiplas listas customizadas
- Implementar filtros inteligentes baseados em horário (café da manhã, almoço, jantar)
- Integração com calendário para sugestões baseadas em eventos
- Modo offline com cache de resultados recentes

### Limites Conhecidos

- Precisão de distância depende da qualidade do GPS do dispositivo
- Resultados do Apple Maps limitados à disponibilidade de dados da Apple
- Base local (Minha Base) limitada a São Paulo até segunda fase
- Não suporta múltiplas cidades simultaneamente (usuário só pode ter uma cidade ativa)

## Questões em Aberto

### Requisitos a Esclarecer

1. **Agrupamento de distância**: Os thresholds propostos (< 1km, 1-3km, 3-5km, > 5km) estão alinhados com expectativas dos usuários? Considerar validar com dados de uso ou testes A/B.

2. **Quantidade máxima de resultados**: 15 resultados iniciais é o número ideal antes de "Ver mais"? Considerar testar 10, 15 ou 20 para otimizar scrolling vs completude.

3. **Onboarding de permissão**: A tela de permissão deve ser skippable para usuários avançados? Considerar adicionar opção "Don't ask again".

4. **Fallback de Apple Maps**: Quando busca no Apple Maps falha em SP, devemos automaticamente tentar "Minha Base" ou pedir confirmação do usuário?

5. **Animação de transição de aba**: Fade simples é suficiente ou devemos considerar animação mais elaborada (slide, scale)?

### Dependências de Design

6. **Ícones de badges**: Definir ícones específicos para "Minha Base" (disco? estrela curada?) e confirmar uso do logo Apple Maps.

7. **Empty state**: Como apresentar quando não há resultados em nenhuma fonte? Mensagem, ilustração, CTA?

8. **Loading states**: Durante busca, mostrar skeleton cards, spinner ou animação customizada?

### Questões de Negócio

9. **Métricas de sucesso**: Precisamos configurar analytics adicionais ou ferramentas existentes cobrem todas as métricas definidas?

10. **Cronograma de rollout**: Lançamento gradual (beta testers → cidade a cidade) ou full release?

11. **Comunicação com usuários**: Precisamos de changelog, tutorial in-app ou mensagem de "What's New" para explicar mudanças?

---

**Documento criado em**: 2026-01-17
**Versão**: 1.0
**Aprovador pendente**: Product Owner / Stakeholder responsável
