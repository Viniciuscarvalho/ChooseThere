# [2.0] Implementar serviço/orquestração do sorteio “Perto de mim” (Apple Maps → candidatos → sorteio) (M)

## Objetivo
- Criar um pipeline único para: buscar Apple Maps (até 10km), transformar em candidatos compatíveis com a regra de sorteio e usar `SmartRouletteService`/`RestaurantRandomizer` para sortear um resultado.

## Subtarefas
- [ ] 2.1 Criar/definir `NearbyRouletteServicing` (ou equivalente) e integrar com `NearbySearching` + `LocationManaging`
- [ ] 2.2 Implementar mapeamento Apple Maps (`NearbyPlace`) → candidatos sorteáveis (incluindo tags derivadas)
- [ ] 2.3 Implementar estratégia de matching com base local (quando possível) para obter `id`/tags/ratings internos
- [ ] 2.4 Implementar fallback de rating `.only` → `.prefer` no fluxo nearby

## Critérios de Sucesso
- Dado um contexto e localização, o serviço retorna um restaurante sorteado ou um erro/estado “sem resultados” previsível.
- A lógica de sorteio utilizada é a mesma (via `SmartRouletteService`/`RestaurantRandomizer`) e não há duplicação de regras.

## Dependências
- Tarefa 1.0

## Observações
- Evitar acoplamento do MapKit na camada de UI; manter a orquestração em um serviço de domínio/aplicação.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/domain</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>external_apis|database</dependencies>
</task_context>

# Tarefa 2.0: Implementar serviço/orquestração do sorteio “Perto de mim”

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar um serviço que encapsula a busca por restaurantes próximos via Apple Maps, aplica filtros equivalentes ao sorteio atual e retorna um resultado sorteado pronto para navegação.

<requirements>
- Buscar resultados via `NearbySearching` respeitando raio (máx 10km).
- Aplicar filtros de tags (desired/avoid), raio e prioridade de rating conforme regra atual.
- Integrar anti-repetição e preferências aprendidas via `SmartRouletteService`.
- Implementar fallback quando não houver rating interno disponível e o modo `.only` eliminar todos.
</requirements>

## Subtarefas

- [ ] 2.1 Definir interface e pontos de integração (MapKit, localização, cache)
- [ ] 2.2 Implementar conversão `NearbyPlace` → candidato sorteável
- [ ] 2.3 Implementar matching com base local (quando possível) para enriquecer tags/ratings
- [ ] 2.4 Implementar fallbacks (rating `.only`, sem resultados, erros)

## Detalhes de Implementação

Referenciar as seções “Interfaces Principais”, “Modelos de Dados” e “Pontos de Integração” em `tasks/prd-nearby-roulette-eden-ux/techspec.md`.

## Critérios de Sucesso

- Retorna resultado válido em cenários de sucesso e estados previsíveis em falhas.
- Mantém regra única de sorteio (sem duplicar filtros fora de `RestaurantRandomizer`/`SmartRouletteService`).

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/AppleMapsNearbySearchService.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/SmartRouletteService.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`


