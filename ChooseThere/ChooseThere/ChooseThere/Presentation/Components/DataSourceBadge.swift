//
//  DataSourceBadge.swift
//  ChooseThere
//
//  Created by Claude on 2026-01-17.
//

import SwiftUI

/// Badge que indica a fonte de dados (Minha Base ou Apple Maps)
struct DataSourceBadge: View {
  let source: DataSource
  @State private var showTooltip = false

  var body: some View {
    Button {
      showTooltip.toggle()
    } label: {
      HStack(spacing: 4) {
        Image(systemName: source.badgeIcon)
          .font(.system(size: 9, weight: .medium))
        Text(source.displayName)
          .font(.system(size: 11, weight: .medium))
      }
      .foregroundColor(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(source.badgeColor)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
    .popover(isPresented: $showTooltip) {
      Text(source.tooltipText)
        .font(.caption)
        .padding()
        .presentationCompactAdaptation(.popover)
    }
    .accessibilityLabel("Fonte: \(source.displayName)")
    .accessibilityHint("Toque para mais informações")
  }
}

// MARK: - Preview

#Preview("Local Base") {
  DataSourceBadge(source: .localBase)
    .padding()
    .background(AppColors.surface)
}

#Preview("Apple Maps") {
  DataSourceBadge(source: .appleMaps)
    .padding()
    .background(AppColors.surface)
}
