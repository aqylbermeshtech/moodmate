//
//  EditProfileView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var editViewModel: EditProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        let userId = viewModel.profile?.id ?? viewModel.getCurrentUserId()
        self._editViewModel = StateObject(wrappedValue: EditProfileViewModel(userId: userId))
    }
    
    init(userId: String? = nil) {
        self._editViewModel = StateObject(wrappedValue: EditProfileViewModel(userId: userId))
    }
    
    var body: some View {
        Group {
            ZStack {
                Color.theme.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let error = editViewModel.errorMessage {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .padding(.top, 2)
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.theme.primaryText)
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        avatarSection
                            .padding(.top, 10)

                        colorThemeSection

                        formFieldsSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)

                if editViewModel.showSuccessToast {
                    VStack {
                        SuccessToastView(message: "Profile updated successfully!")
                            .padding(.top, 12)
                        Spacer()
                    }
                    .zIndex(10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                editViewModel.resetSuccessState()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.theme.secondaryText)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveChanges) {
                        if editViewModel.isSaving || editViewModel.isUploadingAvatar {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(Color.theme.accent)
                                Text("Saving")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(editViewModel.isFormValid ? Color.theme.accent : Color.theme.secondaryText)
                        }
                    }
                    .disabled(!editViewModel.isFormValid || editViewModel.isSaving || editViewModel.isUploadingAvatar)
                }
            }
            .sheet(isPresented: $editViewModel.showPickerOptions) {
                AvatarPickerOptionsView(
                    hasCustomAvatar: editViewModel.currentAvatarData != nil || editViewModel.selectedAvatarImage != nil,
                    onSelectLibrary: {
                        editViewModel.activePickerSource = .library
                    },
                    onSelectCamera: {
                        editViewModel.activePickerSource = .camera
                    },
                    onRemoveAvatar: {
                        editViewModel.showRemoveAvatarConfirmation = true
                    }
                )
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.hidden)
            }
            .sheet(item: $editViewModel.activePickerSource) { source in
                switch source {
                case .library:
                    PhotosPickerWrapper(
                        selectedImage: $editViewModel.selectedAvatarImage,
                        onError: { editViewModel.errorMessage = $0 }
                    )
                case .camera:
                    CameraPickerView(selectedImage: $editViewModel.selectedAvatarImage)
                        .ignoresSafeArea()
                }
            }
            .confirmationDialog(
                "Remove Profile Photo",
                isPresented: $editViewModel.showRemoveAvatarConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove Photo", role: .destructive) {
                    editViewModel.removeAvatar()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your profile will revert to displaying your initials with your selected theme color.")
            }
        }
    }
    
    // MARK: - Avatar Section
    
    private var avatarSection: some View {
        VStack(spacing: 12) {
            AvatarView(
                imageData: editViewModel.currentAvatarData,
                image: editViewModel.selectedAvatarImage,
                name: editViewModel.displayName.isEmpty ? "U" : editViewModel.displayName,
                colorHex: editViewModel.avatarColorHex,
                size: 104,
                showBorder: true,
                overlayAction: {
                    editViewModel.showPickerOptions = true
                },
                overlayIcon: "camera.fill"
            )
            
            Button(action: {
                editViewModel.showPickerOptions = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text(hasCustomPhoto ? "Change Photo" : "Add Photo")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color.theme.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.theme.accent.opacity(0.12))
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity)
    }
    
    private var hasCustomPhoto: Bool {
        editViewModel.selectedAvatarImage != nil || (editViewModel.currentAvatarData != nil && !editViewModel.isAvatarRemoved)
    }
    
    // MARK: - Color Theme Selector Section
    
    private var colorThemeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Theme Color")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(editViewModel.avatarColors, id: \.self) { hex in
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                editViewModel.avatarColorHex = hex
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 38, height: 38)
                                
                                if editViewModel.avatarColorHex == hex {
                                    Circle()
                                        .stroke(Color.theme.primaryText, lineWidth: 2)
                                        .frame(width: 46, height: 46)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 48, height: 48)
                        .accessibilityLabel("Color option \(hex)")
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    // MARK: - Form Fields Section
    
    private var formFieldsSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("PERSONAL INFO")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Display Name")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                        Spacer()
                        Text("\(editViewModel.displayName.count)/\(editViewModel.maxDisplayNameLength)")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.theme.secondaryText.opacity(0.7))
                    }
                    .padding(.horizontal, 4)
                    
                    CustomTextField(
                        placeholder: "E.g. Michele",
                        text: $editViewModel.displayName,
                        icon: "person"
                    )
                    .onChange(of: editViewModel.displayName) { _, _ in
                        editViewModel.validateDisplayName()
                    }
                    
                    if let error = editViewModel.displayNameError {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.secondaryText)
                        .padding(.horizontal, 4)
                    
                    CustomTextField(
                        placeholder: "E.g. mj",
                        text: $editViewModel.username,
                        icon: "at"
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: editViewModel.username) { _, _ in
                        editViewModel.validateUsername()
                    }
                    
                    if let error = editViewModel.usernameError {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Bio")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                        Spacer()
                        Text("\(editViewModel.bioRemainingCharacters) left")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(editViewModel.bioRemainingCharacters < 0 ? Color.red : Color.theme.secondaryText.opacity(0.7))
                    }
                    .padding(.horizontal, 4)
                    
                    TextEditor(text: $editViewModel.bio)
                        .frame(height: 90)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .scrollContentBackground(.hidden)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(editViewModel.bioError != nil ? Color.red : Color.theme.border, lineWidth: 1)
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(Color.theme.primaryText)
                        .onChange(of: editViewModel.bio) { _, _ in
                            editViewModel.validateBio()
                        }
                    
                    if let error = editViewModel.bioError {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .padding(16)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 16) {
                Text("ADDITIONAL DETAILS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
                    .padding(.horizontal, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Location")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.secondaryText)
                        .padding(.horizontal, 4)
                    
                    CustomTextField(
                        placeholder: "E.g. San Francisco, CA",
                        text: $editViewModel.location,
                        icon: "mappin.and.ellipse"
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $editViewModel.hasBirthday.animation()) {
                        HStack(spacing: 8) {
                            Image(systemName: "cake.fill")
                                .foregroundStyle(.pink)
                            Text("Birthday")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.theme.primaryText)
                        }
                    }
                    .tint(Color.theme.accent)
                    
                    if editViewModel.hasBirthday {
                        DatePicker(
                            "Select Date",
                            selection: $editViewModel.birthday,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .tint(Color.theme.accent)
                        .padding(8)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(16)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 14) {
                Text("PRIVACY SETTINGS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.secondaryText)
                    .padding(.horizontal, 4)
                
                Picker("Privacy Setting", selection: $editViewModel.privacySetting) {
                    ForEach(Visibility.allCases) { setting in
                        Label(setting.rawValue, systemImage: setting.iconName)
                            .tag(setting)
                    }
                }
                .pickerStyle(.segmented)
                
                HStack(spacing: 6) {
                    Image(systemName: editViewModel.privacySetting.iconName)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.secondaryText)
                    
                    Text(privacyDescription(for: editViewModel.privacySetting))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                .padding(.horizontal, 4)
            }
            .padding(16)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
        }
    }
    
    private func privacyDescription(for setting: Visibility) -> String {
        switch setting {
        case .publicVisibility:
            return "Anyone on MoodMate can view your profile and public posts."
        case .friendsOnly:
            return "Only users you follow back can view your full profile details."
        case .privateVisibility:
            return "Your profile is private and hidden from public discovery."
        }
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        Task {
            let success = await editViewModel.saveProfile()
            if success {
                try? await Task.sleep(nanoseconds: 600_000_000)
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Helper PhotosPicker wrapper
struct PhotosPickerWrapper: View {
    @Binding var selectedImage: UIImage?
    var onError: (String) -> Void = { _ in }
    @State private var selectedItem: PhotosPickerItem? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.theme.accent)
                    Text("Tap to Open Photo Library")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                selectedImage = uiImage
                                dismiss()
                            }
                        }
                    } catch {
                        await MainActor.run {
                            onError("Couldn't load that photo. Please try another one.")
                        }
                    }
                }
            }
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView(userId: "current_user_mock")
    }
}
