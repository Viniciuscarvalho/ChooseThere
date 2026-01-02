# TechSpec — Nearby Roulette + Eden UX (ChooseThere)

## Resumo Executivo

Vamos implementar um novo fluxo de sorteio que usa **Apple Maps (MapKit/MKLocalSearch)** para obter restaurantes próximos em um raio máximo de **10km**, aplicar os **mesmos filtros e regra de negócio** do sorteio atual (tags desejadas/evitar, radius, prioridade de rating, preferências aprendidas e anti-repetição) e então sortear um resultado e navegar para a tela de resultado.

Em paralelo, vamos refatorar a tela “Escolher” (`PreferencesView`) para remover duplicidades e organizar as informações em uma hierarquia clara inspirada no UI kit “Eden”, mantendo consistência de componentes, performance (SwiftUI) e acessibilidade.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **UI**
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
    - Tela de escolha (modo, filtros e CTA).
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RouletteView.swift`
    - Tela da roleta (animação + resultado).
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/ResultView.swift`
    - Tela de resultado (detalhe do restaurante).
- **ViewModels**
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/RouletteViewModel.swift`
    - Controla o sorteio e fase da animação.
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/PreferencesViewModel.swift`
    - Guarda filtros do modo “Minha Lista” (tags, avoid, radius, rating priority, etc.) e “pendingId”.
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
    - Busca e mantém estado do modo “Perto de mim” (fonte local/Apple Maps, radiusKm, selectedCategory).
- **Domínio**
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/SmartRouletteService.swift`
    - Orquestra sorteio + anti-repetição + preferências aprendidas.
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`
    - Filtra candidatos por contexto e sorteia (uniforme/ponderado).
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/AppleMapsNearbySearchService.swift`
    - Busca em Apple Maps e cacheia resultados.
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/NearbyLocalFilterService.swift`
    - Filtra base local por distância/categoria.
- **Infra/Storage**
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppSettingsStorage.swift`
    - Persistência de preferências (modo, radius, cidade, etc.).
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Services/NearbyCacheStore.swift`
    - Cache dos resultados do Apple Maps.
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Repositories/RestaurantRepository.swift`
    - Fonte da base local (seed/SwiftData).

## Design de Implementação

### Interfaces Principais

Criaremos uma camada de orquestração “sorteio nearby” para reduzir acoplamento de UI com MapKit e para reusar `SmartRouletteService`.

```swift
protocol NearbyRouletteServicing {
  func drawNearby(
    context: PreferenceContext,
    radiusKm: Int,
    category: String?,
    cityHint: String?
  ) async throws -> Restaurant
}
```

Notas:
- O retorno é um `Restaurant` do domínio para integrar diretamente com `ResultView` (que usa `restaurantId`).
- A implementação pode:
  - Tentar correlacionar `NearbyPlace` com `RestaurantRepository` (pelo nome/cidade/coord) para obter `id` e tags internas.
  - Caso não encontre correspondência, pode criar um “restaurant transitório” **apenas para sorteio** e persistir/selecionar conforme estratégia definida (ver Modelos de Dados).

### Modelos de Dados

Reuso:
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/Restaurant.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/PreferenceContext.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/NearbyPlace.swift`

Proposta (sem mudar persistência agora):
- Introduzir um tipo interno (domínio) “candidato de sorteio” para Apple Maps quando não existir `Restaurant` correspondente:

```swift
struct RouletteCandidate {
  let id: String
  let name: String
  let lat: Double
  let lng: Double
  let category: String
  let tags: [String]
  let ratingAverage: Double
  let ratingCount: Int
}
```

Estratégia:
- Se o resultado Apple Maps corresponder a um `Restaurant` local (mesma cidade + nome aproximado), usar o `Restaurant` local (tags e ratings internas).
- Se não corresponder:
  - `tags`: derivadas do `category` do Apple Maps + termos do query (quando aplicável).
  - `rating*`: tratar como “sem avaliação interna” (`ratingCount=0`).

Compatibilidade com regra atual:
- `RestaurantRandomizer` já filtra por:
  - desiredTags (match mínimo 1)
  - avoidTags (nenhum match)
  - radiusKm + userLocation
  - ratingPriority == .only (exige rating interno >= 4.0 e pelo menos 1 rating)
- Para Apple Maps “sem rating interno”, o modo `.only` pode eliminar todos os candidatos. Portanto:
  - Implementar fallback específico: se `.only` resultar em zero candidatos, relaxar para `.prefer` (somente no fluxo nearby) e sortear com peso menor para “sem avaliação”.

### Endpoints de API

Não aplicável.

## Pontos de Integração

- **MapKit / MKLocalSearch**: `AppleMapsNearbySearchService` via `NearbySearching`.
- **CoreLocation**: `LocationManager` (via `LocationManaging`) para obter coordenadas.
- **SwiftData (base local)**: `RestaurantRepository.fetchAll()` para fallback e para correlacionar Apple Maps → base local quando possível.

Tratamento de erros e UX:
- Sem permissão: estado `noPermission` com CTA para Settings.
- Erro de rede/busca: mostrar erro e oferecer retry.
- Sem resultados: mostrar vazio e (em SP) sugerir fallback para base local.

## Abordagem de Testes

### Testes Unitários

Cobertura mínima:
- **Orquestração do sorteio nearby**
  - Dado um conjunto de `NearbyPlace` mockado, garantir que:
    - aplica desiredTags/avoidTags
    - respeita raio (<=10km)
    - aplica anti-repetição (sessão + histórico recente via `SmartRouletteService`)
    - fallback de `.only` → `.prefer` quando necessário
- **Regra SP-only**
  - Fora de SP: fonte local desabilitada/oculta e sorteio nearby não usa JSON.
  - Em SP: fallback para base local quando Apple Maps falhar/der vazio.
- **UI**
  - Testes unitários de view model (ex.: `PreferencesViewModel` monta `PreferenceContext` corretamente).

Mocks necessários:
- `NearbySearching`
- `LocationManaging`
- `RecentHistoryProviding`
- `RestaurantRepository` (fetchAll) e opcionalmente um método para match/correlação.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Documentar decisões e regras (PRD/TechSpec) para travar escopo.
2. Implementar montagem de `PreferenceContext` real no fluxo de sorteio (tirar contexto vazio do `RouletteViewModel`).
3. Implementar serviço/orquestração de sorteio nearby (MapKit → candidatos → `SmartRouletteService`).
4. Aplicar regra SP-only e fallback.
5. Refatorar `PreferencesView` (Eden) e integrar “Sortear perto de mim” com estados corretos.
6. Performance audit e ajustes SwiftUI (reduzir recomputações).
7. Testes unitários e regressão.

### Dependências Técnicas

- Permissão de localização no simulador/dispositivo para validar UX.
- MapKit disponível (sem dependência de rede paga; mas depende de conectividade).

## Considerações Técnicas

### Decisões Principais

- **Reusar** `SmartRouletteService` + `RestaurantRandomizer` para manter regra única de sorteio.
- **Apple Maps como fonte primária** do modo “Perto de mim”, com raio até 10km.
- **SP-only** para a base local/JSON no modo “Perto de mim”; fora de SP, remover a opção para evitar confusão.
- **Fallback de rating (.only)** no nearby: relaxar quando não houver dados internos suficientes.

### Riscos Conhecidos

- Matching Apple Maps → base local pode ser impreciso (nomes diferentes, acentos, abreviações).
  - Mitigação: matching heurístico simples + fallback para candidato transitório.
- Latência do MKLocalSearch pode variar.
  - Mitigação: cache (`NearbyCacheStore`) + estados de UI claros.
- SwiftUI performance: `PreferencesView` é grande e pode recomputar muito.
  - Mitigação: refator em subviews puras, reduzir bindings, usar `EquatableView` quando fizer sentido, e evitar trabalho em `body`.

### Requisitos Especiais

- Performance:
  - Evitar múltiplas buscas simultâneas; debouncing para mudanças de filtros (se aplicável).
  - Cache-first para Apple Maps já existe; revisar chave para reduzir miss desnecessário.
- Privacidade:
  - Não persistir coordenadas do usuário (usar apenas em memória).

### Conformidade com Padrões

- Skills:
  - `@.cursor/skills/swiftui-view-refactor/`
  - `@.cursor/skills/swiftui-performance-audit/`
  - `@.cursor/skills/ios-development-skill/skill-ios.md` (HIG/touch targets/acessibilidade)

### Arquivos relevantes

- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/RouletteViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/NearbyModeViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/SmartRouletteService.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/AppleMapsNearbySearchService.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppSettingsStorage.swift`


