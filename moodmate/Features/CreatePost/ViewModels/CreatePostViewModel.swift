//
//  CreatePostViewModel.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import Combine
import UIKit
import FirebaseAuth

@MainActor
final class CreatePostViewModel: ObservableObject {
    // MARK: - Post Form State
    @Published var text: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var visibility: Visibility = .publicVisibility

    // MARK: - View UI State
    @Published var isPublishing: Bool = false
    @Published var showSuccessAnimation: Bool = false
    @Published var showPhotoOptionsActionSheet: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showCameraPicker: Bool = false
    @Published var showDiscardDraftAlert: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies
    private let postRepository: PostRepositoryProtocol
    private let draftManager: DraftManager
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var currentUser: AppUser

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        draftManager: DraftManager = DraftManager.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
        authService: AuthServiceProtocol = FirebaseAuthService.shared
    ) {
        self.postRepository = postRepository
        self.draftManager = draftManager
        self.profileRepository = profileRepository

        let userId = AppSessionManager.currentUserId()
        if let profile = profileRepository.getProfile(forId: userId) {
            self.currentUser = AppUser(
                id: profile.id,
                name: profile.displayName,
                username: profile.username,
                avatarImageName: profile.avatarImageName,
                avatarImageData: profile.avatarImageData,
                avatarColorHex: profile.avatarColorHex
            )
        } else {
            // No stored profile yet (sign-up still settling): show whatever the
            // Firebase user carries, and let `observeProfileUpdates` fill in the
            // rest as soon as the profile lands.
            var userName = ""
            var userHandle = ""
            if let firebaseUser = authService.currentUser {
                if let name = firebaseUser.displayName, !name.isEmpty {
                    userName = name
                }
                if let email = firebaseUser.email, let prefix = email.components(separatedBy: "@").first {
                    if userName.isEmpty { userName = prefix.capitalized }
                    userHandle = prefix.lowercased()
                }
            }

            self.currentUser = AppUser(
                id: userId,
                name: userName,
                username: userHandle,
                avatarImageName: nil,
                avatarColorHex: UserProfile.defaultAvatarColorHex
            )
        }

        observeProfileUpdates()
        loadDraftIfAvailable()
    }

    private func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self = self else { return }
                let currentId = AppSessionManager.currentUserId()
                if profile.id == currentId {
                    self.currentUser = AppUser(
                        id: profile.id,
                        name: profile.displayName,
                        username: profile.username,
                        avatarImageName: profile.avatarImageName,
                        avatarImageData: profile.avatarImageData,
                        avatarColorHex: profile.avatarColorHex
                    )
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Validation
    var isValid: Bool {
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPhoto = !selectedImages.isEmpty

        return (hasText || hasPhoto) && text.count <= 500
    }

    var hasUnsavedContent: Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }

    var accentColor: Color {
        Color.theme.accent
    }

    // MARK: - Form Actions
    func addImage(_ image: UIImage) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            selectedImages.append(image)
        }
    }

    func removeImage(at index: Int) {
        guard index >= 0 && index < selectedImages.count else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            selectedImages.remove(at: index)
        }
    }

    func replaceImage(at index: Int, with newImage: UIImage) {
        guard index >= 0 && index < selectedImages.count else { return }
        selectedImages[index] = newImage
    }

    func addSamplePhoto() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 600))
        let sampleImage = renderer.image { ctx in
            let color1 = UIColor(Color.theme.accent).cgColor
            let color2 = UIColor(Color.purple).cgColor
            let colors = [color1, color2] as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 1.0]) {
                ctx.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 800, y: 600), options: [])
            }
            let text = "MoodMate Moment"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 42, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attrs)
            let rect = CGRect(x: (800 - textSize.width)/2, y: (600 - textSize.height)/2, width: textSize.width, height: textSize.height)
            text.draw(in: rect, withAttributes: attrs)
        }

        addImage(sampleImage)
    }

    // MARK: - Draft Handling
    func saveDraft() {
        var base64Images: [String] = []
        for img in selectedImages {
            if let data = img.jpegData(compressionQuality: 0.7) {
                base64Images.append(data.base64EncodedString())
            }
        }

        let draft = PostDraft(
            text: text,
            imageBase64Strings: base64Images,
            visibility: visibility,
            savedAt: Date()
        )

        draftManager.saveDraft(draft)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func loadDraftIfAvailable() {
        guard let draft = draftManager.loadDraft() else { return }

        self.text = draft.text
        self.visibility = draft.visibility

        var loadedImages: [UIImage] = []
        for base64 in draft.imageBase64Strings {
            if let data = Data(base64Encoded: base64), let img = UIImage(data: data) {
                loadedImages.append(img)
            }
        }
        self.selectedImages = loadedImages
    }

    func clearDraft() {
        draftManager.clearDraft()
    }

    func handleCancelTap(onDismiss: () -> Void) {
        if hasUnsavedContent {
            showDiscardDraftAlert = true
        } else {
            onDismiss()
        }
    }

    // MARK: - Publish Action
    func publishPost(onSuccess: @escaping (PostModel) -> Void) {
        guard isValid else { return }

        isPublishing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        var imageStrings: [String] = []
        for img in selectedImages {
            if let data = img.jpegData(compressionQuality: 0.7) {
                let base64 = "data:image/jpeg;base64," + data.base64EncodedString()
                imageStrings.append(base64)
            }
        }

        let newPost = PostModel(
            id: "post_\(UUID().uuidString.prefix(8))",
            authorId: currentUser.id,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text,
            images: imageStrings,
            visibility: visibility,
            createdAt: Date(),
            likesCount: 0,
            commentsCount: 0,
            bookmarksCount: 0,
            isLiked: false,
            isBookmarked: false,
            gradientStartHex: "38B2AC",
            gradientEndHex: "805AD5"
        )

        Task {
            do {
                let created = try await postRepository.createPost(newPost)

                clearDraft()

                await MainActor.run {
                    self.isPublishing = false
                    self.showSuccessAnimation = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }

                try await Task.sleep(nanoseconds: 600_000_000)

                await MainActor.run {
                    onSuccess(created)
                }
            } catch {
                await MainActor.run {
                    self.isPublishing = false
                    self.errorMessage = error.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}
