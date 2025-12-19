# [1.0] Modelos e persistência para localização/rating (M)

## Objetivo
- Evoluir os modelos (`RestaurantModel`/`Restaurant`) e a camada de persistência para suportar enriquecimento de localização (Apple Maps) e rating interno (snapshot), sem quebrar o seed atual do JSON.

## Subtarefas
- [ ] 1.1 Definir campos novos de localização (status, timestamps, dados normalizados) no `RestaurantModel` e mapear para `Restaurant`
- [ ] 1.2 Definir campos novos de rating (média, contagem, última visita) no `RestaurantModel` e mapear para `Restaurant`
- [ ] 1.3 Atualizar repositórios SwiftData (fetch/update) para ler e persistir os campos novos
- [ ] 1.4 Ajustar seed/migração para manter compatibilidade com dados existentes

## Critérios de Sucesso
- Modelos compilam e persistem novos campos sem perda de dados existentes.
- `Restaurant(from: RestaurantModel)` e escrita/atualização refletem corretamente os campos novos.
- Seed do JSON continua funcionando e criando restaurantes válidos.

## Dependências
- Nenhuma.

## Observações
- Evitar renomes destrutivos; preferir adição de campos com defaults.
- `googleMapsLinkable` pode ser derivado na UI; só persistir se houver necessidade.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/persistence</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Modelos e persistência para localização/rating

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar campos no modelo de dados para:
- localização resolvida via Apple Maps (status + cache)
- rating interno (snapshot agregado das visitas)

<requirements>
- Adicionar campos novos em `RestaurantModel` e refletir em `Restaurant`
- Manter compatibilidade com o seed atual do JSON
- Garantir leitura/escrita via repositórios SwiftData
</requirements>

## Subtarefas

- [ ] 1.1 Atualizar `RestaurantModel` com campos de localização e rating (com defaults)
- [ ] 1.2 Atualizar `Restaurant` e mapping (`init(from:)`)
- [ ] 1.3 Ajustar `SwiftDataRestaurantRepository` para updates parciais (quando aplicável)
- [ ] 1.4 Validar seed em `RestaurantSeeder` e cenários de base vazia

## Detalhes de Implementação

Referenciar:
- `tasks/prd-location-rating-navigation/techspec.md` seção **Modelos de Dados**

## Critérios de Sucesso

- Build sem erros e seed/migração funcionando
- Campos novos persistidos e recuperados corretamente
- Nenhuma regressão nos fluxos existentes (lista/sorteio/detalhe)

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/Restaurant.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Services/RestaurantSeeder.swift`

