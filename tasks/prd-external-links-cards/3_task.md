# [3.0] Resolver de imagem via OpenGraph + cache + timeouts (M)

## Objetivo
- Implementar resolução de imagem do restaurante via `og:image` (OpenGraph) do site, com cache e timeouts para performance.

## Subtarefas
- [x] 3.1 Implementar parser de `og:image` com fixtures
- [x] 3.2 Implementar fetch HTML com `URLSession` + timeout + tratamento de erro
- [x] 3.3 Implementar cache em memória (e opcional URLCache) e integração com UI

## Critérios de Sucesso
- Cards exibem imagem quando `imageURL` manual existe ou quando `og:image` é encontrado.
- Falhas de rede/parsing não travam UI e caem em placeholder.

## Dependências
- 1.0 Modelos e persistência de links/imagem (para `imageURL`)

## Observações
- “Imagem do Google” fora de escopo; apenas OpenGraph do site.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/networking</domain>
<type>implementation</type>
<scope>middleware</scope>
<complexity>medium</complexity>
<dependencies>http_server</dependencies>
</task_context>

# Tarefa 3.0: Resolver de imagem via OpenGraph

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Para exibir imagens sem API paga, vamos usar OpenGraph do site do restaurante. O resolver deve ser best-effort: rápido, com timeout e cache, e nunca deve bloquear a UI.

<requirements>
- Resolver `og:image` a partir de HTML do site.
- Suportar URL relativa (resolver com baseURL).
- Cache em memória para evitar múltiplos fetches.
- Timeout (ex.: 2–4s) e tratamento de erros.
</requirements>

## Subtarefas

- [x] 3.1 Criar parser (`String` HTML -> `URL?`) com testes unitários e fixtures
- [x] 3.2 Criar resolver async com `URLSession` e timeout
- [x] 3.3 Integrar com `RestaurantCard` (ou view model) para exibir estados: loading / imagem / placeholder

## Detalhes de Implementação

Referenciar `techspec.md` (seção “Pontos de Integração: OpenGraph (HTML)”). Evitar dependências externas; usar parsing simples e robusto.

## Critérios de Sucesso

- Imagem aparece quando `og:image` existe.
- Erros de rede/parsing resultam em placeholder sem crash.
- Cache reduz requests repetidas ao rolar lista.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/RestaurantListView.swift`
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/PreferencesView.swift`

