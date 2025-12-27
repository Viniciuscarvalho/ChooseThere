# Especificação Técnica: Seleção de Cidade + “Perto de mim” (Any City Mode) + Configurações

## Resumo Executivo

Esta entrega adiciona (1) uma camada de **preferências globais** (cidade selecionada, modo atual, raio e fonte do “Perto de mim”), (2) um **fluxo de onboarding** para seleção de cidade no primeiro uso e (3) um modo “**Perto de mim**” com duas fontes de dados: **Minha base** (SwiftData/JSON) e **Apple Maps** (MapKit/MKLocalSearch), com **cache local** para reduzir custo e latência.

O app continuará funcionando offline para “Minha base”. Para Apple Maps, será usado cache com TTL e “bucket” de localização (arredondamento de lat/lng) para evitar consultas repetidas ao longo de uma mesma região.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- `AppSettingsStorage` (novo, Application): persistência em `UserDefaults` para cidade selecionada, modo atual, raio e fonte padrão.
- `CityCatalog` (novo, Domain/Services): extrai lista de cidades (unique `city/state`) a partir do seed local (SwiftData/JSON).
- `NearbyModeViewModel` (novo, Presentation/ViewModels): orquestra filtros, permissões, busca e cache.
- `NearbyLocalFilterService` (novo, Domain/Services): filtra restaurantes locais por distância a partir de `RestaurantRepository`.
- `AppleMapsNearbySearchService` (novo, Domain/Services): busca lugares próximos via MapKit (`MKLocalSearch`).
- `NearbyCacheStore` (novo, Data/Services): cache local com TTL para resultados do Apple Maps.
- Views impactadas/novas:
  - `OnboardingView` (atualizada para incluir seleção de cidade)
  - Novo `CitySelectionView` (tela do onboarding e reuso em Configurações)
  - Novo `SettingsView` (configurações: cidade e preferências do “Perto de mim”)
  - Ajustes em `PreferencesView` (para conter o segmento “Minha Lista | Perto de mim” ou navegação equivalente)

Fluxo de dados (alto nível):
1. Primeiro uso -> onboarding -> seleção de cidade -> persistir settings -> tabs.
2. “Perto de mim”:
   - Fonte “Minha base”: consulta SwiftData e filtra por distância.
   - Fonte “Apple Maps”: executa search via MapKit -> cacheia -> retorna lista para roleta.
3. Configurações: altera settings e invalida/renova cache conforme necessário.

## Design de Implementação

### Interfaces Principais

```swift
protocol AppSettingsStoring {
  var selectedCityKey: String? { get set } // ex: "São Paulo|SP" ou nil para AnyCity
  var nearbySource: NearbySource { get set } // .localBase | .appleMaps
  var nearbyRadiusKm: Int { get set } // 1...10
}

protocol NearbySearching {
  func search(
    radiusKm: Int,
    category: String?,
    userCoordinate: CLLocationCoordinate2D,
    cityHint: String?
  ) async throws -> [NearbyPlace]
}
```

### Modelos de Dados

Preferências (UserDefaults):
- `selectedCityKey: String?`
  - `nil` significa **Any City**
  - caso contrário: `"city|state"` (ex.: `"São Paulo|SP"`)
- `nearbySource: NearbySource` (`localBase` | `appleMaps`)
- `nearbyRadiusKm: Int` (default: 3)
- `nearbyLastCategory: String?` (opcional)

Cache (local):
- `NearbyCacheKey`:
  - `source` (sempre `appleMaps`)
  - `category` (ou nil)
  - `radiusKm`
  - `cityHint` (ou nil)
  - `locationBucket` (ex.: `latRounded/lngRounded` em 2–3 casas decimais)
- `NearbyCacheEntry`:
  - `key`
  - `createdAt`
  - `ttlSeconds`
  - `places: [NearbyPlace]`

Entidade transitória para resultados do Apple Maps:
- `NearbyPlace`:
  - `id: String` (ex.: hash estável de `name+coordinate`, ou `MKMapItem` derivado quando possível)
  - `name: String`
  - `address: String?`
  - `coordinate: CLLocationCoordinate2D`
  - `categoryHint: String?`
  - `externalLink: URL?` (opcional)

Decisão: **não persistir** resultados do Apple Maps como `RestaurantModel` para não “poluir” a base do usuário. O fluxo de UI para resultado do Apple Maps será um detalhe leve (ex.: sheet/overlay) que permite abrir no Maps e/ou adicionar à lista futuramente (fora do escopo).

### Endpoints de API

Não aplicável (MapKit é integração local do ecossistema Apple; não há backend próprio).

## Pontos de Integração

- **CoreLocation**:
  - `CLLocationManager` para obter localização atual (quando o usuário optar pelo modo “Perto de mim”).
  - Estados: não determinado, permitido, negado/restrito.
- **MapKit**:
  - `MKLocalSearch` para busca de lugares próximos por query textual + região.
  - Query construída a partir do filtro de categoria/tipo e, quando aplicável, `cityHint`.

Tratamento de erros:
- Sem permissão: mostrar UI explicando e ação “Abrir Ajustes”.
- Sem rede/erro MapKit: fallback para estado de erro e sugestão de trocar para “Minha base”.
- Zero resultados: empty state (com ajuste de raio/tipo).

## Abordagem de Testes

### Testes Unitários

- `CityCatalog`:
  - extrai cidades únicas do seed local
  - ordenação estável
  - inclui opção Any City
- `NearbyLocalFilterService`:
  - distância correta (haversine via CoreLocation)
  - aplica raio e categoria/tags
- `NearbyCacheStore`:
  - hit/miss por key
  - expiração por TTL
  - invalidação manual (clear)
- `NearbyModeViewModel` (com mocks):
  - alternância de fonte
  - comportamento sem permissão
  - comportamento com cache (não chama search quando cache válido)

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. `AppSettingsStorage` (UserDefaults) + `CityCatalog` (derivar lista de cidades).
2. Atualizar onboarding para capturar cidade no primeiro uso.
3. Implementar `SettingsView` (troca de cidade e preferências, limpar cache).
4. Implementar “Perto de mim” fonte “Minha base” (filtro por distância).
5. Implementar “Perto de mim” fonte “Apple Maps” + cache TTL.
6. Ajustes de UI/UX (estados, copy, acessibilidade).
7. Testes unitários principais.

### Dependências Técnicas

- iOS: `CoreLocation`, `MapKit`, SwiftUI, SwiftData.
- Permissões: uso de `NSLocationWhenInUseUsageDescription` (ajustes no projeto, se ainda não existir).

## Considerações Técnicas

### Decisões Principais

- Persistência simples de preferências em `UserDefaults` (coerente com `OnboardingStorage` existente).
- Cache local com TTL e bucket de localização para reduzir chamadas ao MapKit.
- Resultados Apple Maps como `NearbyPlace` (transitório), evitando persistir como restaurante local nesta fase.

### Riscos Conhecidos

- UX de localização (permissão negada) pode bloquear o modo “Perto de mim”: mitigação via estados e fallback para “Minha base”.
- `MKLocalSearch` pode retornar resultados inconsistentes: mitigação via query simples e filtros básicos; ajustes iterativos.
- Definição de bucket/TTL: trade-off entre frescor e custo. Começar simples (ex.: TTL 30min e arredondamento 0.01).

### Requisitos Especiais

- Performance: evitar travar UI (async/await); usar cache; limitar chamadas repetidas.
- Privacidade: não enviar dados a serviços além do ecossistema Apple (MapKit).
- Acessibilidade: controles de segmento/raio/tipo com labels e tamanho mínimo.

### Conformidade com Padrões

- Regras (em `.cursor/rules`):
  - `/.cursor/rules/code-standards.md` (Swift Style Guide)

[Utilize as skills na pasta @.cursor/skills que se encaixam nesta techspec]
- Skills aplicáveis:
  - `/.cursor/skills/ios-development-skill/skill-ios.md` (SwiftUI, async/await, CoreLocation/MapKit)
  - `/.cursor/skills/design/skill-design.md` (HIG para Configurações e onboarding)
  - `/.cursor/skills/skill-debugger/skill-crash-debugger.md` (suporte caso haja crashes/permissões)

### Arquivos relevantes

- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/OnboardingStorage.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/RootView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/OnboardingView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/MainTabView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/PreferencesViewModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`


