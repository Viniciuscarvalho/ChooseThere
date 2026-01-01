# [1.0] Fundação do projeto (S)

## Objetivo
- Criar a base do app em camadas (Domain/Data/Presentation + Composition Root), estabelecer o DesignSystem (cores) e preparar o terreno para Router/DI sem acoplamento ao scaffold do Xcode.

## Subtarefas
- [ ] 1.1 Criar estrutura de pastas (Domain/Data/Presentation/Application) no target iOS
- [ ] 1.2 Implementar DesignSystem (paleta: Mango/Tomato/Mint/Porcelain/etc.) para uso em SwiftUI
- [ ] 1.3 Criar esqueleto do Router (sem `NavigationStack`) e uma RootView que renderiza telas por rota
- [ ] 1.4 Preparar Composition Root para DI (Swinject será integrado na tarefa de DI/config)

## Critérios de Sucesso
- Estrutura em camadas criada e referenciada no projeto
- Cores do tema disponíveis via API simples (`AppColors.*`) e aplicáveis em botões/cards/texto
- App abre em uma root view controlada por Router (sem `NavigationStack`)

## Dependências
- PRD e Tech Spec presentes na pasta (`prd.md`, `techspec.md`)

## Observações
- Identidade visual (light mode) deve ser aplicada desde o início: CTA Mango, erro Tomato, sucesso Mint, background Porcelain.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/infra/foundation</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 1.0: Fundação do projeto

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Estabelecer a fundação arquitetural e visual do projeto, criando camadas, um Router inicial (sem `NavigationStack`) e um DesignSystem consistente para as telas da V1.

<requirements>
- Manter arquitetura por camadas conforme `techspec.md`
- Não usar `NavigationStack`
- Disponibilizar paleta de cores do app para uso na UI
</requirements>

## Subtarefas

- [ ] 1.1 Criar diretórios e arquivos base das camadas
- [ ] 1.2 Implementar `AppColors` e helpers de cor (hex) para SwiftUI
- [ ] 1.3 Criar `AppRouter` (ObservableObject) e `RootView` com switch de rotas

## Detalhes de Implementação
- Referência: `techspec.md` (Arquitetura do Sistema, Decisões Principais, Conformidade com Padrões)

## Critérios de Sucesso

- App compila e inicia exibindo uma tela placeholder controlada por Router
- Cores do DesignSystem aplicadas em ao menos 1 botão/label demonstrativo
- Código alinhado com `.cursor/rules/code-standards.md`

## Arquivos relevantes
- `tasks/prd-choose-there/prd.md`
- `tasks/prd-choose-there/techspec.md`
- `.cursor/rules/code-standards.md`
- `ChooseThere/ChooseThere/ChooseThereApp.swift`
- `ChooseThere/ChooseThere/ContentView.swift`







