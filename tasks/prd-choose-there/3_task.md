# [3.0] Seed/import do JSON para SwiftData (M)

## Objetivo
- Importar `Restaurants.json` para SwiftData na primeira execução (sem duplicar), garantindo que o app leia sempre do banco após a inicialização.

## Subtarefas
- [ ] 3.1 Definir DTO para decodificar o JSON (Data layer)
- [ ] 3.2 Implementar `RestaurantSeeder` (idempotente)
- [ ] 3.3 Integrar seed no startup (Composition Root) antes de renderizar fluxo
- [ ] 3.4 Validar dados críticos (id, nome, lat, lng) e lidar com erros

## Critérios de Sucesso
- Seed executa uma única vez e não duplica registros
- SwiftData passa a ser a fonte de leitura do app

## Dependências
- 2.0 Modelos e persistência SwiftData

## Observações
- Caso haja itens inválidos, registrar log e ignorar com segurança (sem crash).

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/import</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 3.0: Seed/import do JSON para SwiftData

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Garantir a experiência offline-first importando a lista curada de restaurantes do JSON para SwiftData na primeira execução.

<requirements>
- Import idempotente
- Sem duplicidade de fonte (JSON apenas seed)
- Validar `lat`/`lng`
</requirements>

## Subtarefas

- [ ] 3.1 Implementar parsing do JSON (DTOs)
- [ ] 3.2 Implementar seeder idempotente
- [ ] 3.3 Conectar seed ao startup (Composition Root)

## Detalhes de Implementação
- Referência: `techspec.md` (Data: seed/import, fonte única)

## Critérios de Sucesso

- Primeiro launch cria `RestaurantModel`s no SwiftData
- Lançamentos subsequentes não reimportam (ou não duplicam)

## Arquivos relevantes
- `Restaurants.json`
- `tasks/prd-choose-there/techspec.md`

