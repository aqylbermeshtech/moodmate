//
//  ProfileViewModel.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    let userId: String

    private let fetchProfileUseCase: FetchProfileUseCaseProtocol
    private let observeProfileUpdatesUseCase: ObserveProfileUpdatesUseCaseProtocol
    private let observeFeedPostsUseCase: ObserveFeedPostsUseCaseProtocol
    private let toggleFollowUseCase: ToggleFollowUseCaseProtocol
    private let fetchFollowListsUseCase: FetchFollowListsUseCaseProtocol
    private let currentUserProvider: CurrentUserProviderProtocol
    let sessionManager: AppSessionManager

    @Published var profile: UserProfile?
    @Published var posts: [PostModel] = []
    @Published var followers: [UserProfile] = []
    @Published var following: [UserProfile] = []

    @Published var isLoading = true
    @Published var errorMessage: String?

    var cancellables = Set<AnyCancellable>()

    init(userId: String,
         fetchProfileUseCase: FetchProfileUseCaseProtocol = DIContainer.shared.fetchProfileUseCase,
         observeProfileUpdatesUseCase: ObserveProfileUpdatesUseCaseProtocol = DIContainer.shared.observeProfileUpdatesUseCase,
         observeFeedPostsUseCase: ObserveFeedPostsUseCaseProtocol = DIContainer.shared.observeFeedPostsUseCase,
         toggleFollowUseCase: ToggleFollowUseCaseProtocol = DIContainer.shared.toggleFollowUseCase,
         fetchFollowListsUseCase: FetchFollowListsUseCaseProtocol = DIContainer.shared.fetchFollowListsUseCase,
         currentUserProvider: CurrentUserProviderProtocol = DIContainer.shared.currentUserProvider,
         sessionManager: AppSessionManager? = nil) {
        self.userId = userId
        self.fetchProfileUseCase = fetchProfileUseCase
        self.observeProfileUpdatesUseCase = observeProfileUpdatesUseCase
        self.observeFeedPostsUseCase = observeFeedPostsUseCase
        self.toggleFollowUseCase = toggleFollowUseCase
        self.fetchFollowListsUseCase = fetchFollowListsUseCase
        self.currentUserProvider = currentUserProvider
        // Resolved in the (MainActor) init body: default argument expressions
        // are nonisolated in Swift 5 language mode.
        self.sessionManager = sessionManager ?? DIContainer.shared.sessionManager

        observePostUpdates()
        subscribeToProfileUpdates()
    }

    /// `OwnProfileViewModel` overrides this to resolve the live authenticated
    /// user, since sign-in can complete after this VM is constructed.
    var targetUserId: String { userId }

    private func observePostUpdates() {
        observeFeedPostsUseCase.publisher
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
        observeProfileUpdatesUseCase.publisher
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
        currentUserProvider.currentUserId
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
        self.followers = fetchFollowListsUseCase.followers(forId: profileId)
        self.following = fetchFollowListsUseCase.following(forId: profileId)

        do {
            self.profile = try await fetchProfileUseCase.executeAsync(forId: profileId)
        } catch {
            self.profile = nil
        }

        if self.profile == nil {
            self.profile = fetchProfileUseCase.execute(forId: profileId)
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
        var updated: UserProfile?
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            updated = toggleFollowUseCase.execute(targetId: targetId)
            if let updated, updated.id == profile?.id {
                self.profile = updated
            }
        }
        return updated
    }

    func loadFollowersAndFollowing() {
        self.followers = fetchFollowListsUseCase.followers(forId: targetUserId)
        self.following = fetchFollowListsUseCase.following(forId: targetUserId)
    }
}
