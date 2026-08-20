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

                        MoodPickerCard(
                            selectedMoodEmoji: viewModel.selectedMoodEmoji,
                            selectedMoodText: viewModel.selectedMoodText,
                            selectedMoodColorHex: viewModel.selectedMoodColorHex,
                            onTap: {
                                viewModel.showMoodPickerSheet = true
                            }
                        )

                        PostTextEditor(
                            text: $viewModel.text,
                            placeholder: placeholderText,
                            maxLength: 500,
                            onEmojiSelected: { emoji in
                                viewModel.appendEmoji(emoji)
                            }
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
            .sheet(isPresented: $viewModel.showMoodPickerSheet) {
                moodPickerSheet
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.visible)
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
        if let text = viewModel.selectedMoodText {
            return "Describe why you're feeling \(text.lowercased()) today..."
        }
        return "What's happening?"
    }

    // MARK: - Mood Picker Sheet View
    private var moodPickerSheet: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Select your mood")
                    .font(.xScreenTitle)
                    .foregroundStyle(Color.theme.primaryText)
                Text("This will highlight your post on MoodMate")
                    .font(.xTrendingMeta)
                    .foregroundStyle(Color.theme.secondaryText)
            }
            .padding(.top, 16)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 95, maximum: 110), spacing: 14)], spacing: 14) {
                ForEach(viewModel.moodOptions) { option in
                    let isSelected = viewModel.selectedMoodEmoji == option.emoji

                    Button {
                        viewModel.selectMood(emoji: option.emoji, text: option.text, colorHex: option.colorHex)
                        viewModel.showMoodPickerSheet = false
                    } label: {
                        VStack(spacing: 10) {
                            Text(option.emoji)
                                .font(.system(size: 36))

                            Text(option.text)
                                .font(.xDisplayName)
                                .foregroundStyle(Color.theme.primaryText)
                        }
                        .frame(width: 95, height: 95)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? Color.theme.accent.opacity(0.15) : Color.theme.secondaryBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    isSelected ? Color.theme.accent : Color.theme.divider,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(XPressableStyle())
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.theme.primaryBackground)
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
