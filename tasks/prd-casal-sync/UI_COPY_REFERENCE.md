# Referência de Copy: Coleção Compartilhada do Casal

## Versão: 1.0
## Data: 29/12/2025

---

## 📝 Todas as Mensagens de UI

### Settings View - Seção "Coleção do casal"

#### Header
```
Coleção do casal
```

#### Footer
```
Exporte sua coleção para compartilhar com outra pessoa, ou importe um backup recebido.
```

#### Botões
- **Exportar backup** - Ícone: `square.and.arrow.up` (azul)
- **Importar backup** - Ícone: `square.and.arrow.down` (secundário)

---

### Export Flow

#### Alert: Aviso de Privacidade
**Título**:
```
Aviso de Privacidade
```

**Mensagem**:
```
O backup contém dados pessoais (histórico de visitas, avaliações e notas). Compartilhe apenas com pessoas de confiança.
```

**Botões**:
- `Cancelar` (role: cancel)
- `Continuar` (role: default)

---

#### Alert: Erro ao Exportar
**Título**:
```
Erro ao Exportar
```

**Mensagem**: (variável, baseada no erro)
- `Não há dados para exportar.`
- `Erro ao gerar backup: [detalhe]`
- `Erro ao buscar dados: [detalhe]`

**Botões**:
- `OK` (role: cancel)

---

### Import Flow

#### Alert: Erro ao Importar
**Título**:
```
Erro ao Importar
```

**Mensagem**: (variável, baseada no erro de validação)

**Erros de Validação**:
```
- "O arquivo não é um JSON válido: [detalhe]"
- "Versão do backup não suportada: [versão]. Atualize o app."
- "Campo obrigatório ausente: [campo]"
- "Dados inválidos no restaurante '[id]': [razão]"
- "Dados inválidos na visita '[uuid]': [razão]"
- "A visita '[uuid]' referencia um restaurante inexistente: '[restaurantId]'"
- "O backup está vazio (sem restaurantes)."
- "A data de criação do backup está no futuro."
- "Não foi possível obter sua localização para a busca no Apple Maps."
```

**Botões**:
- `OK` (role: cancel)

---

### Preview View

#### Header
**Título**:
```
Preview do Backup
```

**Subtitle**:
```
Importar Backup
```

**Descrição**:
```
Revise as informações abaixo antes de continuar
```

---

#### Informações do Backup
**Labels**:
- `Data de criação`: [data formatada]
- `Versão do app`: [versão]
- `Versão do schema`: `v[número]`

---

#### Contadores
**Título da Seção**:
```
O que será importado
```

**Cards**:
- **Restaurantes**: `[N]` - Ícone: `fork.knife`
- **Favoritos**: `[N]` - Ícone: `star.fill`
- **Visitas/Avaliações**: `[N]` - Ícone: `clock.arrow.circlepath`

---

#### Cidades
**Título da Seção**:
```
Cidades no backup
```

**Conteúdo**: Lista de cidades em chips

---

#### Modo de Importação
**Título da Seção**:
```
Como importar?
```

**Modo 1: Substituir tudo**
- **Nome**: `Substituir tudo`
- **Descrição**: `Apaga todos os dados locais e importa o backup do zero.`

**Modo 2: Mesclar por ID**
- **Nome**: `Mesclar por ID`
- **Descrição**: `Adiciona novos itens e atualiza existentes sem apagar o restante.`

---

#### Botões
- **Cancelar** (toolbar, cancelation action, vermelho)
- **Confirmar Importação** (botão principal, azul)

---

### Alert: Confirmação de Substituição

**Título**:
```
Substituir Tudo?
```

**Mensagem**:
```
Isso apagará TODOS os seus restaurantes e visitas atuais e substituirá pelos dados do backup. Esta ação não pode ser desfeita.
```

**Botões**:
- `Cancelar` (role: cancel)
- `Substituir` (role: destructive, vermelho)

---

### Alert: Importação Concluída

**Título**:
```
Importação Concluída
```

**Mensagem**: (gerada dinamicamente por `BackupImportResult.summary`)

**Exemplos**:
```
- "5 restaurante(s) importado(s), 10 visita(s) importada(s)"
- "2 restaurante(s) atualizado(s), 3 visita(s) atualizada(s)"
- "10 restaurante(s) importado(s), 5 restaurante(s) atualizado(s), 20 visita(s) importada(s), 8 visita(s) atualizada(s)"
- "1 entrada(s) inválida(s) ignorada(s)"
- "Nenhuma alteração realizada."
```

**Botões**:
- `OK` (role: default)

---

## ♿ Acessibilidade

### Labels e Hints

#### SettingsView
```swift
// Botão Exportar
.accessibilityLabel("Exportar backup")
.accessibilityHint("Gera um arquivo com sua coleção de restaurantes para compartilhar")

// Botão Importar
.accessibilityLabel("Importar backup")
.accessibilityHint("Seleciona um arquivo de backup para restaurar ou mesclar")
```

#### BackupImportPreviewView
```swift
// Modo de importação
.accessibilityLabel("\(mode.displayName)")
.accessibilityHint(mode.description)
.accessibilityAddTraits(selectedMode == mode ? [.isSelected] : [])

// Botão Confirmar
.accessibilityLabel("Confirmar importação")
.accessibilityHint("Aplica o backup usando o modo selecionado")
```

---

## 🎨 Princípios de Copy

### Tom e Voz
- ✅ **Claro e direto**: Sem jargão técnico
- ✅ **Amigável**: Linguagem casual mas profissional
- ✅ **Honesto**: Avisos claros sobre ações destrutivas
- ✅ **Útil**: Mensagens de erro explicam o problema e próximos passos

### Estrutura de Mensagens

#### Erros
```
[Problema claro] + [Possível causa ou ação corretiva]
```

Exemplos:
- ❌ "Erro 404" 
- ✅ "Versão do backup não suportada: 99. Atualize o app."

#### Confirmações
```
[Descrição da ação] + [Consequência] + [Reversibilidade]
```

Exemplo:
- "Isso apagará TODOS os seus restaurantes... Esta ação não pode ser desfeita."

#### Sucesso
```
[Quantificação] + [Ação realizada]
```

Exemplo:
- "5 restaurante(s) importado(s), 10 visita(s) importada(s)"

---

## 🌐 Localização (Futuro)

### Strings Hardcoded Atuais
Todas as strings estão hardcoded em português no código.

### Preparação para i18n
Para suportar múltiplos idiomas no futuro:
1. Extrair todas as strings para `Localizable.strings`
2. Usar `NSLocalizedString` ou SwiftUI `.localized`
3. Manter chaves descritivas: `backup.export.privacy.title`

### Prioridade de Idiomas (Sugestão)
1. Português (BR) - atual
2. Inglês (US)
3. Espanhol (ES)

---

## 📊 Métricas de Copy

### Clareza
- [ ] Todas as mensagens são compreensíveis sem contexto técnico
- [ ] Usuários entendem "Substituir tudo" vs "Mesclar por ID"
- [ ] Erros explicam o problema claramente

### Consistência
- [ ] Tom de voz consistente em todo o fluxo
- [ ] Terminologia padronizada ("backup", "importar", "restaurante")
- [ ] Formatação consistente (contadores, datas)

### Completude
- [ ] Todos os estados têm mensagens (loading, sucesso, erro)
- [ ] Confirmações para ações destrutivas
- [ ] Feedback claro após operações

---

## 🐛 Problemas Conhecidos de Copy

### Nenhum identificado atualmente

---

## ✅ Checklist de Revisão

- [x] Todas as mensagens estão em português correto
- [x] Sem jargão técnico desnecessário
- [x] Ações destrutivas têm confirmação explícita
- [x] Erros são claros e acionáveis
- [x] Sucesso fornece feedback quantificado
- [x] Acessibilidade: labels e hints presentes

---

**Última revisão**: 29/12/2025  
**Revisado por**: AI Assistant  
**Status**: ✅ Aprovado para produção

