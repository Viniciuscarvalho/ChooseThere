# ChooseThere 🍽️

Um app iOS para ajudar você a escolher onde comer, usando uma roleta de restaurantes personalizada.

## 📱 Features

### ✅ Implementado

#### 1. Seleção de Cidade e Configurações
- Onboarding com seleção de cidade na primeira vez
- Suporte a múltiplas cidades no Brasil
- Modo "Qualquer lugar (Perto de mim)" para buscar restaurantes próximos
- Tela de Configurações para ajustar preferências

#### 2. Perto de Mim (Any City Mode)
- **Duas fontes de dados**:
  - Base local (Restaurants.json)
  - Apple Maps (busca em tempo real)
- Filtros configuráveis:
  - Raio de busca (1-10 km)
  - Categoria de restaurante
- Cache inteligente de resultados do Apple Maps (30 minutos TTL)
- Integração com permissões de localização

#### 3. Coleção Compartilhada do Casal
- **Export**: Gera arquivo `chooseThere_backup.json` com toda a coleção
- **Import**: Duas estratégias disponíveis:
  - **Substituir tudo**: Limpa e importa tudo do backup (destrutivo)
  - **Mesclar por ID**: Adiciona novos e atualiza existentes (não destrutivo)
- Validação robusta do formato do arquivo
- Preview antes de importar
- Sincronização via AirDrop, WhatsApp ou qualquer canal de compartilhamento
- Schema versionado para compatibilidade futura

#### 4. Roleta de Restaurantes
- Sorteio aleatório de restaurantes
- Filtros por categoria, tags e favoritos
- Histórico de visitas e avaliações (0-5 estrelas)
- Sistema de match: "voltaria?" e "deu match?"

### 🚧 Planejado (Fase 3)

#### Preferências que Aprendem
- Ajuste automático de pesos por categoria/tags com base em avaliações
- Aumento de probabilidade para lugares "match"
- Sistema de anti-repetição (evitar últimos 10 lugares)
- Sem ML complexo: regras simples e eficazes

## 🗂️ Estrutura do Projeto

```
ChooseThere/
├── Application/         # AppRouter, RootView, Settings
├── Data/
│   ├── Models/         # RestaurantModel, VisitModel (SwiftData)
│   ├── Repositories/   # SwiftDataRestaurantRepository
│   └── Services/       # Seeder, PlaceResolver
├── Domain/
│   ├── Entities/       # Restaurant, Visit, BackupV1
│   ├── Repositories/   # Protocols
│   └── Services/       # Business logic (Randomizer, Filters, Backup)
├── Presentation/
│   ├── Components/     # UI reusáveis
│   ├── ViewModels/     # Lógica de apresentação
│   └── Views/          # SwiftUI views
└── Resources/
    └── Restaurants.json # Base de dados inicial
```

## 🧪 Testes

O projeto possui cobertura de testes unitários para:
- ✅ `CityCatalog` (extração e sorting de cidades)
- ✅ `AppSettingsStorage` (persistência de preferências)
- ✅ `NearbyLocalFilterService` (filtragem por proximidade)
- ✅ `NearbyCacheStore` (cache do Apple Maps)
- ✅ `NearbyModeViewModel` (lógica de busca)
- ✅ `BackupCodec` (encode/decode/validação de backup)
- ✅ `BackupImportService` (estratégias de importação)

**Total**: 100+ testes unitários

## 🔧 Tecnologias

- **SwiftUI**: Interface declarativa
- **SwiftData**: Persistência local
- **CoreLocation**: Geolocalização
- **MapKit**: Busca de lugares via Apple Maps
- **Combine**: Reactive programming
- **XCTest**: Testes unitários

## 📚 Documentação

### Para Desenvolvedores
- [Tech Specs](./tasks/) - Especificações técnicas detalhadas por feature
- [Code Standards](./.cursor/rules/code-standards.md) - Kodeco Swift Style Guide

### Para Usuários
- [Formato do Backup](./tasks/prd-casal-sync/BACKUP_FORMAT.md) - Estrutura do JSON de backup
- [QA Checklist](./tasks/prd-casal-sync/QA_CHECKLIST.md) - Cenários de teste manual

## 🚀 Como Rodar

1. Clone o repositório
2. Abra `ChooseThere.xcodeproj` no Xcode 15+
3. Selecione um simulador iOS 17+ ou dispositivo
4. Build e Run (⌘R)

## 📝 Notas de Versão

### v1.0.0 (Atual)
- ✅ Seleção de cidade e configurações
- ✅ Modo "Perto de mim" com Apple Maps
- ✅ Export/Import de backup
- ✅ Roleta de restaurantes com filtros

### Próximo (v1.1.0)
- 🚧 Preferências que aprendem
- 🚧 Anti-repetição automático
- 🚧 Ajuste de pesos por categoria

## 👥 Contribuindo

Este é um projeto pessoal, mas sugestões e feedback são bem-vindos!

## 📄 Licença

Copyright © 2025 Vinicius Carvalho. Todos os direitos reservados.
