# [11.0] Create LocationOnboardingView (M)

## Objetivo
- Criar tela de onboarding que educa usuário sobre benefícios de permissão de localização
- Implementar UI com ilustração, título, descrição e botões de ação
- Solicitar permissão apenas após usuário tocar em "Permitir localização"
- Implementar botão secundário "Agora não" para pular
- Integrar com LocationManager para request de permissão

## Subtarefas
- [ ] 11.1 Criar arquivo `LocationOnboardingView.swift` em `ChooseThere/Presentation/Views/`
- [ ] 11.2 Implementar struct com properties: locationManager, onPermissionGranted, onSkip
- [ ] 11.3 Criar layout vertical com SF Symbol de localização
- [ ] 11.4 Adicionar título "Descubra restaurantes perto de você"
- [ ] 11.5 Adicionar descrição explicativa
- [ ] 11.6 Implementar botão primário que chama `locationManager.requestPermission()`
- [ ] 11.7 Implementar botão secundário que chama `onSkip` e seta flag
- [ ] 11.8 Adicionar lógica para dismiss após permissão concedida
- [ ] 11.9 Aplicar styling consistente com design system do app
- [ ] 11.10 Criar SwiftUI preview

## Critérios de Sucesso
- View renderiza com layout correto e centralizado
- SF Symbol de localização aparece grande (80pt) e hierárquico
- Textos estão em português e claros
- Botão primário solicita permissão ao tocar
- Botão secundário dismiss view e seta flag hasSkippedLocationOnboarding
- View dismiss automaticamente se permissão for concedida
- Callbacks (onPermissionGranted, onSkip) são chamados apropriadamente
- Preview mostra tela completa
- Código segue Kodeco Swift Style Guide

## Dependências
- **Task 10.0**: AppSettingsStorage deve ter flags de onboarding
- LocationManager existente (não modificar)

## Observações
- View é apresentada como sheet/fullScreenCover
- Usar `@Environment(\.dismiss)` para fechar view
- Request de permissão é async, usar Task {}
- Verificar `locationManager.isAuthorized` após request
- Não usar cores hardcoded, usar AppColors
- Ilustração usa SF Symbol "location.circle.fill" com hierarchical rendering

## status: pending

<task_context>
<domain>presentation/views</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>task_10</dependencies>
</task_context>

# Tarefa 11.0: Create LocationOnboardingView

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta view apresenta o onboarding contextualizado de permissão de localização durante o primeiro launch do app. Explica os benefícios da permissão antes de solicitá-la, aumentando taxa de concessão e reduzindo fricção no fluxo de busca.

<requirements>
- Layout centralizado com ilustração + texto + botões
- Texto em português explicando benefício
- Botão primário solicita permissão via LocationManager
- Botão secundário permite pular
- Dismiss automático após concessão
- Callbacks para comunicar resultado ao parent
</requirements>

## Subtarefas

- [ ] 11.1 Criar arquivo `LocationOnboardingView.swift` em `ChooseThere/Presentation/Views/`
- [ ] 11.2 Definir struct LocationOnboardingView: View
- [ ] 11.3 Adicionar properties: locationManager, onPermissionGranted closure, onSkip closure
- [ ] 11.4 Adicionar @Environment(\.dismiss) para fechar view
- [ ] 11.5 Implementar VStack principal com Spacers
- [ ] 11.6 Adicionar SF Symbol "location.circle.fill" (80pt, primary color, hierarchical)
- [ ] 11.7 Adicionar título com font .title2.weight(.bold)
- [ ] 11.8 Adicionar descrição com multilineTextAlignment center
- [ ] 11.9 Implementar botão primário com async Task
- [ ] 11.10 Implementar botão secundário com dismiss
- [ ] 11.11 Aplicar padding e styling
- [ ] 11.12 Criar #Preview

## Detalhes de Implementação

Consulte `techspec.md` seção "LocationOnboardingView" (linhas 415-485) para implementação completa.

**Properties:**
```swift
@Environment(\.dismiss) private var dismiss
let locationManager: LocationManager
let onPermissionGranted: () -> Void
let onSkip: () -> Void
```

**Layout principal:**
```swift
VStack(spacing: 24) {
  Spacer()

  // Ilustração
  Image(systemName: "location.circle.fill")
    .font(.system(size: 80))
    .foregroundColor(AppColors.primary)
    .symbolRenderingMode(.hierarchical)

  // Título
  Text("Descubra restaurantes perto de você")
    .font(.title2.weight(.bold))
    .foregroundColor(AppColors.textPrimary)
    .multilineTextAlignment(.center)

  // Descrição
  Text("Permitir acesso à localização ajuda a encontrar as melhores opções próximas")
    .font(.body)
    .foregroundColor(AppColors.textSecondary)
    .multilineTextAlignment(.center)
    .padding(.horizontal, 32)

  Spacer()

  // Botões
  VStack(spacing: 12) {
    // Botão primário
    // Botão secundário
  }
  .padding(.horizontal, 24)
  .padding(.bottom, 32)
}
```

**Botão primário (solicitar permissão):**
```swift
Button {
  Task {
    await locationManager.requestPermission()
    if locationManager.isAuthorized {
      onPermissionGranted()
      dismiss()
    }
  }
} label: {
  Text("Permitir localização")
    .font(.headline)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding()
    .background(AppColors.primary)
    .clipShape(RoundedRectangle(cornerRadius: 14))
}
```

**Botão secundário (pular):**
```swift
Button {
  onSkip()
  AppSettingsStorage.hasSkippedLocationOnboarding = true
  dismiss()
} label: {
  Text("Agora não")
    .font(.subheadline)
    .foregroundColor(AppColors.textSecondary)
}
```

## Critérios de Sucesso

- View compila e renderiza sem erros
- Layout é centralizado verticalmente com Spacers
- Ícone de localização aparece em 80pt com hierarchical rendering
- Título usa .title2.weight(.bold) em textPrimary
- Descrição tem padding horizontal 32pt e textAlignment center
- Botão primário é azul (AppColors.primary) com texto branco
- Ao tocar botão primário:
  - Solicita permissão via LocationManager
  - Se concedida: chama onPermissionGranted() e dismiss
  - Se negada: não dismiss (usuário pode tentar novamente)
- Ao tocar botão secundário:
  - Chama onSkip()
  - Seta hasSkippedLocationOnboarding = true
  - Dismiss view
- Botão secundário usa texto menor e cor secondary
- Preview mostra tela completa com mock LocationManager
- Código formatado com 2-space indentation
- Textos estão em português correto

## Arquivos relevantes
- Criar: `ChooseThere/Presentation/Views/LocationOnboardingView.swift`
- Referência: `ChooseThere/Services/LocationManager.swift` (existente)
- Referência: `ChooseThere/Data/AppSettingsStorage.swift` (hasSkippedLocationOnboarding)
- Referência: `AppColors.swift` (cores)
- Referência: `techspec.md` (linhas 415-485)
- Referência: `prd.md` (linhas 128-146 - FR5: Fluxo Proativo de Permissão)
