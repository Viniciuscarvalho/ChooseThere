# ChooseThere — PRD (V1 iOS)

## Visão Geral
ChooseThere é um app offline-first para ajudar a escolher um restaurante em São Paulo com base no “gosto do dia” da minha namorada, usando uma lista curada (JSON) e registrando avaliações para construir histórico e preferências ao longo do tempo. O problema que resolve é a fricção de decidir “onde ir hoje”, reduzindo indecisão e tornando a escolha divertida (tela de roleta), com um resultado acionável (mapa/rota) e aprendizado local via histórico.

O público-alvo da V1 é um casal que deseja decidir rapidamente onde comer/beber, com baixa carga cognitiva: definir preferências rápidas, sortear, abrir rota, e depois registrar se valeu a pena.

## Objetivos
- Diminuir tempo até a decisão (meta: usuário consegue sortear e abrir rota em < 30s).
- Aumentar taxa de “conclusão do fluxo” (meta: ≥ 60% das sessões chegam no resultado do sorteio).
- Criar hábito de avaliação pós-visita (meta: ≥ 30% dos restaurantes marcados como visitados recebem nota).
- Funcionar offline para navegação e histórico (meta: app utilizável sem rede, exceto abrir links externos).

## Histórias de Usuário
- Como usuária (namorada), eu quero escolher rapidamente o tipo de comida/lugar que estou a fim para que o app sorteie algo compatível.
- Como usuário (curador da lista), eu quero que a lista de restaurantes seja offline e estável, para que o app funcione sem depender de serviços externos.
- Como usuária, eu quero ver o resultado no mapa e abrir a rota para que eu consiga ir até o lugar sem esforço.
- Como usuária, eu quero avaliar a visita para que o app aprenda o que funciona pro meu gosto e eu consiga consultar histórico.

## Funcionalidades Principais

### 1) Onboarding rápido (opcional)
O onboarding explica o fluxo (“preferências → sorteio → ir → avaliar”) com um CTA de início.

Requisitos funcionais:
1.1 Exibir uma tela única de onboarding ao primeiro uso, com opção de “Começar”.
1.2 Permitir pular o onboarding em execuções futuras (não bloquear uso).

### 2) Preferências (tela inicial)
Tela para definir o contexto do sorteio: tags desejadas, filtros simples e tags a evitar.

Requisitos funcionais:
2.1 Exibir campo “Hoje estamos a fim de…” com chips/tags selecionáveis (ex.: Japonesa, Pizza, Vegano, Hambúrguer, Café, Bar, Doces).
2.2 Permitir selecionar múltiplas tags desejadas.
2.3 Permitir definir raio de busca (1km/3km/5km/10km).
2.4 Permitir definir faixa de preço ($/$$/$$$).
2.5 Permitir selecionar tags “Evitar” (não curto).
2.6 Botão principal “Sortear agora” inicia o sorteio usando apenas o contexto atual.
2.7 Se o usuário não selecionar nenhuma tag desejada, o sorteio deve considerar todos os restaurantes (respeitando apenas filtros aplicáveis).

### 3) Tela de roleta (animação de escolha)
Tela intermediária com animação divertida e simples, exibindo “quase escolhidos” para gerar expectativa.

Requisitos funcionais:
3.1 Exibir uma animação de sorteio (uma opção definida na V1).
3.2 Exibir 3–6 restaurantes “quase escolhidos” durante a animação.
3.3 Após finalizar, navegar automaticamente para o resultado.
3.4 Oferecer “Sortear de novo” com limite configurável (ex.: até 3 re-rolls por sessão).

### 4) Resultado no mapa + ações
Exibe restaurante escolhido e um mapa com pin, além de ações práticas.

Requisitos funcionais:
4.1 Exibir card do restaurante escolhido com nome, categoria, preço, distância e/ou bairro (quando disponível).
4.2 Exibir mapa com pin na localização do restaurante.
4.3 Permitir abrir rota no app de mapas (Apple Maps; suporte a Google Maps opcional quando instalado).
4.4 Permitir marcar/desmarcar como favorito.
4.5 Permitir “Sortear outro” retornando ao fluxo de roleta, mantendo o mesmo contexto (preferências atuais).
4.6 Permitir “Ver rota” (ação equivalente a abrir o mapa já com navegação/rota).

### 5) Pós-visita: avaliação + histórico local
Registro de visita e avaliação, com tags rápidas e indicador de “match pro gosto dela”.

Requisitos funcionais:
5.1 Permitir marcar um restaurante como “visitado” manualmente a partir do resultado ou detalhe no histórico.
5.2 Capturar nota 1–5.
5.3 Capturar tags rápidas (ex.: Gostei muito, Bom custo, Voltaria, Muito cheio, Demorado).
5.4 Capturar comentário opcional.
5.5 Capturar toggle “Foi match pro gosto dela?” (boolean).
5.6 Salvar localmente (offline) e atualizar o histórico imediatamente.

### 6) Histórico
Lista de visitas com filtros e acesso a detalhes.

Requisitos funcionais:
6.1 Exibir lista de visitas ordenada por data (mais recente primeiro).
6.2 Permitir filtros: “Melhores avaliados”, “Voltaria”, “Não repetir”, por categoria/tag.
6.3 Ao tocar em um item, exibir detalhes do restaurante + mapa + avaliação.
6.4 Permitir editar avaliação (nota/tags/comentário/match) de uma visita existente.

### 7) Base de dados e conteúdo (offline-first)
A V1 usa uma lista de restaurantes incluída no app (bundle) e armazena tudo localmente.

Requisitos funcionais:
7.1 Consumir a lista de restaurantes a partir de um arquivo JSON incluído no app.
7.2 Cada restaurante deve incluir `lat` e `lng` (pré-preenchidos no JSON para a V1).
7.3 Persistir restaurantes, favoritos e visitas localmente.
7.4 Manter uma única “fonte da verdade” para leitura no app (sem divergência entre JSON e banco local após inicialização).

## Experiência do Usuário
- Fluxo principal: Onboarding (opcional) → Preferências → Roleta → Resultado (mapa + ações) → (opcional) Avaliar → Histórico.
- O app deve ser “bem básico e direto”, com UI clara e ações principais evidentes.
- Acessibilidade: suportar Dynamic Type, VoiceOver para botões e chips, contraste adequado e targets de toque adequados.
- Estados vazios:
  - Sem restaurantes compatíveis: mensagem clara e opção de ajustar filtros (ex.: remover “evitar”, aumentar raio, trocar preço).
  - Sem visitas no histórico: estado vazio com CTA para sortear.

## Restrições Técnicas de Alto Nível
- Arquitetura modular em camadas (Domain/Data/Presentation + Composition Root), sem criar múltiplos módulos SPM.
- Navegação via padrão Router (não usar `NavigationStack`).
- Injeção de dependência via Swinject instalado por SPM.
- Persistência local via SwiftData para restaurantes/favoritos/visitas, evitando duplicidade de fontes.
- Integração com mapa (Apple Maps; Google Maps opcional).
- Operação offline-first (rede apenas para abrir links externos e apps de mapas, quando aplicável).

## Não-Objetivos (Fora de Escopo)
- Sincronização em nuvem, login/contas, compartilhamento entre dispositivos.
- Recomendação “inteligente” avançada (ML), personalização complexa, ou ranking sofisticado além do básico.
- Geocoding automático de endereços (lat/lng já vem no JSON na V1).
- Importação/edição completa da lista de restaurantes dentro do app (admin/editor).
- Notificações push e automações de “cheguei no local” via geofence.

## Questões em Aberto
- Definição exata de “Não repetir”: é uma tag na visita, um estado no restaurante, ou ambos?
- Regras de priorização no sorteio: usar histórico para “puxar” favoritos/melhores avaliados ou manter sorteio uniforme na V1?
- Google Maps: suportar já na V1 como opção de abrir rota, ou manter apenas Apple Maps inicialmente?


