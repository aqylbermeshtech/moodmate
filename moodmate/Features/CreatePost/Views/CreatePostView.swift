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
                // Dynamic Mood-Tinted Ambient Background
                Color.theme.primaryBackground
                    .ignoresSafeArea()
                
                // Subtle dynamic mood glow overlay
                RadialGradient(
                    colors: [
                        viewModel.accentColor.opacity(0.18),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 400
                )
                .ignoresSafeArea()
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.selectedMoodColorHex)
                
                // Main Content Form
                ScrollView {
                    VStack(spacing: 20) {
                        // User Profile Header Info
                        userHeaderView
                        
                        // Mood Selector (Hero Card)
                        MoodPickerCard(
                            selectedMoodEmoji: viewModel.selectedMoodEmoji,
                            selectedMoodText: viewModel.selectedMoodText,
                            selectedMoodColorHex: viewModel.selectedMoodColorHex,
                            onTap: {
                                viewModel.showMoodPickerSheet = true
                            }
                        )
                        
                        // Text Composer with Character Counter and Emoji Bar
                        PostTextEditor(
                            text: $viewModel.text,
                            placeholder: placeholderText,
                            maxLength: 500,
                            onEmojiSelected: { emoji in
                                viewModel.appendEmoji(emoji)
                            }
                        )
                        
                        // Photo Attachment Section
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
                        
                        // Visibility Selector (Public, Friends, Private)
                        VisibilitySelector(selectedVisibility: $viewModel.visibility)
                            .padding(.top, 4)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                
                // Success overlay toast animation
                if viewModel.showSuccessAnimation {
                    successOverlay
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        viewModel.handleCancelTap {
                            dismiss()
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    PublishButton(
                        isValid: viewModel.isValid,
                        isPublishing: viewModel.isPublishing,
                        accentColor: viewModel.accentColor,
                        action: {
                            viewModel.publishPost { publishedPost in
                                onPostPublished?(publishedPost)
                                dismiss()
                            }
                        }
                    )
                }
            }
            // Mood Picker Bottom Sheet
            .sheet(isPresented: $viewModel.showMoodPickerSheet) {
                moodPickerSheet
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.visible)
            }
            // Photo Selection Action Sheet
            .confirmationDialog("Add Photo", isPresented: $viewModel.showPhotoOptionsActionSheet, titleVisibility: .visible) {
                Button("Photo Preset / Sample Photo") {
                    viewModel.addSamplePhoto()
                }
                
                Button("Photo Library") {
                    viewModel.showImagePicker = true
                }
                
                Button("Cancel", role: .cancel) {}
            }
            // Photos Picker
            .photosPicker(isPresented: $viewModel.showImagePicker, selection: $selectedPhotoItem, matching: .images)
            // Load selected photo from system Photos picker asynchronously
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.addImage(uiImage)
                            selectedPhotoItem = nil
                        }
                    }
                }
            }
            // Confirmation alert for unsaved draft
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
    }
    
    // MARK: - User Header View
    private var userHeaderView: some View {
        HStack(spacing: 12) {
            // User Avatar
            AvatarView(
                imageData: viewModel.currentUser.avatarImageData,
                name: viewModel.currentUser.name,
                colorHex: viewModel.currentUser.avatarColorHex,
                size: 44,
                showBorder: true
            )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(viewModel.currentUser.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)
                    
                    Text("@\(viewModel.currentUser.username)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: viewModel.visibility.iconName)
                        .font(.system(size: 10))
                    Text(viewModel.visibility.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.theme.tertiaryText)
            }
            
            Spacer()
        }
    }
    
    // Dynamic placeholder options based on selected mood
    private var placeholderText: String {
        if let text = viewModel.selectedMoodText {
            return "Describe why you're feeling \(text.lowercased()) today..."
        }
        return "What's on your mind today? Share a thought, quote, or photo..."
    }
    
    // MARK: - Mood Picker Sheet View
    private var moodPickerSheet: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Select your mood")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
                Text("This will highlight your post on MoodMate")
                    .font(.system(size: 13))
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
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.theme.primaryText)
                        }
                        .frame(width: 95, height: 95)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(isSelected ? Color.adaptiveMoodColor(hex: option.colorHex).opacity(0.2) : Color.theme.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(
                                    isSelected ? Color(hex: option.colorHex) : Color.theme.border,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
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
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.theme.success)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(viewModel.showSuccessAnimation ? 1.0 : 0.4)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.showSuccessAnimation)
                
                Text("Post Published!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.theme.surface)
                    .shadow(radius: 20)
            )
        }
        .transition(.opacity)
    }
}

#Preview {
    CreatePostView()
}
