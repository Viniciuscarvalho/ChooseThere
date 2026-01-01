# PRD: Enriquecimento de Localização + Rating Interno + Navegação

## Visão Geral

O app hoje lê restaurantes de um JSON (seed no SwiftData) e mostra detalhes em um mapa. Há três problemas principais: (1) coordenadas podem estar erradas ou imprecisas; (2) não existe um conceito de “bem avaliados” para priorizar a experiência; (3) o fluxo de navegação do sorteio/detalhe pode ser confuso, especialmente após abrir o Maps externo e voltar para o app.

Esta funcionalidade adiciona uma camada de enriquecimento de localização usando Apple Maps (MapKit/MKLocalSearch), cria um rating interno baseado nas avaliações feitas dentro do app (VisitModel), e melhora a navegação para que a TabBar esteja disponível em todo o fluxo e o usuário não fique preso em telas sem caminhos claros.

## Objetivos

- Garantir que restaurantes tenham `lat/lng` coerentes e utilizáveis no mapa (Apple Maps como fonte).
- Exibir e utilizar “bem avaliados” baseado em avaliações internas (histórico do usuário).
- Melhorar a navegação do fluxo “sorteio -> detalhe -> avaliar -> voltar/alternar abas” reduzindo fricção e caminhos sem retorno.

Métricas sugeridas:
- % de restaurantes com localização resolvida via Apple Maps.
- % de aberturas do detalhe com “Abrir no Maps” funcionando com coordenadas válidas.
- Aumento do uso de filtro/priorização de “bem avaliados” (cliques e sorteios).
- Redução de abandonos no fluxo de sorteio/detalhe (ex.: usuário preso/sem retorno).

## Histórias de Usuário

- Como usuário, eu quero que a localização do restaurante esteja correta para abrir o mapa e ver a rota com confiança.
- Como usuário, eu quero ver quais restaurantes são “bem avaliados” com base no meu histórico para escolher melhores opções.
- Como usuário, eu quero que o sorteio e o detalhe não me prendam num fluxo sem retorno, podendo trocar de aba a qualquer momento.
- Como usuário, eu quero que o botão voltar seja bem visível (contraste) para entender como retornar.

## Funcionalidades Principais

### 1) Enriquecimento de Localização (Apple Maps)

O que faz:
- Usa `MKLocalSearch` para resolver coordenadas a partir de `name + address + city/state`.
- Atualiza `lat/lng` do restaurante no SwiftData quando o match é considerado confiável.
- Marca status de disponibilidade no Apple Maps.

Por que é importante:
- Corrige coordenadas do JSON e garante navegação/rota confiável.

Requisitos funcionais:
1. F1.1: Resolver coordenadas para um restaurante individual sob demanda.
2. F1.2: Rodar “backfill” (batch) para todos os restaurantes em background (controlado) e cachear resultados.
3. F1.3: Persistir data da última resolução e o status “disponível no Apple Maps”.
4. F1.4: Não bloquear UI durante resolução; indicar loading quando necessário.

### 2) Disponibilidade Google Maps (sem API)

O que faz:
- Gera um link para abrir o local no Google Maps (URL), marcando como “linkável”.

Por que é importante:
- Dá opção ao usuário, mesmo sem validação via Google Places API.

Requisitos funcionais:
1. F2.1: Ao tocar em “Abrir no Maps”, abrir Apple Maps por padrão; oferecer opção Google quando aplicável.
2. F2.2: “Linkável no Google Maps” não deve ser tratado como confirmação de existência.

### 3) Rating interno (“bem avaliados”) e uso no app

O que faz:
- Calcula score de restaurante usando avaliações internas (`VisitModel`) e salva snapshot no `RestaurantModel`.
- Exibe rating na lista e no detalhe.
- Permite filtrar/priorizar sorteio/lista por “bem avaliados”.

Requisitos funcionais:
1. F3.1: Calcular rating (ex.: média 1–5) e quantidade de avaliações por restaurante.
2. F3.2: Atualizar o snapshot quando uma nova avaliação é salva.
3. F3.3: Exibir rating e contagem no detalhe e na lista.
4. F3.4: Permitir priorizar/filtrar por rating no sorteio e/ou lista (definido na UI).

### 4) Navegação e TabBar no fluxo inteiro

O que faz:
- Mantém a TabBar disponível no fluxo principal, evitando telas “isoladas” sem retorno claro.
- Ajusta o fluxo do sorteio para que “Ver no mapa” leve para um detalhe que não volte para uma animação confusa ao retornar do Maps externo.

Requisitos funcionais:
1. F4.1: TabBar visível e funcional no fluxo de detalhe do restaurante (Result) e avaliação (Rating), quando apropriado.
2. F4.2: “Voltar” sempre retorna para um estado esperado (lista/detalhe/tab), sem prender o usuário.
3. F4.3: Fluxo do sorteio deve permitir “ver detalhes”, “sortear novamente” e “ir para lista” claramente.

### 5) UI: Botão voltar com contraste

Requisitos funcionais:
1. F5.1: Ícone do voltar em branco nos contextos em que fica sobre mapa/área escura.
2. F5.2: Tamanho mínimo de toque e acessibilidade (label).

## Experiência do Usuário

- A TabBar deve estar presente no fluxo principal (sorteio/detalhe/avaliação/lista/histórico), com exceções apenas para onboarding.
- No detalhe do restaurante:
  - Mostrar rating interno (média e contagem) quando disponível.
  - CTA “Abrir no Maps” deve funcionar com coordenadas resolvidas.
- No sorteio “E o escolhido é…”:
  - CTA “Ver no mapa” deve levar para detalhe (com TabBar) e oferecer caminhos claros para “sortear de novo” e “ir para lista”.

## Restrições Técnicas de Alto Nível

- Sem API do Google (Places/Geocoding) e sem TripAdvisor para dados externos.
- Apple Maps (MapKit) é a fonte de verdade para resolução de coordenadas.
- Evitar rodar backfill pesado no launch; usar batch controlado e cache no SwiftData.
- Não adicionar dependências externas de rede/billing.

## Não-Objetivos (Fora de Escopo)

- Integração com Google Places API/TripAdvisor para rating externo.
- Um sistema de contas/sincronização em nuvem.
- Ajustes profundos de design visual além dos pontos de navegação/contraste especificados.

## Questões em Aberto

- Definição final do algoritmo de priorização por rating (corte mínimo vs. ponderação por quantidade/recência).
- UX final para escolha entre Apple Maps e Google Maps (ex.: sheet/ações).






