# Especificação Técnica: Links Externos + Cards (Deliverio style)

## Resumo Executivo

Esta feature adiciona **cards de restaurantes** com imagem e ações rápidas para **TripAdvisor**, **iFood** e **99** (com fallback para rota no Maps). Como não utilizaremos APIs pagas, os links serão **salvos manualmente** no SwiftData e a imagem será carregada via **OpenGraph** (meta `og:image`) do site do restaurante quando disponível, com cache e timeouts para manter a UI responsiva.

O trabalho se divide em: (1) evolução do modelo/persistência; (2) serviço de OpenGraph para resolver imagem; (3) componentes UI (cards e editor de links); (4) integração nas telas de “Minha base” e “Perto de mim”; (5) testes e QA.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **Model/Persistência**
  - `RestaurantModel` (SwiftData): armazenará URLs específicas e opcionalmente `imageURL`.
  - `Restaurant` (Domain): refletirá os novos campos como `URL?`.
  - `RestaurantRepository` + `SwiftDataRestaurantRepository`: leitura/gravação dos novos campos.

- **Serviço de imagem via OpenGraph**
  - `OpenGraphImageResolver` (novo, Domain/Services ou Data/Services):
    - Entrada: `websiteURL` (String/URL) ou `externalLink` existente
    - Saída: `URL?` da imagem (`og:image`)
    - Comportamento: async/await; timeout; parse HTML; cache.

- **Abertura de links**
  - `ExternalLinkOpener` (novo helper):
    - Usa `openURL`/`UIApplication.shared.open` para abrir URLs.
    - Para 99: se `ride99URL` não existir, abre rota no Apple Maps usando coordenadas do restaurante.

- **UI**
  - `RestaurantCard` (novo componente):
    - imagem (AsyncImage/loader custom)
    - nome/categoria/rating/distance
    - botões rápidos: TripAdvisor / iFood / 99 (ou rota no mapa)
  - `RestaurantLinksEditorView` (novo sheet):
    - campos de texto com validação simples
    - botão “Salvar”
    - suporte “Colar” (Clipboard) opcional

Fluxo de dados:
1. Listas carregam `Restaurant` do repositório.
2. `RestaurantCard` pede imagem:
   - se `imageURL` existe, usa direto
   - senão tenta `OpenGraphImageResolver` a partir de `externalLink`/site (se existir)
3. Usuário pode abrir links externos ou editar/salvar links.
4. Links salvos persistem no SwiftData e passam a aparecer como ações rápidas.

## Design de Implementação

### Interfaces Principais

```go
// Resolver de imagem via OpenGraph (sem API paga)
type OpenGraphImageResolver interface {
  Resolve(websiteURL string) (imageURL string, ok bool, err error)
}

// Abridor de links externos
type ExternalLinkOpener interface {
  Open(url string) error
  OpenRoute(lat float64, lng float64, name string) error
}
```

> Implementação real será em Swift com `async/await` e tipos `URL`.

### Modelos de Dados

Evolução sugerida:

- `RestaurantModel` (SwiftData):
  - `tripAdvisorURL: String?`
  - `iFoodURL: String?`
  - `ride99URL: String?` (opcional)
  - `imageURL: String?` (manual/curado; maior prioridade)
  - Reaproveitar `externalLink: String?` como “site do restaurante” (se já for esse significado) ou manter como “site genérico” e adicionar `websiteURL` explícito.

- `Restaurant` (Domain):
  - `tripAdvisorURL: URL?`
  - `iFoodURL: URL?`
  - `ride99URL: URL?`
  - `imageURL: URL?`

Regras:
- Se `ride99URL == nil`: mostrar ação “Rota no mapa” (Apple Maps).
- Imagem:
  - `imageURL` manual tem precedência.
  - OpenGraph só será tentado quando houver `externalLink` (site) válido.
  - Se falhar, usar placeholder consistente com design.

### Endpoints de API

Não aplicável (sem backend). O único “fetch” é o HTML do site do restaurante para ler OpenGraph.

## Pontos de Integração

- **OpenGraph (HTML)**
  - `URLSession` com timeout (ex.: 2–4s) e tratamento de erros.
  - Parsing:
    - localizar `<meta property="og:image" content="...">` (ou `name="og:image"`)
    - aceitar URLs absolutas e relativas (resolver relativo via `URL(baseURL: ...)`)
  - Cache:
    - `NSCache` em memória por `host/path`
    - opcionalmente `URLCache` para requests.

- **Abrir links**
  - Preferir `OpenURLAction` (SwiftUI `@Environment(\\.openURL)`) em views.
  - Em camadas não-UI, usar `UIApplication.shared.open` no `@MainActor`.

- **Maps fallback (99)**
  - Usar `MKMapItem.openInMaps` com destino do restaurante.

## Abordagem de Testes

### Testes Unitários

- `OpenGraphImageResolver`:
  - parsing de HTML com fixtures (sem rede)
  - resolver URL relativa corretamente
  - ignorar quando não há `og:image`

- Validação de URLs:
  - aceitar `https://...`
  - rejeitar strings inválidas

- `RestaurantCard`/ViewModel (se houver):
  - estados: loading → image → fallback placeholder

### Testes Manuais (QA)

- “Minha base”: cards carregam; abrir detalhe; ações rápidas quando links existem.
- “Perto de mim”: resultados do Apple Maps exibem cards; “rota no mapa” funciona.
- Edição de links: colar URLs; validação; persistir; reabrir app e verificar.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Modelos/persistência (novos campos no SwiftData + mapping domain).
2. Editor de links + validação.
3. OpenGraph resolver + cache.
4. Componente `RestaurantCard` no estilo Deliverio (adaptado ao design system atual).
5. Aplicar cards em “Minha base” e “Perto de mim”.
6. QA e testes.

### Dependências Técnicas

- Acesso à internet (para OpenGraph do site do restaurante).
- MapKit para fallback de rota no mapa.

## Considerações Técnicas

### Decisões Principais

- **Sem API paga**: links externos serão curados manualmente.
- **Sem scraping do Google**: imagens via OpenGraph do site (best-effort).
- **Fallback 99**: rota no Apple Maps quando link 99 não existir.

### Riscos Conhecidos

- Sites podem bloquear requests ou não ter `og:image` → placeholder.
- URLs coladas podem ser inválidas → validação simples + feedback.
- Cache inconsistente → manter cache apenas para melhorar UX; nunca bloquear funcionalidade.

### Requisitos Especiais

- Performance:
  - não bloquear a UI durante fetch de OpenGraph
  - limitar concorrência de requests (ex.: no máximo 2–4 simultâneos)

### Conformidade com Padrões

- Skills a seguir:
  - `.cursor/skills/ios-development-skill/skill-ios.md` (SwiftUI + async/await + boas práticas de isolamento)
  - `.cursor/skills/design/skill-design.md` (hierarquia, espaçamento, touch targets, acessibilidade; cards com fundo sólido)
  - `.cursor/skills/skill-debugger/skill-crash-debugger.md` (quando depurar issues de rede/parsing/UI)

### Arquivos relevantes

- Modelos/Repos:
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Entities/Restaurant.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Repositories/RestaurantRepository.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`
- UI:
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/NearbyPlaceDetailView.swift`


