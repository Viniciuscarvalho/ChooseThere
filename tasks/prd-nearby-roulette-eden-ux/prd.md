# PRD — Nearby Roulette + Eden UX (ChooseThere)

## Visão Geral

Hoje o sorteio do ChooseThere é feito essencialmente a partir da base local (seed do JSON persistido em SwiftData). A nova funcionalidade muda o comportamento padrão para permitir que o sorteio seja feito **a partir de restaurantes próximos (até 10km)**, usando **Apple Maps (MapKit/MKLocalSearch)**, respeitando **tags e filtros** e mantendo a **mesma lógica de negócio do sorteio atual** (anti-repetição, prioridade de rating, preferências aprendidas).

Além disso, a tela “Escolher” (filtros + modo) está confusa e com informações duplicadas. Vamos refatorá-la para uma hierarquia clara, inspirada no UI kit “Eden”.

## Objetivos

- Tornar o sorteio mais contextual: **“Sortear perto de mim”** usando restaurantes próximos em um raio de até **10km**.
- Reaproveitar a lógica existente de negócio do sorteio (filtros, preferências aprendidas e anti-repetição) sem regressões.
- Reduzir confusão na tela “Escolher”: remover duplicidades, simplificar leitura e melhorar o entendimento do usuário.
- Definir comportamento claro de fallback:
  - **Fora de São Paulo**: **não usar JSON** (desabilitar/ocultar “Minha base”).
  - **São Paulo**: manter JSON como **fallback**.

Métricas sugeridas:
- Aumento da taxa de “Sortear” no modo “Perto de mim”.
- Redução de abandono na tela “Escolher”.
- Tempo médio para obter um resultado (latência percebida).

## Histórias de Usuário

- Como usuário, eu quero **sortear um lugar perto de mim** dentro de um raio configurável (até 10km) para decidir rápido onde ir/comer.
- Como usuário, eu quero **selecionar tags** (ex.: “japonês”, “pizza”) e que o sorteio respeite isso para ficar alinhado ao meu desejo do dia.
- Como usuário, eu quero evitar repetir lugares recentes para ter variedade.
- Como usuário, quando eu estiver fora de São Paulo, eu quero que o app use a fonte correta (Apple Maps) sem me confundir com opções que não fazem sentido.
- Como usuário, eu quero uma tela de filtros clara, sem informações duplicadas, para entender exatamente o que está ativo no sorteio.

## Funcionalidades Principais

1) **Sorteio por proximidade (Apple Maps, até 10km)**
- O que faz: busca restaurantes próximos e sorteia um resultado.
- Por que importa: decisão contextual e mais útil (melhor conversão de escolha).
- Como funciona (alto nível):
  - Solicita/valida permissão de localização.
  - Busca resultados via Apple Maps (MKLocalSearch) no raio configurado (máx 10km).
  - Aplica filtros por tags (desejadas/evitar) e outros filtros já existentes.
  - Aplica anti-repetição e preferências aprendidas.
  - Sorteia e navega para a tela de resultado.

Requisitos funcionais:
- RF1: O modo “Perto de mim” deve oferecer um CTA “**Sortear perto de mim**”.
- RF2: O raio máximo deve ser **10km**.
- RF3: O sorteio deve respeitar **desiredTags**, **avoidTags**, **radius**, e **rating priority** conforme a regra atual.
- RF4: Deve haver estados de UI claros: carregando, sem permissão, sem resultados, erro e sucesso.

2) **Fallback e regras por cidade**
- O que faz: define quando a base local (seed/JSON) é habilitada.
- Requisitos funcionais:
  - RF5: Se a cidade selecionada (settings) **não** for São Paulo (SP), a opção “Minha base/JSON” deve ficar **oculta ou desabilitada** no modo “Perto de mim”, e a fonte deve ser forçada para Apple Maps.
  - RF6: Em São Paulo (SP), o JSON pode ser usado como **fallback** (ex.: quando Apple Maps não retornar resultados ou em erro).

3) **Refator da tela “Escolher” (inspirada no Eden UI kit)**
- O que faz: reorganiza layout, reduz duplicidade e torna o fluxo óbvio.
- Requisitos funcionais:
  - RF7: Não exibir informações redundantes (ex.: mesma “cidade” em múltiplos cards sem necessidade).
  - RF8: Deixar explícito o que está selecionado: modo (Minha Lista/Perto de mim), raio, tags, fonte.
  - RF9: CTA principal deve ser coerente com o modo:
    - Minha Lista: “Sortear”
    - Perto de mim: “Sortear perto de mim”

## Experiência do Usuário

Fluxo “Perto de mim”:
- Usuário abre “Escolher” → seleciona “Perto de mim”.
- Ajusta tags/raio (até 10km).
- Toca em “Sortear perto de mim”.
- App solicita permissão se necessário (com call-to-action para abrir Settings quando negado).
- Ao sucesso, navega para o resultado.

Fluxo “Minha Lista”:
- Mantém comportamento existente (com filtros e sorteio da base local).

UI/UX (Eden-inspired):
- Hierarquia clara por seções:
  - Cabeçalho (contexto “Hoje estamos a fim de…”)
  - Segmento (Minha Lista | Perto de mim)
  - Card de contexto (local/cidade + alterar)
  - Cards de filtros (tags, raio, rating, etc.)
  - CTA principal fixo no rodapé
- Touch targets mínimos (44pt) e acessibilidade:
  - Labels/hints para botões de modo, fonte e CTA.
  - Estados vazios/erro com texto simples.

## Restrições Técnicas de Alto Nível

- Sem APIs pagas (usar MapKit/MKLocalSearch).
- Respeitar limite de raio (até 10km).
- Reaproveitar a lógica existente do domínio (sorteio e filtros) para evitar divergência de regras.
- Performance: evitar recomputações e re-renderização excessiva no SwiftUI; reutilizar cache existente de busca (NearbyCacheStore).
- Privacidade: localização apenas para a busca local; não persistir coordenadas do usuário.

## Não-Objetivos (Fora de Escopo)

- Garantir correspondência perfeita entre resultados do Apple Maps e restaurantes do JSON.
- Criar backend ou persistência completa dos resultados do Apple Maps como novos `RestaurantModel`.
- Implementar ranking “por popularidade externa” (Google/Apple ratings) — não disponível sem integrações adicionais.
- Re-trabalho visual de todas as telas do app (apenas “Escolher”).

## Questões em Aberto

- Como tratar o filtro “somente bem avaliados” no Apple Maps quando não houver rating interno disponível?
  - Sugestão: manter semântica atual para itens que existam na base local; para itens apenas do Apple Maps, tratar como “sem avaliação” e aplicar fallback de relaxamento quando necessário (detalhado na techspec).
- Qual é o critério exato para “São Paulo”: cidade==“São Paulo” e estado==“SP”, ou “selectedCityKey” específico? (Definir na implementação.)


