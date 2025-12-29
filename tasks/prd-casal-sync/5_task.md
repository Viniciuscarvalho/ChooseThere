# [5.0] Persistência SwiftData: upsert de Restaurant/Visit + integridade (L)

## Objetivo
- Implementar `BackupImportService` para aplicar `BackupV1` no SwiftData com as duas estratégias (replace e merge), mantendo integridade entre `RestaurantModel` e `VisitModel`.

## Subtarefas
- [ ] 5.1 Implementar escrita no SwiftData: importar restaurants e depois visits (ordem garantida)
- [ ] 5.2 Implementar modo “Substituir tudo” (reset controlado + importar)
- [ ] 5.3 Implementar modo “Mesclar por ID” (upsert + dedupe) e contabilizar resultado (imported/updated)

## Critérios de Sucesso
- Importação não cria visitas “órfãs” (visit com restaurantId inexistente).
- Replace limpa dados do usuário e restaura o estado do backup.
- Merge aplica upsert por ID sem apagar dados não presentes no arquivo.

## Dependências
- 1.0 Contrato do backup (schema v1) + codec/validação
- 4.0 Importação: Substituir tudo vs Mesclar por ID

## Observações
- Implementar de forma determinística e testável (permitir repositórios fakes em testes).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded
# Nota: Implementado como parte da Task 4.0 (BackupImportService)

<task_context>
<domain>ios/app/persistence</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 5.0: Persistência SwiftData: upsert de Restaurant/Visit + integridade

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Aqui acontece a aplicação real do backup no banco local. Precisamos importar restaurantes primeiro (para garantir referências) e depois as visitas. O resultado deve reportar contagens de inseridos/atualizados e entradas ignoradas.

<requirements>
- Aplicar backup no SwiftData com integridade
- Suportar `replaceAll` e `mergeByID`
- Reportar resultado (`BackupImportResult`)
</requirements>

## Subtarefas

- [ ] 5.1 Implementar import de restaurantes (upsert)
- [ ] 5.2 Implementar import de visitas (upsert + validação de referência)
- [ ] 5.3 Implementar modo replaceAll (reset) e mergeByID (upsert)

## Detalhes de Implementação

- Ver `techspec.md`: **Pontos de Integração** (SwiftData) e **Modelos de Dados** (BackupImportResult).

## Critérios de Sucesso

- Não existem visitas órfãs após importação.
- Merge não apaga dados locais não presentes no arquivo.

## Arquivos relevantes
- `tasks/prd-casal-sync/techspec.md`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/RestaurantModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Models/VisitModel.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataRestaurantRepository.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Repositories/SwiftDataVisitRepository.swift`

