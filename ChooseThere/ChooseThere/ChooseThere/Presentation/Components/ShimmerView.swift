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

// MARK: - Category Theme

/// Temas visuais por categoria de restaurante para placeholders atraentes
enum CategoryTheme {
  case japanese
  case italian
  case coffee
  case burger
  case bar
  case bbq
  case vegetarian
  case dessert
  case mexican
  case seafood
  case chinese
  case indian
  case arabic
  case brazilian
  case fineDining
  case brunch
  case general

  // MARK: - Factory

  static func from(category: String) -> CategoryTheme {
    let lowercased = category.lowercased()

    switch lowercased {
    // Japanese variations
    case let c where c.contains("japonês") || c.contains("japanese") || c.contains("japan") || c.contains("sushi") || c.contains("ramen") || c.contains("temaki") || c.contains("izakaya"):
      return .japanese

    // Italian variations
    case let c where c.contains("italiano") || c.contains("italian") || c.contains("pizza") || c.contains("pasta") || c.contains("massas"):
      return .italian

    // Coffee/Cafe/Dessert variations
    case let c where c.contains("café") || c.contains("cafe") || c.contains("coffee") || c.contains("padaria") || c.contains("bakery") || c.contains("confeitaria") || c.contains("dessert"):
      return .coffee

    // Burger/Fast food variations
    case let c where c.contains("burger") || c.contains("hamburguer") || c.contains("lanche") || c.contains("fast"):
      return .burger

    // Bar variations
    case let c where c.contains("bar") || c.contains("drink") || c.contains("cerveja") || c.contains("pub") || c.contains("boteco") || c.contains("botequim"):
      return .bar

    // BBQ/Grill variations
    case let c where c.contains("churrasco") || c.contains("carne") || c.contains("bbq") || c.contains("steakhouse") || c.contains("grill"):
      return .bbq

    // Vegetarian variations
    case let c where c.contains("vegetariano") || c.contains("vegan") || c.contains("salada") || c.contains("natural") || c.contains("organico"):
      return .vegetarian

    // Dessert variations
    case let c where c.contains("doce") || c.contains("sobremesa") || c.contains("sorvete") || c.contains("acai") || c.contains("gelato"):
      return .dessert

    // Mexican variations
    case let c where c.contains("mexicano") || c.contains("tex-mex") || c.contains("taco") || c.contains("burrito"):
      return .mexican

    // Seafood variations
    case let c where c.contains("frutos do mar") || c.contains("seafood") || c.contains("peixe") || c.contains("marisco"):
      return .seafood

    // Chinese variations
    case let c where c.contains("chines") || c.contains("chinese") || c.contains("oriental"):
      return .chinese

    // Indian variations
    case let c where c.contains("indiano") || c.contains("indian") || c.contains("curry"):
      return .indian

    // Arabic/Mediterranean variations
    case let c where c.contains("arabe") || c.contains("arab") || c.contains("libanes") || c.contains("sirio") || c.contains("mediterranean"):
      return .arabic

    // Brazilian variations (new)
    case let c where c.contains("brasileira") || c.contains("brazilian") || c.contains("nordestino") || c.contains("mineiro") || c.contains("baiano"):
      return .brazilian

    // Fine dining/Contemporary (new)
    case let c where c.contains("contemporary") || c.contains("fine") || c.contains("gastronomico"):
      return .fineDining

    // Brunch (new)
    case let c where c.contains("brunch") || c.contains("breakfast"):
      return .brunch

    default:
      return .general
    }
  }

  // MARK: - Visual Properties

  /// Cor primária do tema
  var primaryColor: Color {
    switch self {
    case .japanese:
      return Color(hex: 0xE74C3C) // Vermelho tradicional japonês
    case .italian:
      return Color(hex: 0x27AE60) // Verde italiano
    case .coffee:
      return Color(hex: 0x8B4513) // Marrom café
    case .burger:
      return Color(hex: 0xE67E22) // Laranja burger
    case .bar:
      return Color(hex: 0x9B59B6) // Roxo noturno
    case .bbq:
      return Color(hex: 0xC0392B) // Vermelho fogo
    case .vegetarian:
      return Color(hex: 0x2ECC71) // Verde vibrante
    case .dessert:
      return Color(hex: 0xF1C40F) // Amarelo doce
    case .mexican:
      return Color(hex: 0xE74C3C) // Vermelho mexicano
    case .seafood:
      return Color(hex: 0x3498DB) // Azul oceano
    case .chinese:
      return Color(hex: 0xC0392B) // Vermelho chinês
    case .indian:
      return Color(hex: 0xD35400) // Laranja especiarias
    case .arabic:
      return Color(hex: 0xD4AC0D) // Dourado arabe
    case .brazilian:
      return Color(hex: 0x009739) // Verde Brasil
    case .fineDining:
      return Color(hex: 0x1A1A2E) // Azul escuro elegante
    case .brunch:
      return Color(hex: 0xF39C12) // Laranja sol
    case .general:
      return AppColors.primary
    }
  }

  /// Cor secundaria do tema para gradientes
  var secondaryColor: Color {
    switch self {
    case .japanese:
      return Color(hex: 0xFFB7C5) // Rosa sakura
    case .italian:
      return Color(hex: 0xE74C3C) // Vermelho tomate
    case .coffee:
      return Color(hex: 0xD2B48C) // Bege creme
    case .burger:
      return Color(hex: 0xF39C12) // Amarelo mostarda
    case .bar:
      return Color(hex: 0x2C3E50) // Azul escuro
    case .bbq:
      return Color(hex: 0xE67E22) // Laranja brasa
    case .vegetarian:
      return Color(hex: 0x27AE60) // Verde folha
    case .dessert:
      return Color(hex: 0xE74C3C) // Rosa morango
    case .mexican:
      return Color(hex: 0xF1C40F) // Amarelo limao
    case .seafood:
      return Color(hex: 0x1ABC9C) // Verde agua
    case .chinese:
      return Color(hex: 0xF1C40F) // Dourado
    case .indian:
      return Color(hex: 0xF39C12) // Amarelo acafrao
    case .arabic:
      return Color(hex: 0x7D3C98) // Roxo berinjela
    case .brazilian:
      return Color(hex: 0xFEDF00) // Amarelo Brasil
    case .fineDining:
      return Color(hex: 0xD4AF37) // Dourado elegante
    case .brunch:
      return Color(hex: 0xFFE5B4) // Peach suave
    case .general:
      return AppColors.accent
    }
  }

  /// Icone SF Symbol representativo
  var icon: String {
    switch self {
    case .japanese:
      return "fish.fill"
    case .italian:
      return "fork.knife"
    case .coffee:
      return "cup.and.saucer.fill"
    case .burger:
      return "takeoutbag.and.cup.and.straw.fill"
    case .bar:
      return "wineglass.fill"
    case .bbq:
      return "flame.fill"
    case .vegetarian:
      return "leaf.fill"
    case .dessert:
      return "birthday.cake.fill"
    case .mexican:
      return "flame.fill"
    case .seafood:
      return "fish.fill"
    case .chinese:
      return "takeoutbag.and.cup.and.straw.fill"
    case .indian:
      return "flame.fill"
    case .arabic:
      return "star.fill"
    case .brazilian:
      return "leaf.fill"
    case .fineDining:
      return "star.fill"
    case .brunch:
      return "sun.max.fill"
    case .general:
      return "fork.knife"
    }
  }

  /// Icone secundario decorativo
  var decorativeIcon: String {
    switch self {
    case .japanese:
      return "leaf.fill"
    case .italian:
      return "leaf.fill"
    case .coffee:
      return "leaf.fill"
    case .burger:
      return "star.fill"
    case .bar:
      return "sparkles"
    case .bbq:
      return "smoke.fill"
    case .vegetarian:
      return "carrot.fill"
    case .dessert:
      return "heart.fill"
    case .mexican:
      return "sun.max.fill"
    case .seafood:
      return "water.waves"
    case .chinese:
      return "star.fill"
    case .indian:
      return "sparkles"
    case .arabic:
      return "moon.fill"
    case .brazilian:
      return "star.fill"
    case .fineDining:
      return "sparkles"
    case .brunch:
      return "cup.and.saucer.fill"
    case .general:
      return "sparkle"
    }
  }
}

// MARK: - Category Placeholder View

/// Placeholder visual rico baseado na categoria do restaurante
struct CategoryPlaceholderView: View {
  let category: String
  let showLabel: Bool

  init(category: String, showLabel: Bool = false) {
    self.category = category
    self.showLabel = showLabel
  }

  private var theme: CategoryTheme {
    CategoryTheme.from(category: category)
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Gradiente de fundo temático
        LinearGradient(
          colors: [
            theme.primaryColor.opacity(0.18),
            theme.secondaryColor.opacity(0.12),
            theme.primaryColor.opacity(0.08)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        // Padrão decorativo com formas geométricas
        decorativePattern(in: geometry)

        // Ícone central com efeito visual
        VStack(spacing: 8) {
          ZStack {
            // Círculo de fundo suave
            Circle()
              .fill(theme.primaryColor.opacity(0.12))
              .frame(width: 56, height: 56)

            // Ícone principal
            Image(systemName: theme.icon)
              .font(.system(size: 24, weight: .medium))
              .foregroundStyle(theme.primaryColor.opacity(0.7))
          }

          // Label opcional da categoria
          if showLabel {
            Text(formatCategory(category))
              .font(.caption.weight(.medium))
              .foregroundStyle(theme.primaryColor.opacity(0.6))
              .lineLimit(1)
          }
        }
      }
    }
  }

  // MARK: - Decorative Pattern

  @ViewBuilder
  private func decorativePattern(in geometry: GeometryProxy) -> some View {
    let width = geometry.size.width
    let height = geometry.size.height

    // Elementos decorativos posicionados estrategicamente
    ZStack {
      // Círculo grande no canto superior direito
      Circle()
        .fill(theme.primaryColor.opacity(0.08))
        .frame(width: width * 0.5, height: width * 0.5)
        .offset(x: width * 0.35, y: -height * 0.15)

      // Círculo médio no canto inferior esquerdo
      Circle()
        .fill(theme.secondaryColor.opacity(0.06))
        .frame(width: width * 0.35, height: width * 0.35)
        .offset(x: -width * 0.25, y: height * 0.25)

      // Ícone decorativo pequeno no canto superior esquerdo
      Image(systemName: theme.decorativeIcon)
        .font(.system(size: 14, weight: .light))
        .foregroundStyle(theme.secondaryColor.opacity(0.25))
        .offset(x: -width * 0.32, y: -height * 0.32)

      // Ícone decorativo pequeno no canto inferior direito
      Image(systemName: theme.decorativeIcon)
        .font(.system(size: 10, weight: .light))
        .foregroundStyle(theme.primaryColor.opacity(0.2))
        .offset(x: width * 0.35, y: height * 0.35)
    }
    .clipped()
  }

  private func formatCategory(_ category: String) -> String {
    category
      .replacingOccurrences(of: "-", with: " ")
      .capitalized
  }
}

// MARK: - Image Placeholder (Enhanced)

/// Placeholder de imagem com shimmer e ícone de fallback.
/// Estilo clean inspirado em Deliverio com suporte a temas por categoria.
struct ImagePlaceholder: View {
  enum Style {
    case loading    // Shimmer animado
    case empty      // Placeholder estático com ícone
    case error      // Fallback após erro
    case category(String)  // Placeholder temático baseado na categoria
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

      case .category(let categoryName):
        CategoryPlaceholderView(category: categoryName)

      case .empty:
        // Background gradiente suave
        LinearGradient(
          colors: [
            AppColors.divider,
            AppColors.divider.opacity(0.7)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        // Icone centralizado
        VStack(spacing: 6) {
          Image(systemName: icon)
            .font(.system(size: 28, weight: .light))
            .foregroundStyle(AppColors.textSecondary.opacity(0.4))
        }

      case .error:
        // Background gradiente suave
        LinearGradient(
          colors: [
            AppColors.divider,
            AppColors.divider.opacity(0.7)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        // Icone centralizado com mensagem de erro
        VStack(spacing: 6) {
          Image(systemName: icon)
            .font(.system(size: 28, weight: .light))
            .foregroundStyle(AppColors.textSecondary.opacity(0.4))

          Text("Imagem indisponivel")
            .font(.caption2)
            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }
}

// MARK: - Preview

#Preview("Shimmer & Placeholders") {
  ScrollView {
    VStack(spacing: 20) {
      Text("Loading States")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)

      ShimmerView(cornerRadius: 12)
        .frame(height: 120)

      ImagePlaceholder(style: .loading, cornerRadius: 12)
        .frame(height: 120)

      Text("Category Placeholders")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        ForEach([
          "japanese", "italian", "cafe-dessert", "burger",
          "bar", "brasileira", "contemporary-fine", "brunch",
          "arab-mediterranean", "Frutos do mar", "Vegetariano", "Sobremesa"
        ], id: \.self) { category in
          VStack(spacing: 4) {
            ImagePlaceholder(style: .category(category), cornerRadius: 12)
              .frame(height: 100)
            Text(category.capitalized)
              .font(.caption)
              .foregroundStyle(AppColors.textSecondary)
          }
        }
      }

      Text("Fallback States")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)

      ImagePlaceholder(style: .empty, cornerRadius: 12, icon: "fork.knife")
        .frame(height: 120)

      ImagePlaceholder(style: .error, cornerRadius: 12)
        .frame(height: 120)
    }
    .padding()
  }
  .background(AppColors.background)
}


