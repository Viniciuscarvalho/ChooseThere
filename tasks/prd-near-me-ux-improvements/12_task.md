# [12.0] Integrate Location Onboarding Flow (M)

## Objetivo
- Integrar `LocationOnboardingView` no fluxo de app launch
- Exibir onboarding na primeira vez que usuário abre o app
- Não exibir novamente se já mostrado ou se usuário pulou
- Adicionar fallback no modo "Perto de mim" para quem negou permissão
- Implementar card informativo com botão para Configurações

## Subtarefas
- [ ] 12.1 Localizar app entry point (main app view ou ContentView)
- [ ] 12.2 Adicionar state para controle de apresentação de onboarding
- [ ] 12.3 Adicionar `.onAppear` que verifica flags e locationManager status
- [ ] 12.4 Apresentar LocationOnboardingView como sheet/fullScreenCover
- [ ] 12.5 Implementar callbacks de onPermissionGranted e onSkip
- [ ] 12.6 Abrir PreferencesView (modo Nearby)
- [ ] 12.7 Adicionar card informativo quando permissão não concedida
- [ ] 12.8 Implementar botão "Ir para Configurações" que abre Settings app
- [ ] 12.9 Testar fluxo completo: primeira vez, pular, conceder, negar

## Critérios de Sucesso
- Onboarding aparece no primeiro launch do app
- Não aparece em launches subsequentes se já mostrado
- Não aparece se usuário já tem permissão concedida
- Após conceder permissão, onboarding não aparece mais
- Após pular, flag é setada e onboarding não aparece mais
- No modo "Perto de mim", card informativo aparece se permissão não concedida
- Botão "Ir para Configurações" abre Settings app na tela correta
- Fluxo não interfere com navegação normal do app
- Testes manuais cobrem todos os cenários

## Dependências
- **Task 10.0**: Flags de onboarding no AppSettingsStorage
- **Task 11.0**: LocationOnboardingView implementado
- LocationManager existente

## Observações
- Apresentação deve ser em `.onAppear` do main view
- Verificar três condições: já mostrou? já pulou? já tem permissão?
- URL para Settings: `UIApplication.openSettingsURLString`
- Card informativo deve ser discreto, não modal (não bloquear UI)
- Card aparece apenas no contexto do modo "Perto de mim"
- Considerar usar `.sheet` ou `.fullScreenCover` dependendo do design

## status: pending

<task_context>
<domain>presentation/views</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>task_10,task_11</dependencies>
</task_context>

# Tarefa 12.0: Integrate Location Onboarding Flow

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa conecta o onboarding de localização ao fluxo principal do app, apresentando-o no momento adequado e implementando fallbacks para casos onde permissão foi negada. Completa o requisito FR5 do PRD (Fluxo Proativo de Permissão).

<requirements>
- Apresentar onboarding apenas no primeiro launch OU se usuário nunca viu
- Respeitar flags de AppSettingsStorage
- Não interferir com navegação existente
- Implementar card informativo em PreferencesView para casos de negação
- Abrir Settings app quando usuário quer conceder permissão posteriormente
</requirements>

## Subtarefas

- [ ] 12.1 Localizar main app view (ContentView, MainTabView, ou similar)
- [ ] 12.2 Adicionar @State var showLocationOnboarding = false
- [ ] 12.3 Adicionar @StateObject ou @EnvironmentObject LocationManager
- [ ] 12.4 Implementar .onAppear com lógica de decisão
- [ ] 12.5 Adicionar .sheet ou .fullScreenCover apresentando LocationOnboardingView
- [ ] 12.6 Implementar onPermissionGranted callback
- [ ] 12.7 Implementar onSkip callback
- [ ] 12.8 Abrir PreferencesView (modo Nearby) e adicionar seção de fallback
- [ ] 12.9 Implementar card informativo "Permissão necessária"
- [ ] 12.10 Implementar botão que abre Settings
- [ ] 12.11 Testar todos os cenários de permissão

## Detalhes de Implementação

Consulte `techspec.md` linhas 128-146 (FR5) e `prd.md` linhas 128-146 para requisitos.

**Lógica de apresentação no app launch:**
```swift
@State private var showLocationOnboarding = false
@StateObject private var locationManager = LocationManager()

var body: some View {
  // Main content
  // ...
  .onAppear {
    checkAndShowOnboarding()
  }
  .sheet(isPresented: $showLocationOnboarding) {
    LocationOnboardingView(
      locationManager: locationManager,
      onPermissionGranted: {
        AppSettingsStorage.hasShownLocationOnboarding = true
        // Opcional: navegar para modo Nearby
      },
      onSkip: {
        AppSettingsStorage.hasShownLocationOnboarding = true
        // Usuário pulou, não fazer nada
      }
    )
  }
}

private func checkAndShowOnboarding() {
  // Só mostrar se:
  // 1. Nunca mostrou antes
  // 2. Não tem permissão já concedida
  let shouldShow = !AppSettingsStorage.hasShownLocationOnboarding &&
                   !locationManager.isAuthorized

  if shouldShow {
    // Delay pequeno para evitar apresentação no frame inicial
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      showLocationOnboarding = true
    }
  }
}
```

**Card informativo em PreferencesView (modo Nearby sem permissão):**
```swift
// Na seção de nearby content, antes dos resultados
if searchMode == .nearby && !locationManager.isAuthorized {
  VStack(spacing: 12) {
    Image(systemName: "location.slash.fill")
      .font(.system(size: 40))
      .foregroundColor(AppColors.textSecondary)

    Text("Para usar esta função, precisamos acessar sua localização")
      .font(.body)
      .foregroundColor(AppColors.textPrimary)
      .multilineTextAlignment(.center)

    Button {
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
    } label: {
      Text("Ir para Configurações")
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .background(AppColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
  .padding()
  .background(AppColors.surface)
  .clipShape(RoundedRectangle(cornerRadius: 16))
  .padding(.horizontal)
}
```

## Critérios de Sucesso

### App Launch Flow
- Ao abrir app pela primeira vez: onboarding aparece após ~0.5s
- Ao conceder permissão: onboarding fecha, flag hasShownLocationOnboarding = true
- Ao pular: onboarding fecha, ambas flags setadas (hasShown e hasSkipped)
- Em launches subsequentes: onboarding NÃO aparece
- Se usuário já tem permissão: onboarding NUNCA aparece

### PreferencesView Fallback
- No modo "Perto de mim" sem permissão: card informativo aparece
- Card mostra ícone, mensagem, e botão "Ir para Configurações"
- Ao tocar botão: Settings app abre na tela de configurações do app
- Card não aparece se permissão já concedida
- Card não aparece em modo "Minha Lista"

### Testes Manuais
- [ ] Primeira instalação → onboarding aparece → conceder → não aparece mais
- [ ] Primeira instalação → onboarding aparece → pular → não aparece mais
- [ ] Reinstalar app → onboarding aparece novamente
- [ ] Negar permissão → modo Nearby → card fallback aparece
- [ ] Ir para Settings → conceder → voltar para app → card desaparece
- [ ] Já tem permissão → onboarding nunca aparece

### Code Quality
- Código compila sem warnings
- Lógica de decisão é clara e bem comentada
- Delay de apresentação evita conflitos de navegação
- Callbacks atualizam flags corretamente
- Formatação segue Kodeco style guide

## Arquivos relevantes
- Modificar: Main app view (ContentView, AppView, ou similar)
- Modificar: `ChooseThere/Presentation/Views/PreferencesView.swift` (adicionar card fallback)
- Referência: `ChooseThere/Presentation/Views/LocationOnboardingView.swift`
- Referência: `ChooseThere/Data/AppSettingsStorage.swift`
- Referência: `ChooseThere/Services/LocationManager.swift`
- Referência: `techspec.md` (linhas 415-485, 542-560)
- Referência: `prd.md` (linhas 128-146 - FR5 completo)
