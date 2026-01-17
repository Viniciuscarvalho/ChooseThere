# [16.0] Manual Testing & Bug Fixes (L)

## Objetivo
- Executar testes manuais end-to-end cobrindo todos os fluxos de usuário
- Testar em múltiplos devices (iPhone SE, iPhone 14, iPhone 15 Pro Max)
- Validar performance em device real
- Identificar e corrigir bugs encontrados
- Validar métricas de sucesso do PRD
- Preparar para release

## Subtarefas
- [ ] 16.1 Criar checklist de test cases baseado nas User Stories do PRD
- [ ] 16.2 Testar fluxo: primeira instalação + onboarding
- [ ] 16.3 Testar fluxo: usuário em São Paulo (ambas abas visíveis)
- [ ] 16.4 Testar fluxo: usuário fora de São Paulo (só "Perto de mim")
- [ ] 16.5 Testar fluxo: troca de cidade SP → outra → SP
- [ ] 16.6 Testar visualização de resultados (lista vertical, agrupamento)
- [ ] 16.7 Testar quick actions (TripAdvisor, iFood, Maps, etc)
- [ ] 16.8 Testar navegação para detalhes (ResultView, NearbyPlaceDetailView)
- [ ] 16.9 Testar estados de erro (sem permissão, sem network, sem resultados)
- [ ] 16.10 Testar em múltiplos devices (SE, 14, 15 Pro Max)
- [ ] 16.11 Profile performance em device real
- [ ] 16.12 Documentar bugs e priorizar
- [ ] 16.13 Corrigir bugs críticos e high priority
- [ ] 16.14 Revalidar após fixes
- [ ] 16.15 Obter sign-off de QA/PM

## Critérios de Sucesso
- Todos os fluxos de usuário funcionam conforme PRD
- Nenhum crash ou erro crítico
- Performance atende requisitos (renderização < 100ms, 60 FPS)
- UI é consistente em todos os tamanhos de tela
- Animações são suaves
- Accessibility funciona corretamente
- Bugs conhecidos são documentados e priorizados
- Aprovação final de stakeholders

## Dependências
- **Todas as tasks anteriores (1-15)** devem estar completas

## Observações
- Esta é a última task antes de release
- Foco em validação end-to-end, não unitária
- Usar devices reais sempre que possível (não só simulador)
- Documentar bugs em sistema de tracking (Jira, Linear, etc)
- Priorizar bugs: P0 (critical/blocker), P1 (high), P2 (medium), P3 (low)
- Não lançar com bugs P0 não resolvidos
- PRD define métricas de sucesso (linhas 19-34) - preparar para tracking

## status: pending

<task_context>
<domain>testing</domain>
<type>testing</type>
<scope>core_feature</scope>
<complexity>high</complexity>
<dependencies>all_previous_tasks</dependencies>
</task_context>

# Tarefa 16.0: Manual Testing & Bug Fixes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta é a task final de validação antes de release. Envolve testing manual sistemático de todos os fluxos, identificação de bugs, priorização, e correção. É crucial para garantir qualidade e evitar regressões em produção.

<requirements>
- Testar todos os User Stories do PRD (US1-US9)
- Validar todos os Functional Requirements (FR1-FR5)
- Testar em múltiplos devices e tamanhos de tela
- Validar performance em hardware real
- Documentar e corrigir bugs encontrados
- Obter aprovação final para release
</requirements>

## Subtarefas

### Fase 1: Preparação
- [ ] 16.1 Criar test plan baseado em PRD User Stories (US1-US9)
- [ ] 16.2 Preparar devices: iPhone SE, iPhone 14, iPhone 15 Pro Max
- [ ] 16.3 Preparar scenarios: São Paulo, Rio de Janeiro, localizações diferentes
- [ ] 16.4 Setup tracking de bugs (spreadsheet ou tool)

### Fase 2: Testes Funcionais
- [ ] 16.5 Test Case 1: Onboarding primeira vez (US5, FR5)
  - [ ] Abrir app pela primeira vez
  - [ ] Onboarding aparece
  - [ ] Conceder permissão → onboarding fecha, não aparece mais
  - [ ] Reinstalar, pular → onboarding fecha, flag setada
- [ ] 16.6 Test Case 2: Usuário em São Paulo (US1, US2, US3, FR1, FR2, FR3, FR4)
  - [ ] Abrir app em SP
  - [ ] Verificar ambas abas visíveis
  - [ ] Tap "Perto de mim" → mostrar preferências
  - [ ] Ajustar raio, escolher fonte
  - [ ] Tap "Sortear perto de mim" → resultados aparecem
  - [ ] Validar lista vertical com grupos
  - [ ] Validar badges de fonte em cards
  - [ ] Tap em badge → tooltip aparece
  - [ ] Tap em card → navega para detalhe
  - [ ] Tap em quick action → abre URL correta
- [ ] 16.7 Test Case 3: Usuário fora de SP (US4, FR1)
  - [ ] Mudar cidade para Rio de Janeiro
  - [ ] Verificar apenas "Perto de mim" visível
  - [ ] "Minha Lista" não aparece
  - [ ] Buscar nearby → resultados Apple Maps
  - [ ] Validar badges "Apple Maps"
- [ ] 16.8 Test Case 4: Troca de cidade (US6, US7, FR1)
  - [ ] Estar em SP com "Minha Lista" ativa
  - [ ] Mudar para Curitiba
  - [ ] Aba desaparece com fade
  - [ ] Modo muda automaticamente para "Perto de mim"
  - [ ] Voltar para SP
  - [ ] Aba reaparece com fade
  - [ ] Dados intactos
- [ ] 16.9 Test Case 5: Visualização de resultados (US8, US9, FR3)
  - [ ] Buscar com 15+ resultados
  - [ ] Validar agrupamento por distância
  - [ ] Validar headers com contagem
  - [ ] Validar ordenação dentro de grupos
  - [ ] Validar espaçamento e padding
  - [ ] Scroll suave em 60 FPS
- [ ] 16.10 Test Case 6: Estados especiais
  - [ ] Sem permissão de localização → card informativo
  - [ ] Sem resultados → empty state
  - [ ] Erro de network → error state
  - [ ] Loading → skeleton ou spinner

### Fase 3: Testes de UI/UX
- [ ] 16.11 Validar animações (FR3, PRD linhas 215-219)
  - [ ] Staggered animation em cards (delay 0.05s)
  - [ ] Fade in/out de aba (0.25s)
  - [ ] Spring animation em modo switch (response 0.3, damping 0.8)
  - [ ] 60 FPS consistente
- [ ] 16.12 Validar design (FR2, PRD linhas 207-230)
  - [ ] Cards têm layout consistente
  - [ ] Tipografia correta (17pt nome, 15pt distância, etc)
  - [ ] Cores corretas (badges, text, backgrounds)
  - [ ] Spacing consistente (12pt entre cards, 16pt padding)

### Fase 4: Testes em Múltiplos Devices
- [ ] 16.13 iPhone SE (2nd gen) - tela pequena
  - [ ] Layout não quebra
  - [ ] Textos legíveis
  - [ ] Botões clicáveis
  - [ ] Performance adequada (60 FPS)
- [ ] 16.14 iPhone 14 - tela média
  - [ ] Layout balanceado
  - [ ] Conteúdo bem distribuído
- [ ] 16.15 iPhone 15 Pro Max - tela grande
  - [ ] Aproveita espaço extra
  - [ ] Não há gaps estranhos

### Fase 5: Testes de Performance
- [ ] 16.16 Medir renderização de lista (PRD: < 100ms)
  - [ ] Usar Time Profiler
  - [ ] Medir desde tap "Sortear" até cards visíveis
  - [ ] Validar < 100ms
- [ ] 16.17 Medir FPS durante animações (PRD: 60 FPS)
  - [ ] Usar Core Animation tool
  - [ ] Scroll + animation simultâneos
  - [ ] Validar 60 FPS consistente
- [ ] 16.18 Medir tempo de busca (PRD: < 2s em 4G)
  - [ ] Simular 4G network em device
  - [ ] Medir desde tap até resultados
  - [ ] Validar < 2s

### Fase 6: Testes de Acessibilidade
- [ ] 16.19 VoiceOver (AR1-AR7)
  - [ ] Navegação lógica em todos os fluxos
  - [ ] Labels e hints corretos
  - [ ] Nenhum elemento importante ignorado
- [ ] 16.20 Dynamic Type
  - [ ] Testar em sizes grandes (XXXL)
  - [ ] Layout se adapta
  - [ ] Texto não corta
- [ ] 16.21 Dark Mode
  - [ ] Cores corretas
  - [ ] Contraste adequado

### Fase 7: Bug Fixing
- [ ] 16.22 Documentar bugs encontrados
  - [ ] Título descritivo
  - [ ] Steps to reproduce
  - [ ] Expected vs actual behavior
  - [ ] Screenshots/videos
  - [ ] Prioridade (P0-P3)
- [ ] 16.23 Corrigir bugs P0 (critical/blocker)
- [ ] 16.24 Corrigir bugs P1 (high priority)
- [ ] 16.25 Avaliar bugs P2/P3 (medium/low) para post-release
- [ ] 16.26 Revalidar após cada fix

### Fase 8: Sign-off
- [ ] 16.27 Demo para Product Owner
- [ ] 16.28 Demo para stakeholders
- [ ] 16.29 Obter aprovação final
- [ ] 16.30 Preparar release notes

## Critérios de Sucesso

### Functional
- ✓ Todos os User Stories (US1-US9) validados
- ✓ Todos os Functional Requirements (FR1-FR5) implementados
- ✓ Nenhum crash durante testing
- ✓ Todos os fluxos principais funcionam end-to-end

### Performance
- ✓ Renderização de lista < 100ms (medido)
- ✓ Animações mantêm 60 FPS (medido)
- ✓ Busca completa < 2s em 4G (medido)

### UI/UX
- ✓ Layout consistente em todos os devices
- ✓ Animações suaves e naturais
- ✓ Design segue especificações do PRD

### Accessibility
- ✓ VoiceOver funciona em todos os fluxos
- ✓ Dynamic Type suportado
- ✓ Contraste de cores > 4.5:1

### Quality
- ✓ Zero bugs P0 (critical) não resolvidos
- ✓ < 3 bugs P1 (high) não resolvidos
- ✓ Bugs P2/P3 documentados para backlog
- ✓ Aprovação final de PM/PO

## Test Plan Template

```markdown
# Test Case: [Nome]

**ID**: TC-[número]
**User Story**: US[X]
**Functional Requirement**: FR[X]
**Priority**: P[0-3]

## Preconditions
- [Estado inicial necessário]

## Steps
1. [Ação]
2. [Ação]
3. [Ação]

## Expected Result
- [Comportamento esperado]

## Actual Result
- [O que aconteceu - preencher durante teste]

## Pass/Fail
- [ ] Pass
- [ ] Fail

## Notes
- [Observações, bugs encontrados, etc]
```

## Bug Report Template

```markdown
# Bug: [Título descritivo]

**ID**: BUG-[número]
**Priority**: P[0-3]
**Severity**: Critical/High/Medium/Low
**Device**: iPhone [model]
**iOS Version**: [version]

## Steps to Reproduce
1. [Passo]
2. [Passo]
3. [Passo]

## Expected Behavior
[O que deveria acontecer]

## Actual Behavior
[O que aconteceu]

## Screenshots/Videos
[Anexos]

## Additional Context
[Qualquer informação relevante]
```

## Arquivos relevantes
- Referência: `prd.md` (todas as seções - User Stories, FRs, métricas)
- Referência: `techspec.md` (toda a implementação)
- Referência: Todos os arquivos implementados nas tasks 1-15
- Tools: Xcode Instruments (Time Profiler, Core Animation), Network Link Conditioner
