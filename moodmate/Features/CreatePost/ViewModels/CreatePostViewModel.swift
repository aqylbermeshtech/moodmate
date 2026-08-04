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
    @Published var selectedMoodEmoji: String? = nil
    @Published var selectedMoodText: String? = nil
    @Published var selectedMoodColorHex: String? = nil
    
    @Published var text: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var visibility: PostVisibility = .publicVisibility
    
    // MARK: - View UI State
    @Published var isPublishing: Bool = false
    @Published var showSuccessAnimation: Bool = false
    @Published var showMoodPickerSheet: Bool = false
    @Published var showPhotoOptionsActionSheet: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showCameraPicker: Bool = false
    @Published var showDiscardDraftAlert: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Dependencies
    private let postService: PostServiceProtocol
    private let draftManager: DraftManager

    @Published var currentUser: MoodUser
    
    init(
        postService: PostServiceProtocol = MockPostService.shared,
        draftManager: DraftManager = DraftManager.shared
    ) {
        self.postService = postService
        self.draftManager = draftManager

        var userName = "John"
        var userHandle = "john_doe"
        if let firebaseUser = FirebaseAuthService.shared.currentUser {
            if let name = firebaseUser.displayName, !name.isEmpty {
                userName = name
            } else if let email = firebaseUser.email, !email.isEmpty {
                let prefix = email.components(separatedBy: "@").first ?? "john"
                userName = prefix.capitalized
                userHandle = prefix.lowercased()
            }
        }
        
        self.currentUser = MoodUser(
            id: FirebaseAuthService.shared.currentUser?.uid ?? "current_user",
            name: userName,
            username: userHandle,
            avatarImageName: nil,
            avatarColorHex: "38B2AC",
            currentMoodEmoji: nil,
            currentMoodText: nil,
            currentMoodColorHex: nil
        )

        loadDraftIfAvailable()
    }
    
    // MARK: - Validation
    var isValid: Bool {
        let hasMood = selectedMoodEmoji != nil
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPhoto = !selectedImages.isEmpty
        
        return (hasMood || hasText || hasPhoto) && text.count <= 500
    }
    
    var hasUnsavedContent: Bool {
        return selectedMoodEmoji != nil || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }
    
    var accentColor: Color {
        if let hex = selectedMoodColorHex {
            return Color.adaptiveMoodColor(hex: hex)
        }
        return Color.theme.accent
    }
 
    struct MoodOption: Identifiable {
        let id = UUID()
        let emoji: String
        let text: String
        let colorHex: String
    }
    
    let moodOptions = [
        MoodOption(emoji: "😊", text: "Happy", colorHex: "38B2AC"),   // Teal
        MoodOption(emoji: "😌", text: "Calm", colorHex: "4A5568"),    // Charcoal
        MoodOption(emoji: "😴", text: "Sleepy", colorHex: "667EEA"),  // Indigo
        MoodOption(emoji: "🤩", text: "Excited", colorHex: "ED64A6"), // Pink
        MoodOption(emoji: "😔", text: "Sad", colorHex: "A0AEC0"),     // Slate
        MoodOption(emoji: "🧠", text: "Mindful", colorHex: "805AD5"), // Purple
        MoodOption(emoji: "🔥", text: "Motivated", colorHex: "DD6B20"),// Orange
        MoodOption(emoji: "✨", text: "Inspired", colorHex: "D69E2E")  // Gold
    ]
    
    // MARK: - Form Actions
    func selectMood(emoji: String, text: String, colorHex: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.selectedMoodEmoji = emoji
            self.selectedMoodText = text
            self.selectedMoodColorHex = colorHex
 
            self.currentUser.currentMoodEmoji = emoji
            self.currentUser.currentMoodText = text
            self.currentUser.currentMoodColorHex = colorHex
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func clearMood() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.selectedMoodEmoji = nil
            self.selectedMoodText = nil
            self.selectedMoodColorHex = nil
        }
    }
    
    func appendEmoji(_ emoji: String) {
        text += emoji
    }
    
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
            let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

            let color1 = UIColor(Color.adaptiveMoodColor(hex: selectedMoodColorHex ?? "38B2AC")).cgColor
            let color2 = UIColor(Color.purple).cgColor
            let colors = [color1, color2] as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 1.0]) {
                ctx.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 800, y: 600), options: [])
            }
            let text = "MoodMate Moment 🌿"
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
            moodText: selectedMoodText,
            moodEmoji: selectedMoodEmoji,
            moodColorHex: selectedMoodColorHex,
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
        
        self.selectedMoodEmoji = draft.moodEmoji
        self.selectedMoodText = draft.moodText
        self.selectedMoodColorHex = draft.moodColorHex
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
            author: currentUser,
            mood: selectedMoodText,
            moodEmoji: selectedMoodEmoji,
            moodColorHex: selectedMoodColorHex,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text,
            images: imageStrings,
            visibility: visibility,
            createdAt: Date(),
            likesCount: 0,
            commentsCount: 0,
            bookmarksCount: 0,
            isLiked: false,
            isBookmarked: false,
            gradientStartHex: selectedMoodColorHex ?? "38B2AC",
            gradientEndHex: "805AD5"
        )
        
        Task {
            do {
                let created = try await postService.createPost(newPost)

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
