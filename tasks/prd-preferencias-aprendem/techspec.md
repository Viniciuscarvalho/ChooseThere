# Especificação Técnica: Preferências que aprendem (Fase 3)

## Resumo Executivo

Esta entrega adiciona um sistema de “preferências que aprendem” **rule-based** para melhorar o sorteio com o tempo. O sistema mantém pesos simples para tags/categorias, atualizados a partir das avaliações (visitas). O `RestaurantRandomizer` passa a ponderar candidatos com base no match desses pesos e evita repetir restaurantes recentes (últimos N).

Persistência será local (preferencialmente `UserDefaults` para pesos e parâmetros globais; e `SwiftData`/`VisitRepository` para histórico). A solução é desenhada para ser testável com RNG injetável e mocks para dependências.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- `LearnedPreferences` (novo, Domain): estrutura com pesos e metadados (última atualização).
- `LearnedPreferencesStore` (novo, Application/Services): persistência em `UserDefaults` (encode/decode JSON).
- `PreferenceLearningService` (novo, Domain/Services):
  - recebe eventos de avaliação (ex.: rating do `VisitModel`)
  - atualiza pesos (clamp + step)
- `RecentHistoryService` (novo, Domain/Services):
  - obtém últimos N restaurantes (por `VisitRepository` e/ou cache de sorteios)
  - gera set de `excludeRestaurantIDs` para o randomizer
- `RestaurantRandomizer` (existente):
  - adicionar modo de peso por match (sem quebrar comportamento atual)
- UI:
  - `SettingsView` (atualizar): toggle “Preferências que aprendem”, botão reset e config do N (se aplicável).

## Design de Implementação

### Interfaces Principais

```swift
protocol LearnedPreferencesStoring {
  func load() -> LearnedPreferences
  func save(_ prefs: LearnedPreferences)
  func reset()
}

protocol PreferenceLearning {
  func applyRating(
    restaurant: Restaurant,
    rating: Int,
    tags: [String],
    category: String
  ) -> LearnedPreferences
}

protocol RecentHistoryProviding {
  func recentRestaurantIDs(limit: Int) throws -> [String]
}
```

### Modelos de Dados

`LearnedPreferences` (Codable):
- `tagWeights: [String: Double]`
- `categoryWeights: [String: Double]`
- `updatedAt: Date`
- `version: Int`

Parâmetros (UserDefaults):
- `learningEnabled: Bool` (default: true)
- `avoidRepeatsLimit: Int` (default: 10)

Regras de atualização (exemplo inicial):
- Rating 5: +1.0
- Rating 4: +0.5
- Rating 3: 0
- Rating 2: -0.5
- Rating 1: -1.0
- Clamp pesos: [-5.0, +5.0]

Match scoring (exemplo inicial):
- Score base = 1.0
- + soma de pesos de tags presentes
- + peso da categoria
- Converter scores em pesos positivos para sorteio:
  - `weight = max(0.1, 1.0 + score)` (evita zero)

### Endpoints de API

Não aplicável.

## Pontos de Integração

- `VisitRepository` / `VisitModel`:
  - o evento de avaliação deve disparar o `PreferenceLearningService`
  - alternativa: recalcular a cada abertura (menos eficiente)
- `RestaurantRandomizer`:
  - receber `LearnedPreferences` opcional no `PreferenceContext` (ou via parâmetro adicional)
  - respeitar `excludeRestaurantIDs` (já existe)

## Abordagem de Testes

### Testes Unitários

- `LearnedPreferencesStoreTests`:
  - encode/decode e reset
- `PreferenceLearningServiceTests`:
  - atualização por rating e clamp
- `RecentHistoryServiceTests`:
  - retorna últimos N IDs corretamente (com repositório fake)
- `RestaurantRandomizerTests`:
  - determinismo com RNG injetável
  - distribuição “puxa” para itens com peso maior (teste estatístico leve ou teste de peso determinístico com RNG fixo)
- `Integration-style` (sem UI):
  - aplicar rating → atualizar prefs → usar randomizer com contexto

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Modelos `LearnedPreferences` + store (UserDefaults).
2. `PreferenceLearningService` (regras por rating).
3. `RecentHistoryService` (últimos N).
4. Integrar no `RestaurantRandomizer` (ponderação por match).
5. Integrar no fluxo de avaliação (quando grava `VisitModel`).
6. UI em `SettingsView` para controle/reset.
7. Testes unitários.

### Dependências Técnicas

- `UserDefaults` para persistência simples de prefs.
- `SwiftData` para histórico de visitas.

## Considerações Técnicas

### Decisões Principais

- Sem ML: regras simples e transparentes.
- Pesos versionados para evolução futura.
- Fallback: sem pesos, randomizer deve se comportar como hoje.

### Riscos Conhecidos

- “Overfitting” rápido (pesos exagerados) → mitigação: clamp e steps pequenos.
- Pequena variedade de restaurantes → mitigação: fallback quando evitar repetidos bloqueia demais.

### Requisitos Especiais

- Performance: atualização de pesos deve ser O(tags) e não travar UI.
- Testabilidade: RNG injetável e serviços com dependências mockáveis.

### Conformidade com Padrões

- `/.cursor/rules/code-standards.md` (Kodeco Swift Style Guide)

### Arquivos relevantes

- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/RestaurantRandomizer.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/PreferenceContext.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`

