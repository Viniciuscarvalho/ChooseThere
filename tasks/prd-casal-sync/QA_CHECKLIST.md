# QA Checklist: Coleção Compartilhada do Casal (Export/Import)

## Versão: 1.0
## Data: 29/12/2025

---

## 📋 Preparação

### Pré-requisitos
- [ ] App instalado em dois dispositivos (ou um dispositivo + simulador)
- [ ] SwiftData populado com alguns restaurantes e visitas
- [ ] Acesso a Configurações → Coleção do casal

---

## ✅ Cenários de Teste - Export

### 1. Export Básico (Caso Feliz)
**Objetivo**: Verificar export de backup com dados válidos

- [ ] **1.1** Abrir Configurações
- [ ] **1.2** Tocar em "Exportar backup"
- [ ] **1.3** Confirmar aviso de privacidade
- [ ] **1.4** Verificar que file picker abre
- [ ] **1.5** Salvar arquivo `chooseThere_backup.json`
- [ ] **1.6** Verificar que arquivo foi criado com sucesso
- [ ] **1.7** Abrir arquivo em editor de texto e validar:
  - JSON válido
  - Campo `schemaVersion: 1`
  - Campo `createdAt` com timestamp
  - Campo `appVersion`
  - Array `restaurants` com dados corretos
  - Array `visits` com dados corretos

**Resultado Esperado**: ✅ Arquivo exportado com sucesso e válido

---

### 2. Export com Database Vazia
**Objetivo**: Verificar comportamento quando não há dados

- [ ] **2.1** Limpar todos os restaurantes e visitas
- [ ] **2.2** Tentar exportar backup
- [ ] **2.3** Verificar erro: "Não há dados para exportar"

**Resultado Esperado**: ✅ Erro claro, não gera arquivo vazio

---

### 3. Export - Cancelamento
**Objetivo**: Verificar que usuário pode cancelar

- [ ] **3.1** Iniciar export
- [ ] **3.2** No aviso de privacidade, tocar "Cancelar"
- [ ] **3.3** Verificar que nenhum arquivo foi criado

**Resultado Esperado**: ✅ Operação cancelada sem efeitos colaterais

---

### 4. Export - Compartilhamento
**Objetivo**: Verificar compartilhamento via AirDrop/WhatsApp

- [ ] **4.1** Exportar backup
- [ ] **4.2** Selecionar "Salvar em Arquivos"
- [ ] **4.3** Verificar que arquivo aparece em iCloud Drive / Arquivos
- [ ] **4.4** (Opcional) Testar AirDrop para outro dispositivo
- [ ] **4.5** (Opcional) Testar envio via WhatsApp

**Resultado Esperado**: ✅ Arquivo pode ser compartilhado por múltiplos canais

---

## ✅ Cenários de Teste - Import

### 5. Import Básico - Merge (Caso Feliz)
**Objetivo**: Importar backup mesclando com dados locais

- [ ] **5.1** Ter alguns restaurantes locais
- [ ] **5.2** Importar backup válido
- [ ] **5.3** Verificar preview:
  - Contagens corretas
  - Data de criação
  - Versão do app
  - Lista de cidades
- [ ] **5.4** Selecionar modo "Mesclar por ID"
- [ ] **5.5** Tocar "Confirmar Importação"
- [ ] **5.6** Verificar mensagem de sucesso com contadores
- [ ] **5.7** Validar que:
  - Restaurantes do backup foram adicionados/atualizados
  - Restaurantes locais não foram apagados
  - Visitas foram mescladas corretamente

**Resultado Esperado**: ✅ Dados mesclados sem perda de dados locais

---

### 6. Import - Replace All (Destrutivo)
**Objetivo**: Substituir todos os dados locais pelo backup

- [ ] **6.1** Ter restaurantes locais diferentes do backup
- [ ] **6.2** Importar backup válido
- [ ] **6.3** Selecionar modo "Substituir tudo"
- [ ] **6.4** Verificar alert de confirmação:
  - Texto claro sobre ação destrutiva
  - Aviso "não pode ser desfeita"
  - Botão "Cancelar" (default)
  - Botão "Substituir" (vermelho)
- [ ] **6.5** Tocar "Substituir"
- [ ] **6.6** Verificar mensagem de sucesso
- [ ] **6.7** Validar que:
  - Todos os dados antigos foram apagados
  - Apenas dados do backup existem

**Resultado Esperado**: ✅ Substituição completa com confirmação explícita

---

### 7. Import - Replace All - Cancelamento
**Objetivo**: Verificar cancelamento do replace

- [ ] **7.1** Iniciar import com "Substituir tudo"
- [ ] **7.2** No alert de confirmação, tocar "Cancelar"
- [ ] **7.3** Verificar que dados locais não foram alterados

**Resultado Esperado**: ✅ Cancelamento seguro, sem mudanças

---

### 8. Import - Arquivo Inválido (JSON corrompido)
**Objetivo**: Validar tratamento de erro para JSON inválido

- [ ] **8.1** Criar arquivo `.json` com conteúdo inválido (ex: texto puro)
- [ ] **8.2** Tentar importar
- [ ] **8.3** Verificar erro: "O arquivo não é um JSON válido"
- [ ] **8.4** Verificar que nenhuma mudança foi feita no banco

**Resultado Esperado**: ✅ Erro claro, sem mudanças no banco

---

### 9. Import - Schema Version Incompatível
**Objetivo**: Validar versão do schema

- [ ] **9.1** Editar backup e mudar `schemaVersion` para `99`
- [ ] **9.2** Tentar importar
- [ ] **9.3** Verificar erro: "Versão do backup não suportada: 99. Atualize o app."
- [ ] **9.4** Verificar que nenhuma mudança foi feita no banco

**Resultado Esperado**: ✅ Erro claro sobre incompatibilidade

---

### 10. Import - Campos Obrigatórios Ausentes
**Objetivo**: Validar campos obrigatórios

- [ ] **10.1** Editar backup e remover campo obrigatório (ex: `schemaVersion`)
- [ ] **10.2** Tentar importar
- [ ] **10.3** Verificar erro: "Campo obrigatório ausente: schemaVersion"

**Resultado Esperado**: ✅ Erro específico sobre campo ausente

---

### 11. Import - Coordenadas Inválidas
**Objetivo**: Validar dados de restaurante

- [ ] **11.1** Editar backup e colocar latitude inválida (ex: `-100`)
- [ ] **11.2** Tentar importar
- [ ] **11.3** Verificar erro sobre latitude inválida

**Resultado Esperado**: ✅ Validação detecta dados inválidos

---

### 12. Import - Visita Órfã
**Objetivo**: Validar integridade referencial

- [ ] **12.1** Editar backup: criar visita com `restaurantId` inexistente
- [ ] **12.2** Tentar importar
- [ ] **12.3** Verificar erro sobre visita órfã ou referência inexistente

**Resultado Esperado**: ✅ Validação detecta referência quebrada

---

### 13. Import - Backup Vazio
**Objetivo**: Verificar import de backup sem dados

- [ ] **13.1** Criar backup com arrays vazios `restaurants: []`, `visits: []`
- [ ] **13.2** Tentar importar
- [ ] **13.3** Verificar erro: "O backup está vazio"

**Resultado Esperado**: ✅ Erro claro para backup vazio

---

### 14. Import - Merge com Dados Duplicados (Mesmo ID)
**Objetivo**: Validar atualização de dados existentes

- [ ] **14.1** Ter restaurante local com ID "rest-1" e nome "Original"
- [ ] **14.2** Importar backup com mesmo ID "rest-1" mas nome "Atualizado"
- [ ] **14.3** Usar modo "Mesclar por ID"
- [ ] **14.4** Verificar que nome foi atualizado para "Atualizado"
- [ ] **14.5** Verificar contador: "0 importados, 1 atualizado"

**Resultado Esperado**: ✅ Atualização correta por ID

---

### 15. Import - Preview e Navegação
**Objetivo**: Validar UX do preview

- [ ] **15.1** Importar backup válido
- [ ] **15.2** No preview, verificar:
  - Todas as informações visíveis
  - Descrições claras dos modos
  - Botão "Cancelar" funciona
  - Navegação fluida
- [ ] **15.3** Alternar entre modos "Substituir" e "Mesclar"
- [ ] **15.4** Verificar que escolha é preservada

**Resultado Esperado**: ✅ Preview completo e navegação intuitiva

---

## ✅ Cenários de Teste - Integração

### 16. Fluxo Completo: Export → Import (Dispositivo 1 → 2)
**Objetivo**: Validar sincronização entre dispositivos

**Dispositivo 1:**
- [ ] **16.1** Criar 5 restaurantes únicos
- [ ] **16.2** Adicionar 3 visitas
- [ ] **16.3** Exportar backup
- [ ] **16.4** Enviar via AirDrop/WhatsApp para Dispositivo 2

**Dispositivo 2:**
- [ ] **16.5** Receber backup
- [ ] **16.6** Importar usando "Substituir tudo"
- [ ] **16.7** Verificar que tem exatamente os mesmos 5 restaurantes e 3 visitas do Dispositivo 1

**Resultado Esperado**: ✅ Sincronização perfeita entre dispositivos

---

### 17. Fluxo Bidirecional (Casal sincronizando)
**Objetivo**: Simular uso real do casal

**Pessoa A:**
- [ ] **17.1** Tem 10 restaurantes
- [ ] **17.2** Exporta backup

**Pessoa B:**
- [ ] **17.3** Importa backup de A (Merge)
- [ ] **17.4** Adiciona 2 novos restaurantes
- [ ] **17.5** Exporta novo backup

**Pessoa A:**
- [ ] **17.6** Importa backup de B (Merge)
- [ ] **17.7** Verifica que tem todos os 12 restaurantes (10 originais + 2 novos)

**Resultado Esperado**: ✅ Ambos ficam sincronizados sem perda de dados

---

## ✅ Cenários de Teste - Acessibilidade

### 18. VoiceOver
**Objetivo**: Validar acessibilidade básica

- [ ] **18.1** Ativar VoiceOver
- [ ] **18.2** Navegar pela tela de Configurações
- [ ] **18.3** Verificar que botões têm labels claros:
  - "Exportar backup"
  - "Importar backup"
- [ ] **18.4** No preview, verificar navegação com VoiceOver
- [ ] **18.5** Nos alerts, verificar leitura correta

**Resultado Esperado**: ✅ Navegação funcional com VoiceOver

---

### 19. Dynamic Type (Fontes grandes)
**Objetivo**: Validar com fontes aumentadas

- [ ] **19.1** Ir em Ajustes → Acessibilidade → Tamanho de Texto
- [ ] **19.2** Aumentar para o máximo
- [ ] **19.3** Abrir preview de import
- [ ] **19.4** Verificar que todo texto é legível e não corta

**Resultado Esperado**: ✅ Layout se adapta a fontes grandes

---

## ✅ Cenários de Teste - Performance

### 20. Import de Backup Grande
**Objetivo**: Validar performance com muitos dados

- [ ] **20.1** Criar backup com 500 restaurantes e 1000 visitas
- [ ] **20.2** Importar com modo "Substituir tudo"
- [ ] **20.3** Verificar que:
  - UI não trava
  - Loading indicator é exibido
  - Import completa em tempo razoável (< 10 segundos)

**Resultado Esperado**: ✅ Performance aceitável com dados grandes

---

## 📊 Resumo de Resultados

| Categoria | Total | Passou | Falhou | Bloqueado |
|-----------|-------|--------|--------|-----------|
| Export | 4 | | | |
| Import | 11 | | | |
| Integração | 2 | | | |
| Acessibilidade | 2 | | | |
| Performance | 1 | | | |
| **TOTAL** | **20** | | | |

---

## 🐛 Bugs Encontrados

### Bug #1
- **Severidade**: [ ] Crítico [ ] Alto [ ] Médio [ ] Baixo
- **Descrição**: 
- **Steps to Reproduce**: 
- **Resultado Esperado**: 
- **Resultado Atual**: 

---

## ✅ Sign-off

- [ ] Todos os cenários críticos passaram
- [ ] Bugs críticos foram corrigidos
- [ ] Copy está claro e consistente
- [ ] Acessibilidade básica validada

**QA por**: _________________  
**Data**: _________________  
**Versão testada**: _________________

