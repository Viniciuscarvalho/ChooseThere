# PRD: Coleção compartilhada do casal (Export/Import)

## Visão Geral

Hoje o ChooseThere é um app local (SwiftData) que concentra a lista de restaurantes e o histórico de visitas/avaliações. Para “virar o app do casal de verdade”, precisamos de um jeito simples de manter a mesma coleção em **dois aparelhos** sem exigir login, backend ou iCloud.

Nesta fase (Fase 2), a sincronização será feita via **Export/Import** de um arquivo `chooseThere_backup.json` usando o Share Sheet (WhatsApp/AirDrop/Files) e um importador dentro do app. A importação deve permitir escolher entre **Substituir tudo** e **Mesclar por ID**.

## Objetivos

- Permitir que duas pessoas compartilhem a mesma coleção de restaurantes e histórico de avaliações sem login.
- Fazer export/import de forma **rápida** e com baixa chance de erro (validação e preview).
- Garantir que o fluxo seja seguro: evitar perda de dados acidental (confirmações e modo merge).

Métricas sugeridas:
- % de usuários que exportam backup pelo menos 1x.
- % de usuários que importam backup com sucesso (sem erro de validação).
- Taxa de uso de “Substituir tudo” vs “Mesclar”.
- Tempo médio do fluxo (abrir Settings → exportar/importar → concluído).

## Histórias de Usuário

- Como usuário, eu quero **exportar** a minha coleção para mandar para meu parceiro(a) e termos a mesma lista e avaliações.
- Como usuário, eu quero **importar** um backup para sincronizar meu app com o de outra pessoa.
- Como usuário, eu quero **escolher** se a importação vai substituir tudo ou mesclar, para evitar apagar algo sem querer.
- Como usuário, eu quero ver um **resumo/preview** do que será importado antes de aplicar.

## Funcionalidades Principais

### 1) Exportar backup (`chooseThere_backup.json`)

O que faz:
- Gera um arquivo JSON contendo a coleção do usuário e permite compartilhar via Share Sheet.

Por que é importante:
- É o caminho de sincronização mais simples e universal (WhatsApp/AirDrop/Files).

Requisitos funcionais:
1. F2.1: Exportar um arquivo `chooseThere_backup.json` com schema versionado.
2. F2.2: Incluir no backup **a lista inteira de restaurantes do usuário**, com campos relevantes (incluindo favoritos) e **visitas/avaliações**.
3. F2.3: Apresentar Share Sheet e permitir salvar em Arquivos.

### 2) Importar backup (com validação e preview)

O que faz:
- Permite selecionar um arquivo `.json`, validar o conteúdo e mostrar um resumo antes de aplicar.

Requisitos funcionais:
1. F2.4: Importar via seletor de arquivo (Files) e validar schema/version.
2. F2.5: Mostrar preview com contagens (ex.: restaurantes e visitas) e possíveis avisos.
3. F2.6: Em caso de erro de validação, mostrar mensagem clara e não alterar a base.

### 3) Estratégia de importação: Substituir vs Mesclar

O que faz:
- Dá ao usuário escolha no momento do import.

Requisitos funcionais:
1. F2.7: Opção “Substituir tudo”: limpa a base local e importa do zero.
2. F2.8: Opção “Mesclar por ID”: insere/atualiza por `id` (restaurant e visit), sem apagar o que não veio no arquivo.
3. F2.9: Confirmar ação destrutiva antes de “Substituir tudo”.

### 4) Integração no app (Configurações)

O que faz:
- Um ponto único para export/import.

Requisitos funcionais:
1. F2.10: Expor ações em `SettingsView`: Exportar backup / Importar backup.
2. F2.11: Mostrar feedback de sucesso/erro e instruções claras.

## Experiência do Usuário

Fluxo sugerido (Settings):
- “Coleção do casal”
  - Botão “Exportar backup”
  - Botão “Importar backup”

Ao importar:
- Seleciona arquivo
- Tela de preview (contagens, data de criação, versão do schema)
- Escolhe: “Substituir tudo” vs “Mesclar”
- Confirma (se substituição)
- Executa import e mostra resultado (ex.: “132 restaurantes, 48 visitas importadas”)

Acessibilidade:
- Botões com labels/hints claros (VoiceOver).
- Mensagens com linguagem simples (“Este backup não é compatível com esta versão do app”).

## Restrições Técnicas de Alto Nível

- Sem backend e sem autenticação.
- Import/export deve ser **determinístico** e não depender de rede.
- Não chamar MapKit ou serviços externos durante testes unitários.
- SwiftData deve manter integridade: visitas referenciam `restaurantId` existente no backup.
- Performance: import deve evitar travar a UI (usar `Task` e atualizações progressivas quando necessário).
- Privacidade: o arquivo contém dados pessoais (histórico/notes). O app deve avisar que o usuário está compartilhando esse arquivo.

## Não-Objetivos (Fora de Escopo)

- Sync em tempo real (iCloud/Google Drive).
- Multi-dispositivos além de duas pessoas.
- Criptografia ponta-a-ponta do arquivo (pode ser um upgrade futuro).
- Import/export do cache do Apple Maps.
- Import/export de settings (cidade selecionada, raio, fonte).

## Questões em Aberto

- Política final de merge para conflitos:
  - Visitas com mesmo `id` mas campos diferentes: “última escrita vence” via timestamp?
  - Restaurante com mesmo `id` mas campos divergentes: manter local vs aplicar backup?
- Como comunicar melhor o risco de compartilhamento (texto/alerta antes de exportar)?


