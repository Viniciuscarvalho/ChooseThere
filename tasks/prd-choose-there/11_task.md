# [11.0] Testes + acessibilidade + polimento (M)

## Objetivo
- Consolidar qualidade: testes unitários (Domain/Data/VM), acessibilidade (Dynamic Type/VoiceOver), estados vazios e polimento visual com o DesignSystem.

## Subtarefas
- [ ] 11.1 Testes unitários do Randomizer e filtros (Domain)
- [ ] 11.2 Testes do seed e repositórios (Data) com SwiftData in-memory
- [ ] 11.3 Ajustes de acessibilidade (labels, Dynamic Type, targets)
- [ ] 11.4 Estados vazios e mensagens (sem resultados, sem histórico)
- [ ] 11.5 Polimento visual (cards, bordas Mist, textos Ink/Slate)

## Critérios de Sucesso
- Suite mínima de testes cobrindo caminhos críticos
- Acessibilidade básica validada
- UI consistente com paleta e sem inconsistências gritantes

## Dependências
- 1.0–10.0 concluídas (ou, no mínimo, 4.0/6.0/8.0/10.0)

## Observações
- Preferir testes de Domain por serem mais estáveis e rápidos.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/quality/polish</domain>
<type>testing</type>
<scope>performance</scope>
<complexity>medium</complexity>
<dependencies>database</dependencies>
</task_context>

# Tarefa 11.0: Testes + acessibilidade + polimento

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Garantir qualidade e consistência do app na V1, cobrindo regras de sorteio, persistência, e refinando a UI/UX com foco em acessibilidade.

<requirements>
- Testes unitários para regras críticas
- Acessibilidade: VoiceOver e Dynamic Type
- DesignSystem aplicado de forma consistente
</requirements>

## Subtarefas

- [ ] 11.1 Testes (Domain/Data)
- [ ] 11.2 Acessibilidade
- [ ] 11.3 Polimento e estados vazios

## Detalhes de Implementação
- Referência: `techspec.md` (Abordagem de Testes, Conformidade com Padrões)

## Critérios de Sucesso

- Cobertura mínima dos cenários críticos descritos na spec

## Arquivos relevantes
- `tasks/prd-choose-there/techspec.md`
- `.cursor/rules/code-standards.md`


