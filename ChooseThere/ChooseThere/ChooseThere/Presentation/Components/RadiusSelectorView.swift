//
//  RadiusSelectorView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 01/01/26.
//

import SwiftUI

/// Seletor de raio de busca (1km, 3km, 5km, 10km)
struct RadiusSelectorView: View {
  @Binding var selectedRadius: Int
  let options: [Int] = [1, 3, 5, 10]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Raio de busca")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)
        .accessibilityAddTraits(.isHeader)

      HStack(spacing: 8) {
        ForEach(options, id: \.self) { km in
          let isSelected = selectedRadius == km
          Button {
            selectedRadius = km
          } label: {
            Text("\(km)km")
              .font(.subheadline.weight(.medium))
              .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
              .padding(.horizontal, 14)
              .frame(minHeight: 44)
              .background(
                isSelected ? AppColors.primary : AppColors.surface,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
          .accessibilityLabel("\(km) quilômetros")
          .accessibilityHint(isSelected ? "Raio selecionado" : "Toque duas vezes para selecionar este raio")
          .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Selecionar raio de busca")
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .shadow(color: AppColors.divider.opacity(0.3), radius: 2, y: 1)
  }
}

