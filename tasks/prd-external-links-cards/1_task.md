# [1.0] Modelos e persistência de links/imagem (M)

## Objetivo
- Evoluir o modelo de dados para suportar URLs específicas (TripAdvisor/iFood/99) e imagem (`imageURL`), mantendo compatibilidade com o app atual e com o SwiftData.

## Subtarefas
- [ ] 1.1 Adicionar novos campos em `RestaurantModel` (SwiftData) e inicializador
- [ ] 1.2 Adicionar novos campos em `Restaurant` (Domain) e mapping `init(from:)`
- [ ] 1.3 Atualizar `RestaurantRepository` e `SwiftDataRestaurantRepository` para ler/gravar os novos campos

## Critérios de Sucesso
- Modelos compilam e persistem corretamente (sem crash/migração quebrada).
- `Restaurant` expõe `URL?` para TripAdvisor/iFood/99/imagem.
- Repositório consegue salvar e recuperar os campos em round-trip.

## Dependências
- `prd.md` e `techspec.md` desta pasta

## Observações
- Sem API paga: os links serão preenchidos por curadoria manual (tela de editor na task 2.0).
- Reaproveitar `externalLink` atual como “site do restaurante” (base para OpenGraph), se fizer sentido.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/data</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Modelos e persistência de links/imagem

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar suporte a URLs específicas por restaurante (TripAdvisor/iFood/99) e a uma URL de imagem manual. Isso habilita ações rápidas nos cards e melhora visual sem depender de APIs pagas.

<requirements>
- Adicionar campos em `RestaurantModel`: `tripAdvisorURL`, `iFoodURL`, `ride99URL`, `imageURL` (todos opcionais).
- Espelhar campos em `Restaurant` como `URL?`.
- Atualizar `RestaurantRepository` para incluir métodos de update desses campos (ou atualizar via update geral, conforme padrão do repo).
</requirements>

## Subtarefas

- [x] 1.1 Atualizar `RestaurantModel` e initializer para incluir novos campos
- [x] 1.2 Atualizar `Restaurant` e mapping a partir de `RestaurantModel`
- [x] 1.3 Atualizar `RestaurantRepository` e `SwiftDataRestaurantRepository` com operações de leitura/gravação

## Detalhes de Implementação

Referenciar `techspec.md` (seção “Modelos de Dados”) para o desenho dos campos e regras de prioridade.

## Critérios de Sucesso

- Compila sem erros e sem warnings críticos.
- Dados persistem e são recuperados corretamente.
- Campos continuam opcionais (não quebrar seed existente).

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/Restaurant.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Repositories/RestaurantRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`

