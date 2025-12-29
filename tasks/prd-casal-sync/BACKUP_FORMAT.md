# Formato do Backup: chooseThere_backup.json

## Versão: 1.0 (Schema Version 1)
## Data: 29/12/2025

---

## 📋 Visão Geral

O arquivo `chooseThere_backup.json` contém todos os dados da coleção do usuário:
- Lista de restaurantes (incluindo favoritos)
- Histórico de visitas e avaliações

O formato é versionado para permitir evolução futura sem quebrar compatibilidade.

---

## 📦 Estrutura do Arquivo

```json
{
  "schemaVersion": 1,
  "createdAt": "2025-12-29T10:00:00Z",
  "appVersion": "1.0.0",
  "restaurants": [
    {
      "id": "rest-001",
      "name": "Restaurante Exemplo",
      "category": "Japonês",
      "address": "Rua Exemplo, 123",
      "city": "São Paulo",
      "state": "SP",
      "tags": ["sushi", "japonês", "premium"],
      "notes": "Ótimo sushi, preço alto",
      "externalLink": "https://maps.apple.com/...",
      "lat": -23.5505,
      "lng": -46.6333,
      "isFavorite": true,
      "ratingAverage": 4.5,
      "ratingCount": 10,
      "ratingLastVisitedAt": "2025-12-20T19:00:00Z"
    }
  ],
  "visits": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "restaurantId": "rest-001",
      "dateVisited": "2025-12-20T19:00:00Z",
      "rating": 5,
      "tags": ["almoço", "trabalho"],
      "note": "Experiência excelente!",
      "isMatch": true,
      "wouldReturn": true
    }
  ]
}
```

---

## 🔑 Campos Principais

### Root Level

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `schemaVersion` | `Int` | ✅ Sim | Versão do schema (sempre `1` para V1) |
| `createdAt` | `ISO8601 Date` | ✅ Sim | Data/hora de criação do backup |
| `appVersion` | `String` | ❌ Não | Versão do app que gerou o backup |
| `restaurants` | `Array<Restaurant>` | ✅ Sim | Lista de restaurantes |
| `visits` | `Array<Visit>` | ✅ Sim | Lista de visitas/avaliações |

---

### Restaurant Object

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | `String` | ✅ Sim | ID único do restaurante |
| `name` | `String` | ✅ Sim | Nome do restaurante |
| `category` | `String` | ✅ Sim | Categoria (ex: "Japonês", "Italiano") |
| `address` | `String` | ✅ Sim | Endereço completo |
| `city` | `String` | ✅ Sim | Cidade |
| `state` | `String` | ✅ Sim | Estado (sigla: "SP", "RJ") |
| `tags` | `Array<String>` | ✅ Sim | Tags/palavras-chave (pode ser vazio) |
| `notes` | `String` | ✅ Sim | Notas do usuário (pode ser vazio) |
| `externalLink` | `String?` | ❌ Não | Link externo (Apple Maps, Google Maps, etc) |
| `lat` | `Double` | ✅ Sim | Latitude (entre -90 e 90) |
| `lng` | `Double` | ✅ Sim | Longitude (entre -180 e 180) |
| `isFavorite` | `Bool` | ✅ Sim | Se é favorito |
| `ratingAverage` | `Double?` | ❌ Não | Média de avaliações (0-5) |
| `ratingCount` | `Int?` | ❌ Não | Número de avaliações |
| `ratingLastVisitedAt` | `ISO8601 Date?` | ❌ Não | Data da última visita avaliada |

---

### Visit Object

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | `UUID` | ✅ Sim | ID único da visita |
| `restaurantId` | `String` | ✅ Sim | ID do restaurante (referência) |
| `dateVisited` | `ISO8601 Date` | ✅ Sim | Data/hora da visita |
| `rating` | `Int` | ✅ Sim | Avaliação (0-5) |
| `tags` | `Array<String>` | ✅ Sim | Tags da visita (pode ser vazio) |
| `note` | `String?` | ❌ Não | Nota específica da visita |
| `isMatch` | `Bool` | ✅ Sim | Se foi uma experiência positiva |
| `wouldReturn` | `Bool` | ✅ Sim | Se voltaria ao restaurante |

---

## ✅ Regras de Validação

### Schema Version
- Deve ser um número inteiro
- Versão 1 é a única suportada atualmente
- Versões incompatíveis geram erro claro

### Datas
- Formato ISO8601 obrigatório: `YYYY-MM-DDTHH:mm:ssZ`
- `createdAt` não pode estar no futuro (tolerância de 1 minuto)
- `dateVisited` não pode estar no futuro distante (tolerância de 1 dia)

### Coordenadas
- `lat` deve estar entre -90 e 90
- `lng` deve estar entre -180 e 180
- Valores fora desse intervalo geram erro

### Ratings
- Valores de `rating` devem estar entre 0 e 5
- Valores fora desse intervalo geram erro

### IDs
- `id` de restaurante não pode ser vazio (após trim)
- `id` de visita deve ser um UUID válido
- `restaurantId` em visitas deve referenciar um restaurante existente no backup (validação strict)

### Strings
- `name` de restaurante não pode ser vazio (após trim)
- Campos obrigatórios não podem ser `null`

---

## 🔄 Modos de Importação

### Substituir Tudo (Replace All)
**Comportamento**:
1. Apaga TODAS as visitas locais
2. Apaga TODOS os restaurantes locais
3. Insere todos os restaurantes do backup
4. Insere todas as visitas do backup

**Resultado**:
- Banco fica idêntico ao backup
- Dados locais não presentes no backup são perdidos
- ⚠️ **Ação destrutiva**: requer confirmação explícita

**Contadores retornados**:
- `importedRestaurants`: Total de restaurantes
- `importedVisits`: Total de visitas
- `updatedRestaurants`: 0
- `updatedVisits`: 0

---

### Mesclar por ID (Merge By ID)
**Comportamento**:
1. Para cada restaurante do backup:
   - Se ID existe localmente → **atualiza** campos
   - Se ID não existe → **insere** novo
2. Para cada visita do backup:
   - Se ID existe localmente → **atualiza** campos
   - Se ID não existe → **insere** nova
3. Dados locais não presentes no backup são **preservados**

**Resultado**:
- Dados do backup são aplicados (insert ou update)
- Dados locais adicionais são mantidos
- ✅ **Não destrutivo**: não apaga dados locais

**Contadores retornados**:
- `importedRestaurants`: Novos restaurantes adicionados
- `updatedRestaurants`: Restaurantes atualizados
- `importedVisits`: Novas visitas adicionadas
- `updatedVisits`: Visitas atualizadas

**Regras de Merge**:
- ID é a chave primária (imutável)
- Todos os campos são atualizados no merge
- Exceção: dados de Apple Maps resolution não são sobrescritos

---

## 🚫 O que NÃO está no Backup

Para manter o backup simples e portável, os seguintes dados **não são incluídos**:

- ❌ Configurações do app (cidade selecionada, raio, fonte de dados)
- ❌ Cache do Apple Maps (busca "Perto de mim")
- ❌ Dados de resolução de localização via Apple Maps (`applePlaceResolved*`)
- ❌ Pesos de preferências (Fase 3 - ainda não implementado)
- ❌ Histórico de repetições (Fase 3 - ainda não implementado)

---

## 📝 Exemplo Completo

```json
{
  "schemaVersion": 1,
  "createdAt": "2025-12-29T15:30:00Z",
  "appVersion": "1.0.0",
  "restaurants": [
    {
      "id": "sushi-place-sp",
      "name": "Sushi Place",
      "category": "Japonês",
      "address": "Av. Paulista, 1000",
      "city": "São Paulo",
      "state": "SP",
      "tags": ["sushi", "japonês", "premium"],
      "notes": "Melhor sushi da região",
      "externalLink": null,
      "lat": -23.5613,
      "lng": -46.6565,
      "isFavorite": true,
      "ratingAverage": 4.8,
      "ratingCount": 5,
      "ratingLastVisitedAt": "2025-12-28T20:00:00Z"
    },
    {
      "id": "pizza-rj-123",
      "name": "Pizzaria do João",
      "category": "Italiano",
      "address": "Rua das Pizzas, 456",
      "city": "Rio de Janeiro",
      "state": "RJ",
      "tags": ["pizza", "italiano"],
      "notes": "",
      "externalLink": "https://maps.apple.com/?address=...",
      "lat": -22.9068,
      "lng": -43.1729,
      "isFavorite": false,
      "ratingAverage": null,
      "ratingCount": null,
      "ratingLastVisitedAt": null
    }
  ],
  "visits": [
    {
      "id": "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d",
      "restaurantId": "sushi-place-sp",
      "dateVisited": "2025-12-28T20:00:00Z",
      "rating": 5,
      "tags": ["jantar", "aniversário"],
      "note": "Experiência incrível!",
      "isMatch": true,
      "wouldReturn": true
    },
    {
      "id": "f6e5d4c3-b2a1-4c5d-9e0f-1a2b3c4d5e6f",
      "restaurantId": "sushi-place-sp",
      "dateVisited": "2025-12-15T19:30:00Z",
      "rating": 4,
      "tags": ["almoço"],
      "note": null,
      "isMatch": true,
      "wouldReturn": true
    }
  ]
}
```

---

## 🔒 Privacidade e Segurança

### Dados Sensíveis
O backup contém:
- ✅ Nomes de restaurantes
- ✅ Endereços completos
- ✅ Avaliações pessoais
- ✅ Notas privadas

**⚠️ AVISO**: O arquivo deve ser compartilhado apenas com pessoas de confiança.

### Criptografia
- ❌ **Versão 1 não inclui criptografia**
- Arquivo é JSON em texto plano
- Considerar criptografia em versões futuras

### Recomendações
- Não compartilhe o backup publicamente
- Use canais seguros (AirDrop, mensagens criptografadas)
- Apague cópias antigas após importação bem-sucedida

---

## 🔮 Evolução Futura

### Schema Version 2 (Planejado)
Possíveis adições:
- Suporte a múltiplos idiomas
- Campos de preferências aprendidas (Fase 3)
- Histórico de lugares evitados
- Metadados de sincronização (última atualização por campo)

### Retrocompatibilidade
- App sempre suportará versões anteriores para leitura
- Exportação usa sempre a versão mais recente
- Importação valida e rejeita versões desconhecidas

---

## 📚 Referências

- **PRD**: `tasks/prd-casal-sync/prd.md`
- **Tech Spec**: `tasks/prd-casal-sync/techspec.md`
- **Código**:
  - Modelos: `Domain/Entities/BackupModels.swift`
  - Codec: `Domain/Services/BackupCodec.swift`
  - Export: `Application/BackupExportService.swift`
  - Import: `Application/BackupImportService.swift`
- **Testes**:
  - `ChooseThereTests/BackupCodecTests.swift`
  - `ChooseThereTests/BackupImportServiceTests.swift`

---

**Última atualização**: 29/12/2025  
**Versão do documento**: 1.0

