//
//  OnboardingView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftUI

struct OnboardingView: View {
  @Environment(AppRouter.self) private var router
  @State private var currentPage = 0

  private let slides: [OnboardingSlide] = [
    OnboardingSlide(
      icon: "tag.fill",
      iconColor: AppColors.primary,
      title: "Escolha suas preferências",
      description: "Selecione categorias e tags para filtrar restaurantes do seu jeito"
    ),
    OnboardingSlide(
      icon: "dice.fill",
      iconColor: AppColors.secondary,
      title: "Sorteie um restaurante",
      description: "Deixe a sorte escolher entre os melhores lugares de São Paulo"
    ),
    OnboardingSlide(
      icon: "star.fill",
      iconColor: AppColors.primary,
      title: "Avalie sua experiência",
      description: "Registre sua visita e ajude a refinar futuras escolhas"
    ),
    OnboardingSlide(
      icon: "clock.arrow.circlepath",
      iconColor: AppColors.accent,
      title: "Acompanhe seu histórico",
      description: "Veja todos os lugares visitados e suas avaliações"
    )
  ]

  var body: some View {
    ZStack {
      // Background gradient
      LinearGradient(
        colors: [AppColors.background, AppColors.surface],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      VStack(spacing: 0) {
        // Skip button
        HStack {
          Spacer()
          Button {
            completeOnboarding()
          } label: {
            Text("Pular")
              .font(.subheadline.weight(.medium))
              .foregroundStyle(AppColors.textSecondary)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)

        // Slides
        TabView(selection: $currentPage) {
          ForEach(slides.indices, id: \.self) { index in
            slideView(slide: slides[index])
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: currentPage)

        // Page indicator
        pageIndicator

        // Bottom button
        bottomButton
          .padding(.horizontal, 20)
          .padding(.bottom, 16)
      }
    }
  }

  // MARK: - Slide View

  private func slideView(slide: OnboardingSlide) -> some View {
    VStack(spacing: 32) {
      Spacer()

      // Animated icon container
      ZStack {
        // Background circle
        Circle()
          .fill(slide.iconColor.opacity(0.15))
          .frame(width: 160, height: 160)

        // Inner circle
        Circle()
          .fill(slide.iconColor.opacity(0.3))
          .frame(width: 120, height: 120)

        // Icon
        Image(systemName: slide.icon)
          .font(.system(size: 56, weight: .semibold))
          .foregroundStyle(slide.iconColor)
          .symbolEffect(.pulse, options: .repeating)
      }
      .padding(.bottom, 20)

      VStack(spacing: 16) {
        Text(slide.title)
          .font(.title.weight(.bold))
          .foregroundStyle(AppColors.textPrimary)
          .multilineTextAlignment(.center)

        Text(slide.description)
          .font(.body)
          .foregroundStyle(AppColors.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
      }

      Spacer()
      Spacer()
    }
    .padding(.horizontal, 20)
  }

  // MARK: - Page Indicator

  private var pageIndicator: some View {
    HStack(spacing: 8) {
      ForEach(slides.indices, id: \.self) { index in
        Capsule()
          .fill(index == currentPage ? AppColors.primary : AppColors.divider)
          .frame(width: index == currentPage ? 24 : 8, height: 8)
          .animation(.spring(response: 0.3), value: currentPage)
      }
    }
    .padding(.bottom, 32)
  }

  // MARK: - Bottom Button

  private var bottomButton: some View {
    Button {
      if currentPage < slides.count - 1 {
        withAnimation(.easeInOut(duration: 0.3)) {
          currentPage += 1
        }
      } else {
        completeOnboarding()
      }
    } label: {
      HStack {
        Text(currentPage < slides.count - 1 ? "Próximo" : "Começar")
          .font(.headline)

        if currentPage < slides.count - 1 {
          Image(systemName: "arrow.right")
            .font(.headline)
        }
      }
      .foregroundStyle(AppColors.textPrimary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    .accessibilityLabel(currentPage < slides.count - 1 ? "Ir para próximo slide" : "Começar a usar o app")
    .accessibilityHint(currentPage < slides.count - 1 ? "Avançar para a próxima explicação" : "Ir para a tela de preferências")
  }

  // MARK: - Helpers

  private func completeOnboarding() {
    OnboardingStorage.markAsSeen()
    router.reset(to: .mainTabs)
  }
}

// MARK: - Slide Model

private struct OnboardingSlide {
  let icon: String
  let iconColor: Color
  let title: String
  let description: String
}

#Preview {
  OnboardingView()
    .environment(AppRouter())
}
