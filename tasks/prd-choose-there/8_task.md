# [8.0] Resultado + mapa + ações (M)

## Objetivo
- Implementar a tela de resultado com mapa (pin) e ações: abrir no Maps, favoritar, sortear outro.

## Subtarefas
- [ ] 8.1 Exibir card do restaurante (nome, categoria, preço, distância/bairro)
- [ ] 8.2 Exibir mapa com pin (Tomato; Mint para favorito)
- [ ] 8.3 Implementar “Abrir no Maps” (Apple Maps; Google Maps opcional)
- [ ] 8.4 Implementar “Sortear outro” mantendo o contexto

## Critérios de Sucesso
- Resultado é acionável: abrir rota e favoritar
- Pin reflete estado (favorito)

## Dependências
- 5.0 Router e navegação
- 4.0 Repositórios + regras de sorteio

## Observações
- Se localização do usuário estiver indisponível, esconder distância e ignorar raio.

## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>engine/ui/result</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>external_apis</dependencies>
</task_context>

# Tarefa 8.0: Resultado + mapa + ações

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral
Apresentar o restaurante escolhido com mapa e ações práticas, aplicando identidade visual e suportando degradação sem permissão de localização.

<requirements>
- Mapa com pin e ações de rota
- Favorito persistido
- DesignSystem aplicado (pin Tomato/Mint)
</requirements>

## Subtarefas

- [ ] 8.1 Card do restaurante
- [ ] 8.2 MapKit + pin
- [ ] 8.3 Abrir rota (Apple/Google)
- [ ] 8.4 Favoritar + sortear outro

## Detalhes de Implementação
- Referência: `prd.md` (4.x) e `techspec.md` (Mapas, Localização)

## Critérios de Sucesso

- Botões e pin refletem estados (erro/sucesso/favorito)

## Arquivos relevantes
- `tasks/prd-choose-there/techspec.md`



