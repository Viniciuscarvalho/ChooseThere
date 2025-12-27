# [9.0] Testes unitários principais (M)

## Objetivo
- Consolidar e garantir cobertura unitária mínima para a nova feature (cidade + perto de mim + cache), evitando regressões durante iterações.

## Subtarefas
- [x] 9.1 Testes de `CityCatalog` (cidades únicas + Any City)
- [x] 9.2 Testes de filtro por distância (local base)
- [x] 9.3 Testes de `NearbyCacheStore` (TTL, hit/miss, clear)
- [x] 9.4 Testes do ViewModel (mocks): alternância de fonte e uso de cache

## Critérios de Sucesso
- Suite de testes passa e cobre os fluxos críticos.

## Dependências
- 1.0 Persistência de cidade e preferências globais
- 5.0 “Perto de mim” (fonte: Minha base) — filtro por distância
- 6.0 “Perto de mim” (fonte: Apple Maps) — busca + cache

## Observações
- Não chamar MapKit real nos testes; usar mocks/fakes.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 9.0: Testes unitários principais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar/organizar testes unitários focados nas regras que podem quebrar facilmente: derivação de cidades, filtro por distância e cache TTL. Isso dá segurança para evoluir a UI e as integrações com MapKit.

<requirements>
- Testar CityCatalog (cidades únicas + ordenação + Any City)
- Testar filtro por distância (casos de borda: limite do raio)
- Testar cache TTL + clear
- Testar ViewModel com mocks (sem MapKit real)
</requirements>

## Subtarefas

- [x] 9.1 Criar/atualizar arquivos de teste em `ChooseThereTests/`
- [x] 9.2 Cobrir regras de cache e filtro por distância
- [x] 9.3 Garantir testes estáveis/determinísticos (RNG injetável quando necessário)

## Detalhes de Implementação

- Tech Spec: **Abordagem de Testes**
- Reforço: mocks/fakes para `NearbySearching` e para storage/cache

## Critérios de Sucesso

- Testes passam localmente e cobrem os cenários críticos
- Sem dependência de rede/MapKit real nos unit tests

## Arquivos relevantes
- `ChooseThereTests/*`
- (novos) testes para `CityCatalog`, `NearbyLocalFilterService` e `NearbyCacheStore`

