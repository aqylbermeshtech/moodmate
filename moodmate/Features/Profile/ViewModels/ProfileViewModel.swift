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
    let userId: String? // nil means current authenticated user
    
    @Published var profile: UserProfile?
    @Published var posts: [ProfilePost] = []
    @Published var followers: [UserProfile] = []
    @Published var following: [UserProfile] = []
    
    @Published var isLoading = true
    @Published var isLazyLoadingPosts = false
    @Published var hasMorePosts = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userId: String? = nil) {
        self.userId = userId
        
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
    }
    
    var isOwnProfile: Bool {
        guard let profileId = profile?.id else { return false }
        return profileId == authenticatedUserId
    }
    
    var isWaitingForAuthentication: Bool {
        userId == nil && authenticatedUserId == nil
    }
    
    func getCurrentUserId() -> String {
        authenticatedUserId ?? "current_user_mock"
    }
    
    func loadProfile() {
        isLoading = true
        
        if userId == nil {
            guard let authenticatedUserId,
                  let firebaseUser = Auth.auth().currentUser else {
                // Auth session is still restoring; keep showing the loading state.
                return
            }
            
            ProfileService.shared.syncWithFirebaseUser(user: firebaseUser)
            loadProfileData(for: authenticatedUserId)
            return
        }
        
        loadProfileData(for: userId!)
    }
    
    private var authenticatedUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private func loadProfileData(for profileId: String) {
        self.profile = ProfileService.shared.getProfile(forId: profileId)
        self.posts = ProfileService.shared.getPosts(forId: profileId)
        self.hasMorePosts = true
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
    
    func editProfile(displayName: String, username: String, bio: String, avatarColorHex: String) {
        let actualUserId = userId ?? getCurrentUserId()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if let updated = ProfileService.shared.updateProfile(
                id: actualUserId,
                displayName: displayName,
                username: username,
                bio: bio,
                avatarColorHex: avatarColorHex
            ) {
                self.profile = updated
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
        
        // Simulate network latency (0.8s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // Generate some mock historical posts
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
