//
//  EditProfileViewModel.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {
    // MARK: - Published Form Fields
    
    @Published var displayName: String = ""
    @Published var username: String = ""
    @Published var bio: String = ""
    @Published var location: String = ""
    @Published var hasBirthday: Bool = false
    @Published var birthday: Date = Date()
    @Published var privacySetting: Visibility = .publicVisibility
    @Published var avatarColorHex: String = "38B2AC"

    @Published var selectedAvatarImage: UIImage? = nil
    @Published var currentAvatarData: Data? = nil
    @Published var isAvatarRemoved: Bool = false
    @Published var photosPickerItem: PhotosPickerItem? = nil {
        didSet {
            loadSelectedPhotosItem()
        }
    }

    @Published var displayNameError: String? = nil
    @Published var usernameError: String? = nil
    @Published var bioError: String? = nil
    
    @Published var isLoadingProfile: Bool = false
    @Published var isSaving: Bool = false
    @Published var isUploadingAvatar: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessToast: Bool = false
    @Published var hasPendingAvatarChange: Bool = false

    @Published var showPickerOptions: Bool = false
    @Published var activePickerSource: ImagePickerSourceType? = nil
    @Published var showRemoveAvatarConfirmation: Bool = false
    
    let maxBioLength: Int = 160
    let maxDisplayNameLength: Int = 50
    
    private let profileRepository: ProfileRepositoryProtocol
    private let avatarRepository: AvatarRepositoryProtocol
    private let userId: String

    let avatarColors = [
        "38B2AC", // Teal
        "4DABF7", // Blue
        "BE4BDF", // Magenta
        "FAB005", // Yellow
        "12B886", // Emerald
        "FF6B6B", // Salmon
        "667EEA"  // Indigo
    ]
    
    init(profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
         avatarRepository: AvatarRepositoryProtocol = AvatarRepository.shared,
         userId: String? = nil) {
        self.profileRepository = profileRepository
        self.avatarRepository = avatarRepository
        self.userId = userId ?? AppSessionManager.currentUserId()
        loadProfile()
    }
    
    // MARK: - Profile Operations
    
    func loadProfile() {
        isLoadingProfile = true
        errorMessage = nil
        
        if let currentProfile = profileRepository.getProfile(forId: userId) {
            populateFields(from: currentProfile)
            isLoadingProfile = false
        } else {
            Task {
                if let fetched = try? await profileRepository.fetchProfile(forId: userId) {
                    populateFields(from: fetched)
                }
                isLoadingProfile = false
            }
        }
    }
    
    func refreshProfile() {
        loadProfile()
    }
    
    private func populateFields(from profile: UserProfile) {
        self.displayName = profile.displayName
        self.username = profile.username
        self.bio = profile.bio
        self.location = profile.location ?? ""
        if let userBirthday = profile.birthday {
            self.hasBirthday = true
            self.birthday = userBirthday
        } else {
            self.hasBirthday = false
        }
        self.privacySetting = profile.privacySetting
        self.avatarColorHex = profile.avatarColorHex
        self.currentAvatarData = profile.avatarImageData
        self.isAvatarRemoved = false
        self.selectedAvatarImage = nil
        
        validateProfile()
    }
    
    // MARK: - Validation

    @discardableResult
    func validateProfile() -> Bool {
        let isNameValid = validateDisplayName()
        let isUserValid = validateUsername()
        let isBioValid = validateBio()
        
        return isNameValid && isUserValid && isBioValid
    }

    private var isDisplayNameValid: Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= maxDisplayNameLength
    }
    
    private var isUsernameValid: Bool {
        profileRepository.validateUsername(username: username, currentUserId: userId).isValid
    }
    
    private var isBioValid: Bool {
        bio.count <= maxBioLength
    }
    
    func resetSuccessState() {
        showSuccessToast = false
        errorMessage = nil
    }
    
    @discardableResult
    func validateDisplayName() -> Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            displayNameError = "Display name cannot be empty."
            return false
        }
        if trimmed.count > maxDisplayNameLength {
            displayNameError = "Display name cannot exceed \(maxDisplayNameLength) characters."
            return false
        }
        displayNameError = nil
        return true
    }
    
    @discardableResult
    func validateUsername() -> Bool {
        let (isValid, error) = profileRepository.validateUsername(username: username, currentUserId: userId)
        usernameError = error
        return isValid
    }
    
    @discardableResult
    func validateBio() -> Bool {
        if bio.count > maxBioLength {
            bioError = "Bio cannot exceed \(maxBioLength) characters."
            return false
        }
        bioError = nil
        return true
    }
    
    var bioRemainingCharacters: Int {
        maxBioLength - bio.count
    }

    var isFormValid: Bool {
        isDisplayNameValid && isUsernameValid && isBioValid
    }
    
    // MARK: - Save Profile
    
    func saveProfile() async -> Bool {
        guard validateProfile() else {
            errorMessage = "Please fix the issues above before saving."
            return false
        }
        
        isSaving = true
        errorMessage = nil
        showSuccessToast = false
        
        let cleanedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var avatarDataToSave: Data? = nil
        if let newImage = selectedAvatarImage {
            isUploadingAvatar = true
            avatarDataToSave = avatarRepository.compressAvatar(newImage)
            hasPendingAvatarChange = true
            isUploadingAvatar = false
        } else if !isAvatarRemoved {
            avatarDataToSave = currentAvatarData
        }
        
        do {
            _ = try await profileRepository.updateProfile(
                id: userId,
                displayName: cleanedName,
                username: cleanedUsername,
                bio: cleanedBio,
                location: cleanedLocation.isEmpty ? nil : cleanedLocation,
                birthday: hasBirthday ? birthday : nil,
                privacySetting: privacySetting,
                avatarColorHex: avatarColorHex,
                avatarImageData: avatarDataToSave,
                clearAvatar: isAvatarRemoved
            )
            
            isSaving = false
            hasPendingAvatarChange = false
            selectedAvatarImage = nil
            showSuccessToast = true
            return true
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Avatar Management
    
    func selectAvatarImage(_ image: UIImage) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.selectedAvatarImage = image
            self.isAvatarRemoved = false
            self.hasPendingAvatarChange = true
        }
    }
    
    func removeAvatar() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.selectedAvatarImage = nil
            self.currentAvatarData = nil
            self.isAvatarRemoved = true
            self.hasPendingAvatarChange = true
        }
    }
    
    func uploadAvatar(_ image: UIImage) async {
        isUploadingAvatar = true
        do {
            let data = try await profileRepository.uploadAvatar(image: image, userId: userId)
            self.currentAvatarData = data
            self.selectedAvatarImage = nil
            self.isAvatarRemoved = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isUploadingAvatar = false
    }
    
    func deleteAvatar() async {
        isUploadingAvatar = true
        do {
            try await profileRepository.deleteAvatar(userId: userId)
            self.currentAvatarData = nil
            self.selectedAvatarImage = nil
            self.isAvatarRemoved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isUploadingAvatar = false
    }
    
    private func loadSelectedPhotosItem() {
        guard let item = photosPickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectAvatarImage(uiImage)
                }
            }
        }
    }
}
