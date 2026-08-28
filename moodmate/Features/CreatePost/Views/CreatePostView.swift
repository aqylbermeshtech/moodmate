//
//  CreatePostView.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreatePostViewModel()

    var onPostPublished: ((PostModel) -> Void)? = nil

    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        userHeaderView

                        PostTextEditor(
                            text: $viewModel.text,
                            placeholder: placeholderText,
                            maxLength: 500
                        )

                        PhotoAttachmentView(
                            images: $viewModel.selectedImages,
                            onAddPhotoTap: {
                                viewModel.showPhotoOptionsActionSheet = true
                            },
                            onRemovePhoto: { index in
                                viewModel.removeImage(at: index)
                            },
                            onReplacePhoto: { index in
                                viewModel.showPhotoOptionsActionSheet = true
                            }
                        )

                        VisibilitySelector(selectedVisibility: $viewModel.visibility)
                            .padding(.top, 4)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)

                if viewModel.showSuccessAnimation {
                    successOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        viewModel.handleCancelTap {
                            dismiss()
                        }
                    }) {
                        Text("Cancel")
                            .font(.xHandle)
                            .foregroundStyle(Color.theme.primaryText)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.publishPost { publishedPost in
                            onPostPublished?(publishedPost)
                            dismiss()
                        }
                    } label: {
                        Text("Post")
                            .font(.xButton)
                            .foregroundStyle(viewModel.isValid ? .black : Color.theme.secondaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(
                                    viewModel.isValid
                                        ? Color.theme.primaryText
                                        : Color.theme.secondaryBackground
                                )
                            )
                    }
                    .disabled(!viewModel.isValid || viewModel.isPublishing)
                    .buttonStyle(XPressableStyle())
                }
            }
            .confirmationDialog("Add Photo", isPresented: $viewModel.showPhotoOptionsActionSheet, titleVisibility: .visible) {
                Button("Photo Preset / Sample Photo") {
                    viewModel.addSamplePhoto()
                }

                Button("Photo Library") {
                    viewModel.showImagePicker = true
                }

                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(isPresented: $viewModel.showImagePicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    do {
                        if let data = try await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                viewModel.addImage(uiImage)
                                selectedPhotoItem = nil
                            }
                        }
                    } catch {
                        await MainActor.run {
                            viewModel.errorMessage = "Couldn't load that photo. Please try another one."
                        }
                    }
                }
            }
            .errorAlert($viewModel.errorMessage)
            .confirmationDialog("Unsaved Post", isPresented: $viewModel.showDiscardDraftAlert, titleVisibility: .visible) {
                Button("Save Draft") {
                    viewModel.saveDraft()
                    dismiss()
                }
                Button("Discard Post", role: .destructive) {
                    viewModel.clearDraft()
                    dismiss()
                }
                Button("Continue Editing", role: .cancel) {}
            } message: {
                Text("What would you like to do with your changes?")
            }
        }
        .presentationDragIndicator(.hidden)
    }

    // MARK: - User Header View
    private var userHeaderView: some View {
        HStack(spacing: 12) {
            AvatarView(
                imageData: viewModel.currentUser.avatarImageData,
                name: viewModel.currentUser.name,
                colorHex: viewModel.currentUser.avatarColorHex,
                size: 40,
                showBorder: false
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(viewModel.currentUser.name)
                        .font(.xDisplayName)
                        .foregroundStyle(Color.theme.primaryText)

                    Text("@\(viewModel.currentUser.username)")
                        .font(.xHandle)
                        .foregroundStyle(Color.theme.secondaryText)
                }

                HStack(spacing: 4) {
                    Image(systemName: viewModel.visibility.iconName)
                        .font(.system(size: 11))
                    Text(viewModel.visibility.rawValue)
                        .font(.xTrendingMeta)
                }
                .foregroundStyle(Color.theme.secondaryText)
            }

            Spacer()
        }
    }

    private var placeholderText: String {
        "What's happening?"
    }

    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.theme.accent)
                        .frame(width: 72, height: 72)

                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(viewModel.showSuccessAnimation ? 1.0 : 0.4)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.showSuccessAnimation)

                Text("Post Published!")
                    .font(.xScreenTitle)
                    .foregroundStyle(Color.theme.primaryText)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.theme.secondaryBackground)
            )
        }
        .transition(.opacity)
    }
}

#Preview {
    CreatePostView()
}
