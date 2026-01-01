//
//  ShimmerView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/30/25.
//

import SwiftUI

/// Efeito shimmer para skeleton loading, inspirado em Deliverio.
/// Usado como placeholder enquanto imagens/dados estão carregando.
struct ShimmerView: View {
  // MARK: - State
  
  @State private var phase: CGFloat = 0
  
  // MARK: - Configuration
  
  let cornerRadius: CGFloat
  
  init(cornerRadius: CGFloat = 0) {
    self.cornerRadius = cornerRadius
  }
  
  // MARK: - Body
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Base color
        AppColors.divider
        
        // Shimmer gradient
        LinearGradient(
          gradient: Gradient(colors: [
            Color.clear,
            Color.white.opacity(0.4),
            Color.clear
          ]),
          startPoint: .leading,
          endPoint: .trailing
        )
        .frame(width: geometry.size.width * 0.6)
        .offset(x: -geometry.size.width + (phase * geometry.size.width * 2.2))
        .blur(radius: 2)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    .onAppear {
      withAnimation(
        .linear(duration: 1.2)
        .repeatForever(autoreverses: false)
      ) {
        phase = 1
      }
    }
  }
}

/// Placeholder de imagem com shimmer e ícone de fallback.
/// Estilo clean inspirado em Deliverio.
struct ImagePlaceholder: View {
  enum Style {
    case loading    // Shimmer animado
    case empty      // Placeholder estático com ícone
    case error      // Fallback após erro
  }
  
  let style: Style
  let cornerRadius: CGFloat
  let icon: String
  
  init(style: Style = .empty, cornerRadius: CGFloat = 0, icon: String = "photo") {
    self.style = style
    self.cornerRadius = cornerRadius
    self.icon = icon
  }
  
  var body: some View {
    ZStack {
      switch style {
      case .loading:
        ShimmerView(cornerRadius: cornerRadius)
        
      case .empty, .error:
        // Background gradiente suave
        LinearGradient(
          colors: [
            AppColors.divider,
            AppColors.divider.opacity(0.7)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        
        // Ícone centralizado
        VStack(spacing: 6) {
          Image(systemName: icon)
            .font(.system(size: 28, weight: .light))
            .foregroundStyle(AppColors.textSecondary.opacity(0.4))
          
          if style == .error {
            Text("Imagem indisponível")
              .font(.caption2)
              .foregroundStyle(AppColors.textSecondary.opacity(0.5))
          }
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }
}

// MARK: - Preview

#Preview("Shimmer") {
  VStack(spacing: 20) {
    ShimmerView(cornerRadius: 12)
      .frame(height: 120)
    
    ImagePlaceholder(style: .loading, cornerRadius: 12)
      .frame(height: 120)
    
    ImagePlaceholder(style: .empty, cornerRadius: 12, icon: "fork.knife")
      .frame(height: 120)
    
    ImagePlaceholder(style: .error, cornerRadius: 12)
      .frame(height: 120)
  }
  .padding()
  .background(AppColors.background)
}


