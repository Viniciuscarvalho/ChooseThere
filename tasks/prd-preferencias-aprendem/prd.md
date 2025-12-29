# PRD: Preferências que aprendem (Fase 3)

## Visão Geral

Hoje o ChooseThere já permite filtrar e sortear restaurantes, mas o comportamento é essencialmente estático: o app não “aprende” com o uso. A proposta desta fase é introduzir um sistema de preferências **rule-based** (sem ML pesado) que:

- ajusta pesos de categorias/tags com base nas avaliações;
- aumenta a probabilidade de sorteio de lugares que “combinam” com o perfil;
- evita repetir automaticamente lugares recentes (ex.: últimos 10).

O objetivo é deixar o app melhor com o tempo e criar motivo para uso recorrente.

## Objetivos

- Aprender preferências do usuário de forma transparente e controlável.
- Melhorar a qualidade do sorteio sem exigir configuração complexa.
- Reduzir frustração evitando repetição de lugares recentes.

Métricas sugeridas:
- Aumento de “match” percebido (proxy: mais avaliações altas ao longo do tempo).
- Redução de repetições em sessões próximas.
- % de usuários que mantém “Preferências que aprendem” ligado.
- % de uso do “Resetar aprendizado”.

## Histórias de Usuário

- Como usuário, eu quero que o app **aprenda** com minhas avaliações para sugerir lugares que combinam mais comigo.
- Como usuário, eu quero que o sorteio **não repita** lugares recentes automaticamente.
- Como usuário, eu quero poder **desativar** o aprendizado se eu não quiser.
- Como usuário, eu quero poder **resetar** o aprendizado quando meus gostos mudarem.

## Funcionalidades Principais

### 1) Pesos aprendidos por categoria/tags (sem ML)

O que faz:
- Mantém pesos simples para tags e/ou categorias, atualizando-os quando o usuário avalia um restaurante.

Requisitos funcionais:
1. F3.1: Ajustar pesos quando o usuário avalia (ex.: nota alta aumenta; nota baixa diminui).
2. F3.2: Definir limites (clamp) para evitar pesos extremos.
3. F3.3: Persistir pesos localmente.

### 2) Sorteio com probabilidade ajustada por “match”

O que faz:
- A roleta passa a ponderar candidatos com base no match entre o restaurante e os pesos aprendidos.

Requisitos funcionais:
1. F3.4: Restaurantes com maior match devem ter maior probabilidade de serem escolhidos.
2. F3.5: Deve existir fallback estável caso não existam pesos ainda.
3. F3.6: Testabilidade: sorteio determinístico em testes (RNG injetável).

### 3) Evitar repetidos automaticamente

O que faz:
- Não sortear restaurantes presentes nos últimos N resultados/visitas (ex.: N=10).

Requisitos funcionais:
1. F3.7: Evitar repetição dos últimos N (configurável).
2. F3.8: Se a lista for pequena, fallback controlado (não bloquear o usuário).

### 4) Controles em Configurações

O que faz:
- Usuário controla o sistema de aprendizado.

Requisitos funcionais:
1. F3.9: Toggle “Preferências que aprendem”.
2. F3.10: Botão “Resetar aprendizado”.
3. F3.11: Ajuste do N para “evitar repetidos” (ou valor fixo no MVP com possibilidade de evoluir).

## Experiência do Usuário

Experiência esperada:
- O usuário avalia normalmente (fluxo atual) e o app vai ficando mais alinhado com o tempo.
- O usuário não precisa entender fórmula; o app deve “funcionar por padrão”.
- Em Configurações, deve existir explicação curta do que acontece e como resetar.

Acessibilidade:
- Controles com labels/hints claros.
- Textos simples e curtos para explicar o aprendizado.

## Restrições Técnicas de Alto Nível

- Sem ML pesado e sem dependência de rede.
- Preferências e histórico são locais (UserDefaults/SwiftData).
- Sorteio deve ser testável (RNG injetável) e não degradar performance perceptivelmente.

## Não-Objetivos (Fora de Escopo)

- Modelos de ML, embeddings ou recomendação avançada.
- Sincronização do aprendizado entre dispositivos (pode ser futuro).
- Ranking global/compartilhado.

## Questões em Aberto

- Mapeamento final: aprender por tags, por categoria, ou ambos?
- Regras exatas por nota (ex.: 1–5) e step de incremento/decremento.
- Definição do “histórico recente”: baseado em últimas visitas avaliadas, últimos sorteios, ou ambos?


