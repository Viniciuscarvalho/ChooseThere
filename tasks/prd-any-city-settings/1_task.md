# [1.0] Persistência de cidade e preferências globais (S/M)

## Objetivo
- Criar a base de persistência para guardar a cidade selecionada e preferências do modo “Perto de mim” (raio/fonte), para ser usada no onboarding, em Configurações e nas buscas.

## Subtarefas
- [ ] 1.1 Definir chaves e modelo de settings (`selectedCityKey`, `nearbyRadiusKm`, `nearbySource`)
- [ ] 1.2 Implementar `AppSettingsStorage` (UserDefaults) e API de leitura/escrita
- [ ] 1.3 Implementar `CityCatalog` para listar cidades únicas a partir do seed local
- [ ] 1.4 Adicionar testes unitários para `CityCatalog` e `AppSettingsStorage` (mínimo: encode/decode)

## Critérios de Sucesso
- Preferências persistem entre relaunch do app.
- A lista de cidades é derivada do seed local e estável/ordenada.
- Any City é representado de forma consistente (ex.: `selectedCityKey == nil`).

## Dependências
- PRD/Tech Spec desta pasta.

## Observações
- Manter consistência com `OnboardingStorage` (que já usa `UserDefaults`).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/settings</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>low</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Persistência de cidade e preferências globais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa cria o “single source of truth” para cidade selecionada e preferências do modo “Perto de mim”. Ela habilita o onboarding e Configurações a lerem/escreverem os mesmos valores, sem duplicação.

<requirements>
- Persistir cidade selecionada e preferências do “Perto de mim” via `UserDefaults`
- Derivar lista de cidades únicas a partir do seed local (base atual)
- Incluir opção “Any City” (representada como `nil`/ausência de chave)
- Cobrir com testes unitários básicos
</requirements>

## Subtarefas

- [x] 1.1 Implementar `AppSettingsStorage` (get/set + defaults)
- [x] 1.2 Implementar `CityCatalog` (cidades únicas + ordenação + Any City)
- [x] 1.3 Criar testes unitários para `CityCatalog` e encode/decode de settings

## Detalhes de Implementação

- Tech Spec: seção **Modelos de Dados** (UserDefaults) e **Abordagem de Testes**
- Referências existentes: `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/OnboardingStorage.swift`

## Critérios de Sucesso

- Settings podem ser lidos/escritos sem crash e com defaults coerentes
- Lista de cidades: sem duplicatas, ordenada, e com `Any City`
- Testes unitários passando

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/OnboardingStorage.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Application/AppSettingsStorage.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Domain/Services/CityCatalog.swift`

