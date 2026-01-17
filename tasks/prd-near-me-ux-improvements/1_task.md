# [1.0] Create NearbyDisplayable Protocol and DataSource Enum (S)

## Objetivo
- Criar o protocolo `NearbyDisplayable` que unifica a interface de apresentação para `Restaurant` e `NearbyPlace`
- Criar o enum `DataSource` que representa as fontes de dados (Minha Base e Apple Maps)
- Estabelecer a base para o design unificado de cards

## Subtarefas
- [ ] 1.1 Criar arquivo `NearbyDisplayable.swift` em `ChooseThere/Domain/Protocols/`
- [ ] 1.2 Definir protocol `NearbyDisplayable` com propriedades necessárias
- [ ] 1.3 Criar enum `DataSource` com casos `.localBase` e `.appleMaps`
- [ ] 1.4 Adicionar computed properties ao `DataSource` (displayName, badgeColor, badgeIcon, tooltipText)
- [ ] 1.5 Definir enum `QuickAction` para ações rápidas dos cards

## Critérios de Sucesso
- Protocol `NearbyDisplayable` compila sem erros
- Enum `DataSource` possui todas as propriedades especificadas na techspec
- Código segue Kodeco Swift Style Guide (naming, spacing, access control)
- Arquivo possui comentários de documentação adequados

## Dependências
- Nenhuma - Esta é uma tarefa foundation

## Observações
- Esta tarefa é crítica pois outras tarefas (3, 4, 5, 6, 7) dependem desta interface
- O protocolo usa existential types (`any NearbyDisplayable`) que são bem suportados em Swift 5.7+
- Colors devem referenciar `AppColors.primary` e `AppColors.accent` existentes
- Ícones devem usar SF Symbols nativos

## status: pending

<task_context>
<domain>domain/protocols</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>none</dependencies>
</task_context>

# Tarefa 1.0: Create NearbyDisplayable Protocol and DataSource Enum

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa estabelece a fundação do sistema de cards unificados através da criação de um protocolo que abstrai as diferenças entre `Restaurant` (base local) e `NearbyPlace` (Apple Maps). O protocolo define uma interface comum para apresentação visual, permitindo que um único componente de UI (`UnifiedRestaurantCard`) renderize ambos os tipos.

<requirements>
- Protocol deve incluir todas as propriedades necessárias para renderização de cards
- DataSource enum deve fornecer metadados de badge (cor, ícone, tooltip)
- Código deve seguir convenções Swift modernas (Swift 5.7+)
- Documentação inline deve explicar propósito de cada propriedade
</requirements>

## Subtarefas

- [ ] 1.1 Criar arquivo `NearbyDisplayable.swift` em `ChooseThere/Domain/Protocols/`
- [ ] 1.2 Definir protocol `NearbyDisplayable` com todas as propriedades da techspec
- [ ] 1.3 Criar enum `DataSource` com casos e computed properties
- [ ] 1.4 Criar enum `QuickAction` para representar ações externas
- [ ] 1.5 Adicionar documentação inline e accessibility labels

## Detalhes de Implementação

Consulte `techspec.md` seção "Protocol NearbyDisplayable" (linhas 83-133) para especificação completa.

**Propriedades principais do protocol:**
- `displayId`, `displayName`, `displayCategory` - identificação e categorização
- `displayImageURL`, `displayRating`, `displayAddress` - dados visuais
- `distanceKm` - para agrupamento por distância
- `dataSource` - indica origem dos dados
- `externalActions` - array de ações disponíveis (TripAdvisor, iFood, etc)

**DataSource enum deve incluir:**
- Computed properties: `displayName`, `badgeColor`, `badgeIcon`, `tooltipText`
- Cores: `.localBase` usa `AppColors.primary.opacity(0.9)`, `.appleMaps` usa `AppColors.accent.opacity(0.9)`
- Ícones SF Symbols: "externaldrive.fill" para localBase, "map.fill" para appleMaps

## Critérios de Sucesso

- Protocol compila sem erros ou warnings
- DataSource enum possui todos os computed properties especificados
- Código formatado seguindo Kodeco Swift Style Guide (2-space indentation, clear naming)
- QuickAction enum lista todas as ações: `.tripAdvisor`, `.ifood`, `.ride99`, `.maps`
- Documentação inline explica propósito de cada componente

## Arquivos relevantes
- Criar: `ChooseThere/Domain/Protocols/NearbyDisplayable.swift`
- Referência: `techspec.md` (linhas 83-133)
- Referência: `AppColors.swift` (para cores existentes)
