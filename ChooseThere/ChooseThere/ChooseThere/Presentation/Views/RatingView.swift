//
//  RatingView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftData
import SwiftUI

struct RatingView: View {
  let restaurantId: String

  @Environment(AppRouter.self) private var router
  @Environment(\.modelContext) private var modelContext

  @State private var viewModel: RatingViewModel?
  @FocusState private var isNoteFieldFocused: Bool

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()

      if let vm = viewModel {
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            headerSection

            ratingSection(vm: vm)

            matchSection(vm: vm)

            wouldReturnSection(vm: vm)

            quickTagsSection(vm: vm)

            noteSection(vm: vm)

            if let error = vm.errorMessage {
              errorBanner(message: error)
            }

            Spacer(minLength: 80)
          }
          .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
          isNoteFieldFocused = false
        }
        .safeAreaInset(edge: .bottom) {
          saveButton(vm: vm)
        }
      } else {
        ProgressView()
          .tint(AppColors.primary)
      }
    }
    .onAppear {
      initializeViewModel()
    }
  }

  // MARK: - Sections

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        BackButton(action: { router.popOverlay() }, style: .onSurface)
        
        Spacer()
      }
      .padding(.bottom, 8)
      
      Text("Como foi a visita?")
        .font(.title2.weight(.bold))
        .foregroundStyle(AppColors.textPrimary)

      Text("Deixe sua avaliação para lembrar depois.")
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
    }
  }

  private func ratingSection(vm: RatingViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Nota")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      HStack(spacing: 12) {
        ForEach(1...5, id: \.self) { value in
          Button {
            vm.rating = value
          } label: {
            Image(systemName: vm.rating >= value ? "star.fill" : "star")
              .font(.title)
              .foregroundStyle(vm.rating >= value ? AppColors.primary : AppColors.textSecondary)
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Nota \(value) de 5 estrelas")
          .accessibilityHint("Toque para dar nota \(value)")
          .accessibilityAddTraits(vm.rating == value ? .isSelected : [])
        }
      }
    }
  }

  private func matchSection(vm: RatingViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Foi match pro gosto dela?")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)

          Text("Marque se ela aprovou!")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        Toggle("", isOn: Binding(
          get: { vm.isMatch },
          set: { vm.isMatch = $0 }
        ))
        .labelsHidden()
        .tint(AppColors.success)
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(vm.isMatch ? AppColors.success.opacity(0.1) : AppColors.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(vm.isMatch ? AppColors.success : AppColors.divider, lineWidth: 1)
      )
    }
  }

  private func wouldReturnSection(vm: RatingViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Voltaria?")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)

          Text("Quer ir de novo no futuro?")
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }

        Spacer()

        Toggle("", isOn: Binding(
          get: { vm.wouldReturn },
          set: { vm.wouldReturn = $0 }
        ))
        .labelsHidden()
        .tint(AppColors.accent)
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(vm.wouldReturn ? AppColors.accent.opacity(0.1) : AppColors.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(vm.wouldReturn ? AppColors.accent : AppColors.divider, lineWidth: 1)
      )
    }
  }

  private func quickTagsSection(vm: RatingViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Tags rápidas")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      FlowLayout(spacing: 8) {
        ForEach(RatingViewModel.quickTags, id: \.self) { tag in
          TagChip(
            label: tag,
            isSelected: vm.selectedTags.contains(tag)
          ) {
            vm.toggleTag(tag)
          }
        }
      }
    }
  }

  private func noteSection(vm: RatingViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Comentário (opcional)")
        .font(.headline)
        .foregroundStyle(AppColors.textPrimary)

      TextField("Ex.: O yakitori estava incrível!", text: Binding(
        get: { vm.note },
        set: { vm.note = $0 }
      ), axis: .vertical)
      .lineLimit(3...6)
      .textFieldStyle(.plain)
      .focused($isNoteFieldFocused)
      .submitLabel(.done)
      .onSubmit {
        isNoteFieldFocused = false
      }
      .padding(14)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(isNoteFieldFocused ? AppColors.primary : AppColors.divider, lineWidth: isNoteFieldFocused ? 2 : 1)
      )
      .animation(.easeInOut(duration: 0.2), value: isNoteFieldFocused)
    }
  }

  private func errorBanner(message: String) -> some View {
    HStack {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundStyle(AppColors.error)

      Text(message)
        .font(.subheadline)
        .foregroundStyle(AppColors.error)
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColors.error.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
  }

  private func saveButton(vm: RatingViewModel) -> some View {
    Button {
      if vm.save() {
        // Após salvar, volta para tabs e muda para histórico
        router.dismissAllOverlays()
        Tab.history.select()
      }
    } label: {
      HStack {
        if vm.isSaving {
          ProgressView()
            .tint(AppColors.textPrimary)
        } else {
          Image(systemName: vm.isMatch ? "heart.fill" : "checkmark")
          Text("Salvar avaliação")
        }
      }
      .font(.headline)
      .foregroundStyle(AppColors.textPrimary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        vm.isMatch ? AppColors.success : AppColors.primary,
        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
    }
    .disabled(!vm.canSave || vm.isSaving)
    .opacity(vm.canSave ? 1 : 0.6)
    .padding(.horizontal, 20)
    .padding(.bottom, 8)
    .background(AppColors.background)
    .accessibilityLabel("Salvar avaliação")
  }

  // MARK: - Helpers

  private func initializeViewModel() {
    guard viewModel == nil else { return }
    let visitRepo = SwiftDataVisitRepository(context: modelContext)
    let restaurantRepo = SwiftDataRestaurantRepository(context: modelContext)
    let ratingAggregator = RestaurantRatingAggregator(
      visitRepository: visitRepo,
      restaurantRepository: restaurantRepo
    )
    viewModel = RatingViewModel(
      restaurantId: restaurantId,
      visitRepository: visitRepo,
      ratingAggregator: ratingAggregator,
      restaurantRepository: restaurantRepo
    )
  }
}

#Preview {
  RatingView(restaurantId: "izakaya-matsu")
    .environment(AppRouter())
    .modelContainer(for: [RestaurantModel.self, VisitModel.self], inMemory: true)
}
