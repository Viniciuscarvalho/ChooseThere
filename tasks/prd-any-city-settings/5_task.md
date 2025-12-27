# [5.0] “Perto de mim” (fonte: Minha base) — filtro por distância (M)

## Objetivo
- Implementar a busca “Perto de mim” usando apenas a base local (SwiftData/seed JSON), filtrando por distância com base na localização atual do usuário.

## Subtarefas
- [ ] 5.1 Implementar `NearbyLocalFilterService` (filtra restaurantes por raio e categoria)
- [ ] 5.2 Integrar obtenção de localização (CoreLocation) no fluxo do modo “Perto de mim”
- [ ] 5.3 Alimentar a roleta com resultados filtrados (fluxo local)
- [ ] 5.4 Testes unitários para lógica de filtro por distância

## Critérios de Sucesso
- Com permissão concedida, o modo retorna restaurantes dentro do raio.
- Sem permissão, o app mostra estado apropriado e não quebra.

## Dependências
- 1.0 Persistência de cidade e preferências globais
- 4.0 UI do modo “Minha Lista | Perto de mim”

## Observações
- Esta fonte deve funcionar offline.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/nearby</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 5.0: “Perto de mim” (fonte: Minha base) — filtro por distância

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar a opção de “Perto de mim” usando a base local, aplicando filtros por distância e categoria, e entregando uma lista para o sorteio/roleta.

<requirements>
- Calcular distância (CoreLocation) e filtrar por raio (1–10km)
- Filtrar por categoria/tags (mínimo: categoria)
- UI para lidar com “sem permissão” e “sem resultados”
- Testes unitários para filtro de distância
</requirements>

## Subtarefas

- [x] 5.1 Criar `NearbyLocalFilterService` e testes
- [x] 5.2 Integrar CoreLocation no modo "Perto de mim" (solicitar permissão quando necessário)
- [x] 5.3 Conectar resultados ao fluxo de sorteio (sem depender de Apple Maps)

## Detalhes de Implementação

- Tech Spec: **Pontos de Integração** (CoreLocation) e **Abordagem de Testes**
- Referências existentes:
  - `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/ViewModels/PreferencesViewModel.swift` (já importa CoreLocation e possui `radiusKm`)

## Critérios de Sucesso

- Retorna uma lista coerente de restaurantes dentro do raio
- Sem permissão: estado de UI claro e sem crash
- Testes unitários cobrindo casos básicos

## Arquivos relevantes
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/NearbyLocalFilterService.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`

