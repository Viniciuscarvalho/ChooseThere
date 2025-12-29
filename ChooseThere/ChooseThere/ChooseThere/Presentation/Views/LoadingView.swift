//
//  LoadingView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import Lottie
import SwiftUI

// MARK: - LoadingView

/// View de carregamento com animação Lottie
struct LoadingView: View {
  // MARK: - Body

  var body: some View {
    ZStack {
      AppColors.background
        .ignoresSafeArea()

      VStack(spacing: 24) {
        // Animação Lottie
        LottieView(animationName: "FoodChoice")
          .loopMode(.loop)
          .frame(width: 200, height: 200)

        // Texto opcional (pode ser removido se não necessário)
        Text("Carregando...")
          .font(.subheadline)
          .foregroundStyle(AppColors.textSecondary)
      }
    }
  }
}

// MARK: - Preview

#Preview {
  LoadingView()
}

