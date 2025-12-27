# [3.0] Configurações: alterar cidade e preferências (M)

## Objetivo
- Criar uma área de Configurações para alterar a cidade selecionada e preferências do modo “Perto de mim”, incluindo ações de cache (limpar/atualizar).

## Subtarefas
- [ ] 3.1 Criar `SettingsView` (SwiftUI) com seções agrupadas
- [ ] 3.2 Reutilizar `CitySelectionView` para trocar cidade
- [ ] 3.3 Expor preferências: fonte default (Minha base/Apple Maps), raio default (1–10km)
- [ ] 3.4 Ação “Limpar cache do Perto de mim”

## Critérios de Sucesso
- Usuário consegue trocar cidade e ver a mudança refletida nos modos dependentes.
- Preferências persistem após relaunch.

## Dependências
- 1.0 Persistência de cidade e preferências globais
- 2.0 Onboarding: seleção de cidade no primeiro uso

## Observações
- Seguir padrões HIG (lista agrupada, valores à direita, navegação clara).

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/settings</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 3.0: Configurações: alterar cidade e preferências

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar uma tela de Configurações para que o usuário consiga alterar a cidade selecionada e preferências do “Perto de mim” sem precisar reinstalar/resetar o app. Também inclui ações básicas de cache (limpar).

<requirements>
- Configurações acessíveis no app (ex.: nova tab ou entrada em tela existente)
- Alterar cidade (incluindo Any City) e persistir via `AppSettingsStorage`
- Ajustar raio e fonte default do “Perto de mim”
- Limpar cache do Apple Maps
</requirements>

## Subtarefas

- [x] 3.1 Implementar `SettingsView` com seções: Cidade, Perto de mim, Cache
- [x] 3.2 Integrar `CitySelectionView` (push/navigation)
- [x] 3.3 Persistir mudanças via `AppSettingsStorage`
- [x] 3.4 Implementar ação "Limpar cache" chamando `NearbyCacheStore.clear()`

## Detalhes de Implementação

- Tech Spec: **Modelos de Dados** (UserDefaults) e **Pontos de Integração**
- UI: seguir recomendações HIG (ver skill de design)

## Critérios de Sucesso

- Troca de cidade funciona e é refletida imediatamente ao voltar para o fluxo principal
- Preferências do “Perto de mim” persistem
- “Limpar cache” remove entradas e força nova busca quando necessário

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/MainTabView.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`
- (novo) `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Data/Services/NearbyCacheStore.swift`

