//
//  LottieView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/29/25.
//

import SwiftUI
import Lottie

// MARK: - LottieView

/// Wrapper SwiftUI para LottieAnimationView
struct LottieView: UIViewRepresentable {
  // MARK: - Properties

  let animationName: String
  var loopMode: LottieLoopMode = .loop
  var animationSpeed: CGFloat = 1.0

  // MARK: - UIViewRepresentable

  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)

    let animationView = LottieAnimationView(name: animationName)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = loopMode
    animationView.animationSpeed = animationSpeed
    animationView.play()

    animationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(animationView)

    NSLayoutConstraint.activate([
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    // Atualização se necessário
  }
}

// MARK: - Convenience Modifiers

extension LottieView {
  /// Define o modo de loop da animação
  func loopMode(_ mode: LottieLoopMode) -> LottieView {
    var view = self
    view.loopMode = mode
    return view
  }

  /// Define a velocidade da animação
  func speed(_ speed: CGFloat) -> LottieView {
    var view = self
    view.animationSpeed = speed
    return view
  }
}

