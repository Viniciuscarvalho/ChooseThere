# Especificação Técnica: Enriquecimento de Localização + Rating Interno + Navegação

## Resumo Executivo

A solução adiciona (1) um serviço de resolução de localização usando MapKit (`MKLocalSearch`) para atualizar `lat/lng` dos restaurantes persistidos em SwiftData; (2) um agregador de rating interno baseado em `VisitModel`, persistindo snapshots (média/contagem/recência) em `RestaurantModel`; (3) ajustes de navegação para manter a TabBar consistente no fluxo e evitar retornos confusos após abrir Maps externo.

O foco é minimizar dependências externas (sem Google Places/TripAdvisor), cachear resultados no SwiftData e manter a UI responsiva com tarefas assíncronas e backfill controlado.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- `MapKitPlaceResolver` (novo, Data/Services): resolve coordenadas e metadados via `MKLocalSearch`.
- `RestaurantLocationEnrichmentService` (novo, Domain/Services): orquestra enriquecimento (single/batch), aplica heurísticas e grava no repositório.
- `RestaurantRatingAggregator` (novo, Domain/Services): calcula rating interno usando `VisitRepository`.
- `SwiftDataRestaurantRepository` / `SwiftDataVisitRepository`: persistência e consultas.
- `AppRouter` / `MainTabView` / `CustomTabBar`: fluxo e seleção de tabs.
- Views impactadas: `ResultView`, `RouletteView`, `RatingView`, `RestaurantListView`.

Fluxo de dados (alto nível):
1. Seed inicial do JSON -> `RestaurantModel` com lat/lng possivelmente aproximados.
2. Ao abrir detalhe/lista, dispara enriquecimento (on-demand) e/ou batch.
3. Ao salvar avaliação (`RatingViewModel.save()`), grava `VisitModel` e atualiza snapshot de rating do restaurante.
4. Sorteio/lista consultam rating snapshot para priorização/filtro.

## Design de Implementação

### Interfaces Principais

```go
// Serviço de resolução via MapKit (assíncrono)
type PlaceResolver interface {
    Resolve(query string) (lat float64, lng float64, normalizedName string, normalizedAddress string, ok bool, err error)
}

// Agregador de rating interno a partir de visitas
type RatingAggregator interface {
    Compute(restaurantId string) (avg float64, count int, lastVisited int64, err error)
}
```

> Observação: o código real será Swift (protocols/async-await). O exemplo acima segue o template.

### Modelos de Dados

Atualizações propostas em `RestaurantModel`/`Restaurant`:
- `applePlaceResolved: Bool`
- `applePlaceResolvedAt: Date?`
- `applePlaceName: String?` (normalizado)
- `applePlaceAddress: String?` (normalizado)
- `googleMapsLinkable: Bool` (derivado/armazenado opcionalmente)
- `ratingAverage: Double` (0–5)
- `ratingCount: Int`
- `ratingLastVisitedAt: Date?`

Regras:
- `ratingAverage` e `ratingCount` refletem apenas `VisitModel` do usuário local.
- `googleMapsLinkable` não significa “existe no Google”, apenas que um link pode ser montado (via coordenadas/nome/endereço).

### Endpoints de API

Não aplicável (apenas MapKit local e persistência local).

## Pontos de Integração

- Apple Maps / MapKit:
  - `MKLocalSearch` (busca textual) para resolver coordenadas.
  - Estratégia de query: `"name, address, city, state"` com fallback para variações (ex.: sem número, sem categoria).
  - Heurísticas: aceitar resultado se distância entre coordenada atual e encontrada for aceitável OU se address match for forte.

- Deep links/URLs:
  - Apple Maps: `MKMapItem.openInMaps`.
  - Google Maps: URL `https://www.google.com/maps/search/?api=1&query=lat,lng` (ou query textual), marcando apenas como “linkável”.

## Abordagem de Testes

### Testes Unitários

- `RestaurantRatingAggregator`:
  - média e contagem corretas
  - tratamento de ausência de visitas
  - recência (`lastVisitedAt`) correta

- Priorização por rating (randomizer/seleção):
  - quando filtro mínimo ativo, não retornar itens abaixo
  - quando priorização ativa, maior probabilidade para top-rated (determinístico via RNG injetável)

- `PlaceResolver`:
  - usar mock/fake; não chamar MapKit real em unit tests
  - validar que orquestrador faz cache e respeita `applePlaceResolvedAt`

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Modelos/persistência: campos novos em `RestaurantModel` e migração.
2. Rating interno: agregador + atualização após `RatingViewModel.save()`.
3. Localização: resolver MapKit + serviço de enriquecimento (single/batch).
4. UI: exibição de rating e estados (loading), CTAs do Maps.
5. Navegação: TabBar no fluxo e ajustes no retorno do sorteio/detalhe.
6. Testes e ajustes finos.

### Dependências Técnicas

- Permissões: acesso a localização do usuário não é obrigatório para resolver por texto, mas pode ser usado para melhorar ranking (opcional).
- MapKit requer dispositivo/simulador com frameworks; chamadas são locais ao ecossistema Apple.

## Considerações Técnicas

### Decisões Principais

- Apple Maps como fonte de verdade para coordenadas: reduz dependência de chaves/billing.
- Rating interno derivado de `VisitModel`: mantém privacidade e independência de dados externos.
- Cache no SwiftData para reduzir custo e latência de buscas repetidas.

### Riscos Conhecidos

- `MKLocalSearch` pode retornar resultados ambíguos: mitigação via heurísticas, fallback e possibilidade de marcação “não resolvido”.
- Backfill em lote pode consumir tempo: mitigação com batches pequenos, throttling e execução sob demanda.
- Mudanças de navegação podem introduzir regressões: mitigação com testes manuais por fluxo e ajustes incrementais.

### Requisitos Especiais

- Performance: não travar a UI; limitar concorrência no batch (ex.: 2–4 buscas simultâneas).
- Privacidade: não enviar dados para serviços externos além de MapKit (já parte do sistema).

### Conformidade com Padrões

- (Sem regras específicas adicionais encontradas nesta repo; seguir padrões SwiftUI/SwiftData existentes.)

### Arquivos relevantes

- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppRouter.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/MainTabView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RouletteView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RatingView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataVisitRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`




