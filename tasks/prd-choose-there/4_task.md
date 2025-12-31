# [4.0] Repositórios + regras de sorteio (M)

## Objetivo
- Implementar contratos de repositório no Domain e implementações concretas no Data, além das regras de filtragem e sorteio com suporte a re-roll.

## Subtarefas
- [ ] 4.1 Criar protocolos `RestaurantRepository` e `VisitRepository` (Domain)
- [ ] 4.2 Implementar repositórios SwiftData (Data)
- [ ] 4.3 Implementar `RestaurantRandomizer` com filtros (tags, evitar, preço, raio)
- [ ] 4.4 Definir política de re-roll (excluir IDs já sorteados na sessão)

## Critérios de Sucesso
- Seleção retorna restaurante compatível ou nil com estado “sem resultados”
- Favorito e visitas persistem via repositórios

## Dependências
- 3.0 Seed/import do JSON

## Observações
- Regras devem ser testáveis (injeção de RNG / determinismo em testes).

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/core/sort</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 4.0: Repositórios + regras de sorteio

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Criar a camada de acesso a dados e a regra central do app: filtrar e sortear restaurantes com base no contexto atual.

<requirements>
- Protocolos no Domain; implementações no Data
- Filtros: tags desejadas, evitar, faixa de preço, raio (quando houver localização)
- Re-roll com exclusão de resultados anteriores
</requirements>

## Subtarefas

- [ ] 4.1 Protocolos de repositório no Domain
- [ ] 4.2 Implementações SwiftData no Data
- [ ] 4.3 Randomizer e filtros no Domain
- [ ] 4.4 Re-roll policy e contagem

## Detalhes de Implementação
- Referência: `techspec.md` (Interfaces Principais, Modelos de Dados, Testes)

## Critérios de Sucesso

- Sorteio respeita filtros e evita tags indesejadas
- Favoritar e salvar visitas funcionam via repositórios

## Arquivos relevantes
- `tasks/prd-choose-there/techspec.md`






