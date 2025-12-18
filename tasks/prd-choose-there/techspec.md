# ChooseThere — Especificação Técnica (V1 iOS)

## Resumo Executivo
A V1 do ChooseThere será um app iOS offline-first que carrega uma lista de restaurantes (JSON no bundle) e persiste dados localmente com SwiftData, mantendo uma única fonte de verdade após o seed inicial. A solução adota uma arquitetura modular em camadas (Domain/Data/Presentation) com Composition Root responsável por wiring e DI via Swinject. A navegação será feita via padrão Router (sem `NavigationStack`), permitindo evolução do fluxo sem acoplamento direto a navegação declarativa do SwiftUI.

A implementação prioriza simplicidade: filtros básicos (tags, preço, raio, evitar), animação de roleta e um resultado acionável com mapa e abertura de rota. O histórico de visitas e avaliações alimenta filtros e abre caminho para melhorias futuras de ranking, sem dependência de backend.

## Arquitetura do Sistema

### Visão Geral dos Componentes
- **Domain**
  - **Responsabilidades**: regras de negócio (filtragem, sorteio), entidades de domínio e contratos (protocolos).
  - **Conhecido por**: todos os módulos/camadas.
  - **Conhece**: ninguém (sem dependências concretas).
- **Data**
  - **Responsabilidades**: seed/import do JSON, persistência SwiftData, mapeamentos e implementações concretas de repositório.
  - **Conhecido por**: Composition Root / App (wiring).
  - **Conhece**: Domain (para implementar contratos).
- **Presentation**
  - **Responsabilidades**: Views SwiftUI, ViewModels, Router, estados de tela, validações de input.
  - **Conhecido por**: App (Composition Root).
  - **Conhece**: Domain (para usar casos de uso/regras).
- **Application / Composition Root**
  - **Responsabilidades**: configurar Swinject, registrar dependências, configurar SwiftData `ModelContainer`, iniciar seed e injetar Router/ViewModels.
  - **Conhecido por**: ninguém (ponto mais alto).
  - **Conhece**: todos.

Fluxo de alto nível (runtime):
1) App inicia → Composition Root cria Container (Swinject) e SwiftData container.
2) Data faz seed do JSON para SwiftData se necessário.
3) Presentation lê dados via repositórios (Domain protocols) e executa sorteio/fluxos.

## Design de Implementação

### Interfaces Principais
As interfaces residem em **Domain**, e as implementações em **Data**.

```swift
import Foundation

public protocol RestaurantRepository {
  func fetchAll() throws -> [Restaurant]
  func fetch(id: String) throws -> Restaurant?
  func setFavorite(id: String, isFavorite: Bool) throws
}

public protocol VisitRepository {
  func add(_ visit: Visit) throws
  func update(_ visit: Visit) throws
  func fetchAll() throws -> [Visit]
}

public protocol RestaurantRandomizer {
  func pick(
    from restaurants: [Restaurant],
    context: PreferenceContext,
    excludeRestaurantIDs: Set<String>
  ) -> Restaurant?
}
```

Observação: na V1, “use cases” podem ser structs simples no Domain (ex.: `PickRestaurantUseCase`), orquestrando repositórios e o randomizer.

### Modelos de Dados
Existem dois níveis de modelagem:
1) **Domain models** (structs) usados na regra de negócio e na Presentation.
2) **SwiftData models** (classes `@Model`) como fonte persistida.

#### Domain
- `Restaurant`
  - `id: String` (estável, vindo do JSON)
  - `name: String`
  - `category: String` (ex.: “bar”, “brunch”)
  - `address: String`
  - `city: String`
  - `state: String`
  - `tags: [String]`
  - `notes: String`
  - `externalLink: URL?`
  - `lat: Double`
  - `lng: Double`
  - `isFavorite: Bool`
  - `priceTier: PriceTier?` (opcional na V1 se não existir na lista)
- `Visit`
  - `id: UUID` (gerado localmente)
  - `restaurantId: String`
  - `dateVisited: Date`
  - `rating: Int` (1–5)
  - `tags: [String]`
  - `note: String?`
  - `isMatch: Bool`
  - `wouldReturn: Bool` (derivado de tag “Voltaria” ou campo explícito)
- `PreferenceContext`
  - `desiredTags: Set<String>`
  - `avoidTags: Set<String>`
  - `radiusKm: Int`
  - `priceTier: PriceTier?`
  - `userLocation: (lat: Double, lng: Double)?`

#### SwiftData (fonte única de verdade)
Substituir o scaffold atual (`Item`) por modelos equivalentes:
- `RestaurantModel` (`@Model`)
  - Campos espelhando `Restaurant` + `seedVersion: Int`/`importedAt: Date` (opcional)
- `VisitModel` (`@Model`)
  - Campos espelhando `Visit`

Estratégia de “fonte única”:
- **Primeira execução**: importar `Restaurants.json` para `RestaurantModel` se não houver registros.
- **A partir daí**: o app lê sempre do SwiftData; o JSON só é consultado novamente em caso de migração/seed version (futuro).

### Endpoints de API
Não aplicável (V1 offline, sem backend).

## Pontos de Integração
- **Swinject (DI via SPM)**
  - Composition Root registra: repositórios, randomizer, serviços de localização e Router.
  - Evitar `Container` global: injetar via inicialização de ViewModels/Router.
- **SwiftData**
  - `ModelContainer` criado no App (Composition Root).
  - `ModelContext` injetado no Data layer (ex.: `SwiftDataRestaurantRepository`).
- **Localização/Distância**
  - Usar CoreLocation para obter localização atual (com fallback quando negado).
  - Cálculo de distância (Haversine ou `CLLocation.distance(from:)`).
- **Mapas**
  - **Apple Maps** via MapKit (exibir pin e abrir rota).
  - **Google Maps** opcional apenas para “abrir rota” via URL scheme, se instalado.

Falhas e degradação:
- Sem permissão de localização: raio/distância podem ser ocultados ou desabilitados, e o filtro de raio vira “ignorado” com aviso na UI.
- Links externos (Instagram/Maps) dependem do app externo; se indisponível, mostrar erro amigável.

## Abordagem de Testes

### Testes Unitários
- **Domain**
  - `RestaurantRandomizer`:
    - respeita `avoidTags`
    - respeita `desiredTags` (quando preenchido)
    - evita repetição usando `excludeRestaurantIDs` (re-rolls)
  - `PickRestaurantUseCase`:
    - retorna nil quando não há candidatos
    - mantém determinismo com RNG injetável (para teste)
- **Data**
  - Seed/import do JSON:
    - importa N registros, preserva ids
    - não duplica registros em segunda execução
  - Repositórios SwiftData:
    - CRUD de `VisitModel`
    - toggle de favorito em `RestaurantModel`
- **Presentation**
  - ViewModels:
    - estados e validações básicas (ex.: habilitar/desabilitar sortear)
    - fluxo de re-rolls (contagem e reset)

Mocks:
- Mock de `RestaurantRepository` e `VisitRepository` para testes de Domain/Presentation.
- Para Data, preferir SwiftData in-memory (`ModelConfiguration(isStoredInMemoryOnly: true)`).

## Sequenciamento de Desenvolvimento

### Ordem de Construção
1. **Domain**: entidades, `PreferenceContext`, randomizer e contratos de repositório (base de todo o resto).
2. **Data**: modelos SwiftData + seed do JSON + repositórios concretos.
3. **Presentation**: Router + telas (Preferências → Roleta → Resultado → Avaliação → Histórico).
4. **Integrações**: MapKit/CoreLocation e “abrir no Maps”.
5. **Polimento**: estados vazios, acessibilidade, ajustes de UX e testes adicionais.

### Dependências Técnicas
- `Restaurants.json` deve conter `lat` e `lng` para todos os restaurantes na V1.
- Swinject adicionado via SPM ao projeto iOS.

## Considerações Técnicas

### Decisões Principais
- **Router em vez de `NavigationStack`**: para controle explícito do fluxo e previsibilidade; facilita testes e evolução do fluxo.
- **SwiftData como fonte única**: elimina duplicidade e inconsistência (JSON apenas seed).
- **Randomizer no Domain**: mantém regras de sorteio independentes de UI/persistência.
- **Google Maps opcional**: reduzir dependência/complexidade, mantendo Apple Maps como padrão.

### Riscos Conhecidos
- **Qualidade dos dados**: lat/lng ausentes ou incorretos podem quebrar raio/mapa → validar no seed e reportar erros de forma clara.
- **Permissões de localização**: usuários podem negar → UX precisa fallback consistente.
- **Crescimento do JSON**: seed em primeira execução pode ficar lento → otimizar import e evitar duplicação.

### Requisitos Especiais
- Performance: seed inicial deve ser rápido (meta: < 1s para poucas centenas de itens).
- Privacidade: não enviar dados para rede; usar apenas localização local para cálculo de distância.

### Conformidade com Padrões
- `.cursor/rules/code-standards.md` (Kodeco Swift Style Guide): nomenclatura, organização por extensions, minimal imports, clareza e consistência.

### Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThereApp.swift` (criação do `ModelContainer` hoje)
- `ChooseThere/ChooseThere/ContentView.swift` (scaffold atual; será substituído pelo Router/root view)
- `ChooseThere/ChooseThere/Item.swift` (modelo de exemplo; será substituído por `RestaurantModel`/`VisitModel`)
- `Restaurants.json` (fonte de seed dos restaurantes)
- `.cursor/rules/code-standards.md` (padrões de código)


