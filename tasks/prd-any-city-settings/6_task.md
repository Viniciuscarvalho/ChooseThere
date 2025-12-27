# [6.0] “Perto de mim” (fonte: Apple Maps) — busca + cache (L)

## Objetivo
- Implementar busca por lugares próximos via Apple Maps (MapKit/MKLocalSearch) com cache local (TTL + bucket de localização) para alimentar a roleta.

## Subtarefas
- [x] 6.1 Implementar `AppleMapsNearbySearchService` (async/await, MapKit)
- [x] 6.2 Implementar `NearbyCacheStore` (get/set/clear + TTL)
- [x] 6.3 Integrar o toggle "Apple Maps" no modo "Perto de mim"
- [x] 6.4 Testes unitários para `NearbyCacheStore` (hit/miss/TTL)

## Critérios de Sucesso
- Busca retorna resultados e preenche a lista/roleta.
- Repetir a mesma busca dentro do TTL usa cache (sem chamar MapKit novamente).

## Dependências
- 1.0 Persistência de cidade e preferências globais
- 4.0 UI do modo “Minha Lista | Perto de mim”

## Observações
- MapKit pode falhar (rede/ambiguidade). A UI deve lidar com erro e sugerir “Minha base”.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/nearby</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 6.0: “Perto de mim” (fonte: Apple Maps) — busca + cache

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar a capacidade de descobrir restaurantes/lugares próximos via Apple Maps. Para manter performance e reduzir custo, a busca será cacheada localmente com TTL e chave baseada em localização aproximada.

<requirements>
- Implementar busca via MapKit (`MKLocalSearch`) usando `async/await`
- Introduzir cache local com TTL e invalidação manual
- Respeitar filtros: raio e categoria/tipo
- Falhas (sem rede/erro MapKit) devem resultar em estado de erro controlado
</requirements>

## Subtarefas

- [x] 6.1 Implementar `AppleMapsNearbySearchService` (protocol `NearbySearching`)
- [x] 6.2 Implementar `NearbyCacheStore` e `NearbyCacheKey` (bucket + TTL)
- [x] 6.3 Integrar cache na busca (cache-first, refresh quando expirado)
- [x] 6.4 Testes unitários do cache e mocks do search

## Detalhes de Implementação

- Tech Spec: **Pontos de Integração** (MapKit) e **Modelos de Dados** (cache)
- Considerar buckets por arredondamento de lat/lng (ex.: 0.01) e TTL inicial (ex.: 30min)

## Critérios de Sucesso

- Busca retorna resultados e alimenta o modo “Perto de mim”
- Cache evita chamadas repetidas em curto intervalo
- Limpar cache em Configurações força nova busca

## Arquivos relevantes
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/AppleMapsNearbySearchService.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Services/NearbyCacheStore.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`

