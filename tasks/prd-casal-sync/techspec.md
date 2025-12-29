# Especificação Técnica: Coleção compartilhada do casal (Export/Import)

## Resumo Executivo

Esta entrega implementa sincronização simples entre dois aparelhos via **Export/Import** de um arquivo `chooseThere_backup.json`. O arquivo é versionado (ex.: `schemaVersion = 1`) e contém a **lista inteira de restaurantes do usuário** (incluindo favoritos) e o **histórico de visitas/avaliações**. A importação oferece duas estratégias: **Substituir tudo** (reset + importar) e **Mesclar por ID** (upsert sem apagar o restante).

O fluxo é implementado em SwiftUI, com integração a componentes do sistema para compartilhamento e importação de arquivos (Share Sheet / Files). A aplicação das mudanças na base é feita via SwiftData (`RestaurantModel`, `VisitModel`) com serviços dedicados para encode/decode, validação e importação.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- `BackupV1` (novo, Domain ou Data): modelo Codable do arquivo de backup.
- `BackupCodec` (novo, Domain/Services): encode/decode + validação de versionamento.
- `BackupExportService` (novo, Application ou Presentation support):
  - constrói o `BackupV1` a partir dos repositórios
  - gera `Data` JSON para compartilhar
- `BackupImportService` (novo, Application/Services):
  - valida e aplica import (Substituir vs Mesclar)
  - faz upsert em `RestaurantModel`/`VisitModel`
- UI:
  - `SettingsView` (atualizar): seção “Coleção do casal” com Export/Import
  - `BackupImportPreviewView` (novo): mostra contagens, versão, data e aviso de privacidade

Fluxo de dados (alto nível):
1. Export: SwiftData → `BackupV1` → JSON → Share Sheet
2. Import: File → JSON → validação → preview → estratégia → SwiftData write

## Design de Implementação

### Interfaces Principais

```swift
enum BackupImportMode {
  case replaceAll
  case mergeByID
}

protocol BackupCoding {
  func encodeBackup() throws -> Data
  func decodeBackup(from data: Data) throws -> BackupV1
  func validate(_ backup: BackupV1) throws
}

protocol BackupImporting {
  func apply(_ backup: BackupV1, mode: BackupImportMode) async throws -> BackupImportResult
}
```

### Modelos de Dados

Arquivo: `chooseThere_backup.json`

Estrutura sugerida (V1):
- `schemaVersion: Int` (ex.: 1)
- `createdAt: Date`
- `appVersion: String?`
- `restaurants: [BackupRestaurant]`
- `visits: [BackupVisit]`

`BackupRestaurant` (subset do `RestaurantModel`):
- `id: String`
- `name: String`
- `category: String`
- `address: String`
- `city: String`
- `state: String`
- `tags: [String]`
- `notes: String`
- `externalLink: String?`
- `lat: Double`
- `lng: Double`
- `isFavorite: Bool`
- (opcional) `applePlaceResolved*` e snapshot de rating (se fizer sentido manter)

`BackupVisit` (espelha `VisitModel`):
- `id: UUID`
- `restaurantId: String`
- `dateVisited: Date`
- `rating: Int`
- `tags: [String]`
- `note: String?`
- `isMatch: Bool`
- `wouldReturn: Bool`

Resultado da importação:
- `importedRestaurants: Int`
- `updatedRestaurants: Int`
- `importedVisits: Int`
- `updatedVisits: Int`
- `skippedInvalidEntries: Int`

### Endpoints de API

Não aplicável.

## Pontos de Integração

- SwiftUI (compartilhamento/importação de arquivos):
  - `ShareLink` para Share Sheet quando possível
  - `fileExporter`/`fileImporter` para export/import via Files quando aplicável
  - Referência: Apple SwiftUI docs (Context7) para `ShareLink`, `Transferable`, `fileExporter`
- SwiftData:
  - Repositórios existentes:
    - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`
    - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataVisitRepository.swift`
  - Modelos:
    - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
    - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`

Tratamento de erros:
- Arquivo inválido / JSON inválido → erro com mensagem “Backup inválido”.
- `schemaVersion` desconhecida → erro com mensagem “Backup não compatível”.
- Inconsistência (visit aponta para restaurantId inexistente) →:
  - preferível: importar restaurants primeiro e validar referências
  - se ainda assim faltar: marcar como “skippedInvalidEntries” e avisar no resumo.

## Abordagem de Testes

### Testes Unitários

- `BackupCodecTests`:
  - encode/decode roundtrip
  - validação de versionamento
  - detecção de payload inválido
- `BackupImportServiceTests` (com repositórios fakes/in-memory):
  - modo replaceAll
  - modo mergeByID
  - conflitos: “última escrita vence” (se definido)
  - visitas duplicadas por `id`
- `SettingsView` (opcional): testes de snapshot/preview (se houver infraestrutura), caso contrário testes manuais.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Definir `BackupV1` + `BackupCodec` (base do contrato).
2. Implementar export (montar payload a partir de SwiftData).
3. Implementar import (decode + validação + preview).
4. Implementar `BackupImportService` com as duas estratégias.
5. Integrar no `SettingsView` com UX de confirmação.
6. Adicionar testes unitários.

### Dependências Técnicas

- SwiftUI para Share Sheet / file dialogs (iOS).
- SwiftData para persistência local.

## Considerações Técnicas

### Decisões Principais

- Sem login/back-end: sincronização por arquivo.
- Importação oferece escolha (Substituir vs Mesclar).
- Backup inclui restaurantes + visitas para garantir consistência.

### Riscos Conhecidos

- Perda de dados acidental se o usuário escolher “Substituir tudo” sem entender → mitigação: confirmação + copy clara.
- Conflitos de merge podem gerar comportamento inesperado → mitigação: regras simples e transparentes + preview.
- Arquivos compartilhados podem vazar dados pessoais → mitigação: aviso explícito antes de exportar.

### Requisitos Especiais

- Performance: import pode ser grande; evitar travar UI usando operações assíncronas e, se necessário, batch writes.
- Privacidade: alertar que o arquivo contém dados (visitas, notas, avaliações).

### Conformidade com Padrões

- `/.cursor/rules/code-standards.md` (Kodeco Swift Style Guide)

### Arquivos relevantes

- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataVisitRepository.swift`


