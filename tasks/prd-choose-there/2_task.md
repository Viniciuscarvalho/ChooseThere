# [2.0] Modelos e persistência SwiftData (M)

## Objetivo
- Definir modelos persistidos `RestaurantModel` e `VisitModel` (SwiftData) alinhados ao domínio e remover o scaffold `Item`.

## Subtarefas
- [ ] 2.1 Definir modelos SwiftData para Restaurant e Visit (camada Data)
- [ ] 2.2 Definir modelos de domínio (camada Domain) sem duplicidade de fonte
- [ ] 2.3 Atualizar `ModelContainer` no App para o novo schema
- [ ] 2.4 Remover/aposentar `Item` e referências no app

## Critérios de Sucesso
- SwiftData schema criado com `RestaurantModel` e `VisitModel`
- App inicializa com o novo schema sem warnings de modelo anterior

## Dependências
- 1.0 Fundação do projeto

## Observações
- `RestaurantModel` deve conter `lat`/`lng` e `isFavorite`.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/persistence</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 2.0: Modelos e persistência SwiftData

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Criar os modelos persistidos do app e atualizar o `ModelContainer` para suportar restaurantes, favoritos e visitas/avaliações.

<requirements>
- SwiftData como fonte única de verdade após seed
- Modelos incluem `lat`, `lng`, `isFavorite`
- Não manter `Item` como modelo final do app
</requirements>

## Subtarefas

- [ ] 2.1 Implementar `RestaurantModel` e `VisitModel`
- [ ] 2.2 Atualizar `ChooseThereApp` para o novo schema
- [ ] 2.3 Ajustar RootView/Router para usar o novo container

## Detalhes de Implementação
- Referência: `techspec.md` (Modelos de Dados, SwiftData como fonte única)

## Critérios de Sucesso

- `RestaurantModel`/`VisitModel` persistem e podem ser consultados em runtime
- `Item.swift` não é mais parte do schema do app

## Arquivos relevantes
- `tasks/prd-choose-there/prd.md`
- `tasks/prd-choose-there/techspec.md`
- `ChooseThere/ChooseThere/ChooseThereApp.swift`







