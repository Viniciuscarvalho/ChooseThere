# PRD: Links Externos + Cards (Deliverio style)

## Visão Geral

O ChooseThere já permite listar restaurantes (Minha base) e descobrir lugares próximos (Perto de mim via Apple Maps). O objetivo desta funcionalidade é melhorar a experiência de descoberta e ação rápida, introduzindo **cards** modernos (estilo Deliverio: layout/cores/tipografia semelhantes usando o design system atual do app) e adicionando **atalhos para plataformas externas** (TripAdvisor, iFood e 99).

Como não serão usadas APIs pagas, os links externos serão **curados/salvos manualmente** por restaurante. Para melhorar a listagem visual, o app exibirá uma imagem do restaurante quando possível via **OpenGraph** (ex.: `og:image` do site do restaurante), com fallback para placeholder.

## Objetivos

- Melhorar a “explorabilidade” da listagem, com cards que mostrem: imagem, nome, categoria, rating interno, distância (quando aplicável) e ações rápidas.
- Permitir que o usuário navegue rapidamente para:
  - TripAdvisor (página exata, via URL salva)
  - iFood (página/loja exata, via URL salva)
  - 99 (via URL salva quando houver; caso contrário, fallback para rota no Apple Maps/Google Maps)
- Reduzir atrito na descoberta de lugares próximos (“Perto de mim”) com UI consistente com a lista (“Minha base”).

Métricas sugeridas:
- % de restaurantes com `tripAdvisorURL` preenchido
- % de cards com imagem carregada (manual ou OpenGraph)
- Cliques em “TripAdvisor / iFood / 99” por sessão
- Tempo até primeira ação (abrir link/abrir mapa) após busca

## Histórias de Usuário

- Como usuário, eu quero ver restaurantes em cards com imagem e informações principais para escolher mais rápido.
- Como usuário, eu quero abrir rapidamente o TripAdvisor/iFood do restaurante (quando eu já tiver o link salvo) sem precisar buscar manualmente.
- Como usuário, eu quero chamar a rota no mapa (fallback do 99) quando não houver link salvo.
- Como usuário, eu quero poder colar/editar links externos de um restaurante de forma simples e rápida.
- Como usuário, eu quero a mesma consistência visual em “Minha base” e “Perto de mim”.

## Funcionalidades Principais

### 1) Cards (Deliverio style) para listagens

O que faz:
- Substitui a row atual por **cards** com hierarquia visual clara e ações rápidas.

Por que é importante:
- Melhora leitura, escaneabilidade e reduz cliques desnecessários.

Requisitos funcionais:
1. F1.1: Exibir cards em “Minha base” (lista de restaurantes).
2. F1.2: Exibir cards em “Perto de mim” (resultados localBase e Apple Maps).
3. F1.3: Cards devem respeitar acessibilidade (touch targets ≥ 44pt, labels, contraste).

### 2) Links externos por restaurante (salvos)

O que faz:
- Permite salvar e abrir links do TripAdvisor e iFood.
- Permite salvar um link do 99 opcional; se não existir, abre rota no Maps como fallback.

Requisitos funcionais:
1. F2.1: Adicionar campos por restaurante: `tripAdvisorURL`, `iFoodURL`, `ride99URL` (opcional).
2. F2.2: Ações rápidas no card aparecem somente quando o link existe; se não existir, não mostrar ou mostrar “Adicionar links”.
3. F2.3: Para 99 sem link salvo, mostrar ação “Rota no mapa” (Apple Maps; opcional fallback Google).

### 3) Imagem via OpenGraph (sem API paga)

O que faz:
- Carrega a imagem do restaurante via `og:image` do site quando disponível.
- Permite definir `imageURL` manual (alta prioridade).

Requisitos funcionais:
1. F3.1: Prioridade de imagem: `imageURL` manual → OpenGraph do site → placeholder.
2. F3.2: Não travar UI; carregar imagem de forma assíncrona e cachear.
3. F3.3: Respeitar limite de rede: timeouts, cache, não repetir fetch desnecessário.

### 4) UX de curadoria (editar/colar links)

O que faz:
- Uma tela/sheet por restaurante para colar e validar URLs.

Requisitos funcionais:
1. F4.1: Usuário consegue colar URLs (TripAdvisor/iFood/99 e imagem) e salvar.
2. F4.2: Validação básica (URL válida/https) e feedback de erro.
3. F4.3: Acesso fácil a partir do detalhe e/ou card (“Adicionar links”).

## Experiência do Usuário

- Visual inspirado no Deliverio (cards, hierarquia, bordas suaves, sombras sutis), mas usando o design system do app (`AppColors`, SF Symbols, espaçamentos consistentes).
- Ações rápidas devem ser **claras** e **consistentes** entre “Minha base” e “Perto de mim”.
- Em “Perto de mim”, resultados do Apple Maps podem não ter links salvos; nesse caso, o card deve:
  - abrir o detalhe
  - permitir rota no mapa
  - oferecer CTA “Adicionar links” quando aplicável

Acessibilidade:
- Touch targets mínimos 44×44pt para botões de ação.
- `accessibilityLabel` e `accessibilityHint` nos botões (TripAdvisor/iFood/Maps).
- Suporte a Dynamic Type (fontes de sistema).

## Restrições Técnicas de Alto Nível

- Sem APIs pagas para imagens/dados de restaurantes.
- Sem “imagem do Google” (fora de escopo).
- OpenGraph deve ser best-effort (sites podem bloquear ou não ter `og:image`).
- Links externos são salvos manualmente; não há garantia de consistência externa.

## Não-Objetivos (Fora de Escopo)

- Matching automático de TripAdvisor/iFood/99 via APIs pagas.
- Scraping de resultados do Google para imagens/links.
- Backend intermediário para resolver links.
- Importar assets do pacote UI8 (somente estilo/layout/cores, assets próprios).

## Questões em Aberto

- Quais ícones/labels finais para botões TripAdvisor/iFood/99 (usaremos SF Symbols e texto).
- Comportamento exato do fallback do 99: abrir Apple Maps sempre, ou oferecer sheet Apple/Google (decisão de UX).



