# Instruções para Adicionar Lottie via SPM

## 1. Adicionar Pacote Lottie via Swift Package Manager

1. Abra o projeto `ChooseThere.xcodeproj` no Xcode
2. No menu superior, clique em **File** → **Add Package Dependencies...**
3. Cole a URL do repositório:
   ```
   https://github.com/airbnb/lottie-ios.git
   ```
4. Clique em **Add Package**
5. Na próxima tela, selecione:
   - **Lottie** (não marque "Lottie (Dynamic Library)")
   - Target: **ChooseThere**
6. Clique em **Add Package**

## 2. Verificar Arquivo JSON no Projeto

1. Certifique-se de que o arquivo `FoodChoice.json` está presente em:
   ```
   ChooseThere/ChooseThere/ChooseThere/Resources/FoodChoice.json
   ```
2. Se não estiver, arraste o arquivo para a pasta `Resources` no Xcode
3. Na janela que aparece, certifique-se de que:
   - ✅ **"Copy items if needed"** está marcado
   - ✅ Target **ChooseThere** está selecionado
   - Clique em **Finish**

## 3. Verificar Build Settings

1. No Xcode, selecione o target **ChooseThere**
2. Vá para **Build Phases**
3. Em **Copy Bundle Resources**, verifique se `FoodChoice.json` está listado
4. Se não estiver, clique no **+** e adicione o arquivo

## 4. Testar a Animação

1. Compile e execute o app
2. A animação de loading deve aparecer por 1.5 segundos ao iniciar o app
3. Após o loading, o app navega para a tela principal ou onboarding

## Arquivos Criados/Modificados

- ✅ `Resources/FoodChoice.json` - Arquivo de animação Lottie
- ✅ `Presentation/Components/LottieView.swift` - Wrapper SwiftUI para Lottie
- ✅ `Presentation/Views/LoadingView.swift` - View de loading com animação
- ✅ `Application/RootView.swift` - Integração do loading screen

## Versão do Lottie

Recomendado: **4.3.4** ou superior

## Notas

- A animação está configurada para loop infinito
- O loading screen aparece por 1.5 segundos (pode ser ajustado em `RootView.checkInitialRoute()`)
- Se quiser remover o texto "Carregando...", basta remover essa linha do `LoadingView`

