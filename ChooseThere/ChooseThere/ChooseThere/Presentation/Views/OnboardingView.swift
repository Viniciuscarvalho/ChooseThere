import SwiftUI

struct OnboardingView: View {
  @Environment(AppRouter.self) private var router

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      VStack(alignment: .leading, spacing: 16) {
        Text("Como funciona")
          .font(.largeTitle.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)

        Text("Você escolhe preferências, sorteia, vai e avalia.")
          .font(.body)
          .foregroundStyle(AppColors.textSecondary)

        Spacer()

        Button {
          router.reset(to: .preferences)
        } label: {
          Text("Começar")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .accessibilityLabel("Começar a usar o app")
        .accessibilityHint("Ir para a tela de preferências")
      }
      .padding(20)
    }
  }
}

#Preview {
  OnboardingView()
    .environment(AppRouter())
}


