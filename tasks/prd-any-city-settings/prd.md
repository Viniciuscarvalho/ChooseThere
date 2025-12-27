# PRD: Seleção de Cidade + “Perto de mim” (Any City Mode) + Configurações

## Visão Geral

O ChooseThere hoje é alimentado por um JSON local (`Resources/Restaurants.json`) e uma lista do usuário no SwiftData. Para evoluir o app para múltiplas cidades e torná-lo útil em viagens/rolês espontâneos, precisamos introduzir:

- Uma **seleção de cidade** no primeiro uso (e alterável depois), para guiar a experiência e os filtros.
- Um modo **“Perto de mim”** (“Any City Mode”) que busca restaurantes próximos automaticamente e alimenta a roleta, com cache local.
- Uma área de **Configurações** para modificar cidade e preferências do modo “Perto de mim”.

O objetivo desta entrega (Fase 1) é habilitar cidade + “Perto de mim” com duas fontes:
1) “Minha base” (dados locais) e 2) Apple Maps (MKLocalSearch), com um toggle claro.

## Objetivos

- Permitir que o usuário selecione uma **cidade** no primeiro uso e persista essa escolha.
- Permitir que o usuário **altere** a cidade e preferências em uma área de **Configurações**.
- Implementar o modo **Perto de mim** com filtros e cache, alimentando a roleta sem fricção.
- Reduzir chamadas repetidas ao Apple Maps via **cache** local (com TTL e invalidação simples).

Métricas sugeridas:
- % de usuários que completam seleção de cidade no primeiro uso.
- % de usuários que usam “Perto de mim” pelo menos 1x (por sessão/semana).
- Latência média para aparecer uma lista “Perto de mim” (cold vs warm cache).
- Taxa de falha/empty state em “Perto de mim” (sem permissão, sem resultados, etc.).

## Histórias de Usuário

- Como usuário, eu quero **escolher a cidade** ao abrir o app pela primeira vez para ver recomendações relevantes.
- Como usuário, eu quero **trocar a cidade** em Configurações quando eu viajar.
- Como usuário, eu quero um modo “**Perto de mim**” para encontrar lugares próximos rapidamente sem precisar manter uma lista prévia.
- Como usuário, eu quero filtrar por **raio (1–10km)** e **tipo** para chegar em opções que combinam comigo.
- Como usuário, eu quero alternar a fonte entre **Minha base** e **Apple Maps** para escolher entre “meus lugares” e “descobrir novos”.
- Como usuário, eu quero que o app **não fique lento** nem faça consultas toda hora (cache local).

## Funcionalidades Principais

### 1) Seleção de cidade no primeiro uso

O que faz:
- No primeiro uso, o app solicita a seleção de uma cidade.
- A lista de cidades é **derivada do `Restaurants.json`** (valores únicos de `city/state`) e inclui também a opção **Any City / Perto de mim**.

Requisitos funcionais:
1. F1.1: Exibir uma tela de seleção de cidade no onboarding do primeiro uso.
2. F1.2: Persistir a seleção (cidade/estado ou “Any City”).
3. F1.3: Ao concluir, navegar para o fluxo principal (tabs).

### 2) Modo “Minha Lista | Perto de mim”

O que faz:
- Dentro do fluxo principal, o usuário escolhe entre:
  - **Minha Lista** (fluxo atual baseado em dados locais/SwiftData)
  - **Perto de mim** (novo modo com busca e filtros)

Requisitos funcionais:
1. F2.1: Exibir “Minha Lista | Perto de mim” como um segmento/aba dentro da área de sorteio/lista.
2. F2.2: Persistir a última seleção do modo para reabrir no mesmo estado.

### 3) Perto de mim — fonte “Minha base”

O que faz:
- Usa a localização atual do usuário e filtra os restaurantes locais (seed JSON/SwiftData) por distância dentro do raio.
- Alimenta a roleta com os resultados filtrados.

Requisitos funcionais:
1. F3.1: Solicitar permissão de localização (quando necessário) e lidar com negativa.
2. F3.2: Filtrar por raio (1–10km) e tipo/categoria.
3. F3.3: Exibir estado vazio quando não houver resultados.

### 4) Perto de mim — fonte “Apple Maps”

O que faz:
- Usa Apple Maps (`MKLocalSearch`) para buscar lugares próximos considerando:
  - localização atual
  - raio
  - tipo/categoria (mapeado para termos de busca)
  - cidade selecionada (quando aplicável)
- Cacheia resultados localmente para evitar chamadas repetidas.
- Alimenta a roleta com resultados retornados.

Requisitos funcionais:
1. F4.1: Implementar busca via Apple Maps com parâmetros de localização e query textual.
2. F4.2: Cache local com TTL (ex.: 15–60min) por combinação (fonte, cidade, raio, tipo e localização aproximada).
3. F4.3: Permitir alternar a fonte “Minha base” vs “Apple Maps” via toggle na UI.

### 5) Configurações (cidade e preferências)

O que faz:
- Um local central para trocar:
  - cidade selecionada (incluindo “Any City”)
  - preferências do modo “Perto de mim” (raio default, fonte default, último tipo usado)
  - opções de cache (ex.: “Atualizar agora” / “Limpar cache”)

Requisitos funcionais:
1. F5.1: Tela de Configurações acessível no app (dentro das tabs existentes ou como item dedicado).
2. F5.2: Alterar cidade atual e refletir imediatamente nos fluxos dependentes.
3. F5.3: Permitir limpar cache de “Perto de mim”.

## Experiência do Usuário

- A seleção de cidade deve ser **rápida** e com texto claro (ex.: “Onde você quer buscar?”).
- Se o usuário escolher **Any City / Perto de mim**, o app deve incentivar conceder permissão de localização para melhor experiência.
- Em “Perto de mim”:
  - Mostrar controles simples (raio, tipo, fonte).
  - Ter estados explícitos: carregando, sem permissão, sem resultados, erro.
- Configurações devem seguir padrões HIG: lista agrupada, itens com valores atuais e navegação clara.

## Restrições Técnicas de Alto Nível

- O app deve continuar funcionando **offline** para “Minha base”.
- “Apple Maps” depende de rede e do framework MapKit; deve falhar de forma segura.
- Cache local deve evitar consultas repetidas; TTL e chave de cache devem considerar posição aproximada.
- Evitar dependências externas e login (fora do escopo da Fase 1).

## Não-Objetivos (Fora de Escopo)

- Sincronização entre dispositivos (export/import ou iCloud) — fase futura.
- Algoritmo completo de “preferências que aprendem” — fase futura.
- Suporte a Google Places/TripAdvisor — fora do escopo.

## Questões em Aberto

- Mapeamento final de “tipo/categoria” (bar, japonês, italiano etc.) para query do Apple Maps (termos e sinônimos).
- TTL final do cache (15min vs 30min vs 60min) e estratégia de localização aproximada (ex.: geohash simples vs arredondamento de lat/lng).


