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
class ProfileViewModel: ObservableObject {
    let userId: String
    let profileRepository: ProfileRepositoryProtocol
    let followRepository: FollowRepositoryProtocol
    let sessionManager: AppSessionManager
    let postRepository: PostRepositoryProtocol

    @Published var profile: UserProfile?
    @Published var posts: [PostModel] = []
    @Published var followers: [UserProfile] = []
    @Published var following: [UserProfile] = []

    @Published var isLoading = true
    @Published var errorMessage: String?

    var cancellables = Set<AnyCancellable>()

    init(userId: String,
         profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
         followRepository: FollowRepositoryProtocol = FollowRepository.shared,
         sessionManager: AppSessionManager = AppSessionManager.shared,
         postRepository: PostRepositoryProtocol = PostRepository.shared) {
        self.userId = userId
        self.profileRepository = profileRepository
        self.followRepository = followRepository
        self.sessionManager = sessionManager
        self.postRepository = postRepository

        observePostUpdates()
        subscribeToProfileUpdates()
    }

    /// `OwnProfileViewModel` overrides this to resolve the live authenticated
    /// user, since sign-in can complete after this VM is constructed.
    var targetUserId: String { userId }

    private func observePostUpdates() {
        postRepository.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allPosts in
                guard let self else { return }
                self.posts = allPosts.filter { $0.authorId == self.targetUserId }
            }
            .store(in: &cancellables)
    }

    /// Called on sign-out so the next user doesn't briefly see this grid.
    func resetPosts() {
        posts = []
    }

    private func subscribeToProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self else { return }
                if updatedProfile.id == self.targetUserId {
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

    func getCurrentUserId() -> String {
        sessionManager.currentUser?.uid ?? AppSessionManager.currentUserId()
    }

    func loadProfile() {
        Task { await loadProfileAsync() }
    }

    func refreshProfile() async {
        await loadProfileAsync()
    }

    private func loadProfileAsync() async {
        isLoading = true
        await loadProfileData(for: targetUserId)
    }

    private func loadProfileData(for profileId: String) async {
        self.followers = followRepository.getFollowers(forId: profileId)
        self.following = followRepository.getFollowing(forId: profileId)

        do {
            self.profile = try await profileRepository.fetchProfile(forId: profileId)
        } catch {
            self.profile = nil
        }

        if self.profile == nil {
            self.profile = profileRepository.getProfile(forId: profileId)
        }

        if self.profile == nil {
            errorMessage = "Couldn't load this profile. Pull to refresh to try again."
        }

        self.isLoading = false
    }

    func toggleFollow() {
        guard let targetId = profile?.id else { return }
        toggleFollow(for: targetId)
    }

    @discardableResult
    func toggleFollow(for targetId: String) -> UserProfile? {
        guard targetId != getCurrentUserId() else { return nil }

        var updated: UserProfile?
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            updated = followRepository.toggleFollow(targetId: targetId)
            if let updated, updated.id == profile?.id {
                self.profile = updated
            }
        }
        return updated
    }

    func loadFollowersAndFollowing() {
        self.followers = followRepository.getFollowers(forId: targetUserId)
        self.following = followRepository.getFollowing(forId: targetUserId)
    }
}
