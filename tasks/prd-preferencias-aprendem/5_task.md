# [5.0] Configurações: toggle, reset e limite N (M)

## Objetivo
- Expor em Configurações controles para o usuário: ligar/desligar aprendizado, resetar pesos e configurar o limite N para evitar repetidos.

## Subtarefas
- [ ] 5.1 Adicionar “Preferências que aprendem” em `SettingsView` (toggle e descrição curta)
- [ ] 5.2 Implementar “Resetar aprendizado” com confirmação (ação destrutiva)
- [ ] 5.3 Adicionar ajuste do limite N (ou valor fixo MVP com UI simples)

## Critérios de Sucesso
- Usuário consegue desativar aprendizado e resetar com confirmação.
- Limite N é persistido e aplicado no sorteio.

## Dependências
- 1.0 Modelo + persistência de preferências aprendidas
- 4.0 Evitar repetidos (últimos N)

## Observações
- Seguir HIG e manter consistência visual com Settings atual.

## markdown

## status: completed # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>ios/app/settings</domain>
<type>integration</type>
<scope>configuration</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 5.0: Configurações: toggle, reset e limite N

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

O usuário precisa controlar o aprendizado e entender o efeito dele. Também precisa de um reset para quando preferências mudarem.

<requirements>
- Toggle para habilitar/desabilitar aprendizado
- Resetar pesos com confirmação
- Configurar limite N de “evitar repetidos”
</requirements>

## Subtarefas

- [ ] 5.1 UI do toggle e texto explicativo
- [ ] 5.2 Reset com confirmação
- [ ] 5.3 Ajuste do limite N e persistência

## Detalhes de Implementação

- Ver `techspec.md`: **Parâmetros (UserDefaults)** e **UI**.

## Critérios de Sucesso

- Preferências respeitam o toggle e reset funciona.

## Arquivos relevantes
- `ChooseThere/ChooseThere/ChooseThere/ChooseThere/Presentation/Views/SettingsView.swift`
- `tasks/prd-preferencias-aprendem/techspec.md`

