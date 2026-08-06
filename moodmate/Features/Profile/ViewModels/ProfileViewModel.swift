//
//  ProfileViewModel.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    let userId: String?
    private let profileService: ProfileServiceProtocol
    
    @Published var profile: UserProfile?
    @Published var posts: [ProfilePost] = []
    @Published var followers: [UserProfile] = []
    @Published var following: [UserProfile] = []
    
    @Published var isLoading = true
    @Published var isLazyLoadingPosts = false
    @Published var hasMorePosts = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userId: String? = nil, profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.userId = userId
        self.profileService = profileService
        
        if userId == nil {
            AppSessionManager.shared.$currentUser
                .receive(on: DispatchQueue.main)
                .sink { [weak self] user in
                    guard let self else { return }
                    if let user {
                        ProfileService.shared.syncWithFirebaseUser(user: user)
                        self.loadProfile()
                    } else {
                        self.profile = nil
                        self.posts = []
                        self.isLoading = false
                    }
                }
                .store(in: &cancellables)
        }

        profileService.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self = self else { return }
                let currentTargetId = self.userId ?? self.getCurrentUserId()
                if updatedProfile.id == currentTargetId {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        self.profile = updatedProfile
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    var isOwnProfile: Bool {
        guard let profileId = profile?.id else { return false }
        return profileId == getCurrentUserId()
    }
    
    var isWaitingForAuthentication: Bool {
        userId == nil && authenticatedUserId == nil
    }
    
    func getCurrentUserId() -> String {
        authenticatedUserId ?? profileService.getCurrentUserId()
    }
    
    func loadProfile() {
        Task { await loadProfileAsync() }
    }
    
    func refreshProfile() async {
        await loadProfileAsync()
    }
    
    private func loadProfileAsync() async {
        isLoading = true
        
        let targetId = userId ?? getCurrentUserId()
        if let currentFirebaseUser = Auth.auth().currentUser, userId == nil {
            ProfileService.shared.syncWithFirebaseUser(user: currentFirebaseUser)
        }
        
        await loadProfileData(for: targetId)
    }
    
    private var authenticatedUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private func loadProfileData(for profileId: String) async {
        self.posts = profileService.getPosts(forId: profileId)
        self.followers = profileService.getFollowers(forId: profileId)
        self.following = profileService.getFollowing(forId: profileId)
        self.hasMorePosts = true

        if let freshProfile = try? await profileService.fetchProfile(forId: profileId) {
            self.profile = freshProfile
        } else {
            self.profile = profileService.getProfile(forId: profileId)
        }
        
        self.isLoading = false
    }
    
    func toggleFollow() {
        guard let targetId = profile?.id else { return }
        guard targetId != getCurrentUserId() else { return }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if let updated = ProfileService.shared.toggleFollow(targetId: targetId) {
                self.profile = updated
            }
        }
    }
    
    func updateProfile(
        displayName: String,
        username: String,
        bio: String,
        location: String? = nil,
        birthday: Date? = nil,
        privacySetting: PrivacySetting = .publicVisibility,
        avatarColorHex: String,
        avatarImageData: Data? = nil,
        clearAvatar: Bool = false
    ) async throws -> UserProfile {
        let actualUserId = userId ?? getCurrentUserId()
        let updated = try await profileService.updateProfile(
            id: actualUserId,
            displayName: displayName,
            username: username,
            bio: bio,
            location: location,
            birthday: birthday,
            privacySetting: privacySetting,
            avatarColorHex: avatarColorHex,
            avatarImageData: avatarImageData,
            clearAvatar: clearAvatar
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.profile = updated
        }
        return updated
    }
    
    func uploadAvatar(_ image: UIImage) async throws -> Data {
        let actualUserId = userId ?? getCurrentUserId()
        let data = try await profileService.uploadAvatar(image: image, userId: actualUserId)
        if let currentProfile = profileService.getProfile(forId: actualUserId) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.profile = currentProfile
            }
        }
        return data
    }
    
    func deleteAvatar() async throws {
        let actualUserId = userId ?? getCurrentUserId()
        try await profileService.deleteAvatar(userId: actualUserId)
        if let currentProfile = profileService.getProfile(forId: actualUserId) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.profile = currentProfile
            }
        }
    }
    
    func loadFollowersAndFollowing() {
        let actualUserId = userId ?? getCurrentUserId()
        self.followers = ProfileService.shared.getFollowers(forId: actualUserId)
        self.following = ProfileService.shared.getFollowing(forId: actualUserId)
    }
    
    func loadMorePosts() {
        guard !isLazyLoadingPosts && hasMorePosts else { return }
        
        isLazyLoadingPosts = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }

            let currentPostCount = self.posts.count
            if currentPostCount >= 9 {
                self.hasMorePosts = false
                self.isLazyLoadingPosts = false
                return
            }
            
            let additionalPosts = [
                ProfilePost(
                    id: "lazy_p\(currentPostCount + 1)",
                    quoteText: "Grateful hearts see awesome things.",
                    caption: "Reflected on the beauty of nature. The trees, the morning fog, the quiet breeze. 🌲🌫️✨",
                    postGradientStartHex: "805AD5",
                    postGradientEndHex: "38B2AC",
                    likesCount: 18,
                    commentsCount: 3,
                    isLiked: false,
                    isBookmarked: false,
                    createdAt: Date().addingTimeInterval(-86400 * 5)
                ),
                ProfilePost(
                    id: "lazy_p\(currentPostCount + 2)",
                    quoteText: "Calm is a super power.",
                    caption: "Had an amazing breathing session today. Keeping my head clear during high pressure moments.",
                    postGradientStartHex: "4A5568",
                    postGradientEndHex: "1A202C",
                    likesCount: 22,
                    commentsCount: 1,
                    isLiked: true,
                    isBookmarked: false,
                    createdAt: Date().addingTimeInterval(-86400 * 6)
                ),
                ProfilePost(
                    id: "lazy_p\(currentPostCount + 3)",
                    quoteText: "Keep moving, keep growing.",
                    caption: "Setting my intentions for the next month. Focusing on mental wellness, consistency, and peace.",
                    postGradientStartHex: "ED64A6",
                    postGradientEndHex: "E2E8F0",
                    likesCount: 35,
                    commentsCount: 4,
                    isLiked: false,
                    isBookmarked: true,
                    createdAt: Date().addingTimeInterval(-86400 * 7)
                )
            ]
            
            self.posts.append(contentsOf: additionalPosts)
            self.isLazyLoadingPosts = false
        }
    }
}
