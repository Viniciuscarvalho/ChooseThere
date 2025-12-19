//
//  BackButton.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/19/25.
//

import SwiftUI

/// Estilo do botão de voltar baseado no contexto
enum BackButtonStyle {
  /// Sobre mapa/imagem: ícone branco com material blur
  case onMap
  /// Sobre fundo de superfície: ícone secundário com borda
  case onSurface
}

/// Componente reutilizável de botão voltar
struct BackButton: View {
  let action: () -> Void
  var style: BackButtonStyle = .onSurface
  
  var body: some View {
    Button(action: action) {
      buttonContent
    }
    .accessibilityLabel("Voltar")
    .accessibilityHint("Toque para retornar à tela anterior")
  }
  
  @ViewBuilder
  private var buttonContent: some View {
    switch style {
    case .onMap:
      Image(systemName: "chevron.left")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 44, height: 44)
        .background(.ultraThinMaterial, in: Circle())
        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
      
    case .onSurface:
      Image(systemName: "chevron.left")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(AppColors.textSecondary)
        .frame(width: 44, height: 44)
        .background(AppColors.surface, in: Circle())
        .overlay(
          Circle()
            .stroke(AppColors.divider, lineWidth: 1)
        )
    }
  }
}

// MARK: - Preview

#Preview("On Map Style") {
  ZStack {
    // Simulated map background
    LinearGradient(
      colors: [.gray, .gray.opacity(0.5)],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
    
    BackButton(action: {}, style: .onMap)
  }
}

#Preview("On Surface Style") {
  ZStack {
    AppColors.background
      .ignoresSafeArea()
    
    BackButton(action: {}, style: .onSurface)
  }
}
