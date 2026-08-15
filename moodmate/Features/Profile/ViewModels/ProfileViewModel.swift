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

    /// `posts` is `repositoryPosts + demoLoadedPosts` — split so the fake
    /// posts `loadMorePosts` synthesizes (see below) can be merged in without
    /// ever being written to `postRepository`, and without getting wiped out
    /// the next time `postRepository.postsPublisher` emits.
    private var repositoryPosts: [PostModel] = []
    private var demoLoadedPosts: [PostModel] = []

    @Published var isLoading = true
    @Published var isLazyLoadingPosts = false
    @Published var hasMorePosts = true

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

    /// The id whose profile/posts/followers this VM loads. Defaults to the
    /// stored `userId`, but `OwnProfileViewModel` overrides this to always
    /// resolve the live authenticated user, since sign-in can complete after
    /// the VM is constructed and `userId` alone would go stale.
    var targetUserId: String { userId }

    /// Reconciles the displayed grid whenever any post changes anywhere in
    /// the app (like/bookmark from Feed or Discover, a new post published)
    /// so this profile's posts never drift from the canonical state.
    private func observePostUpdates() {
        postRepository.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allPosts in
                guard let self else { return }
                self.repositoryPosts = allPosts.filter { $0.authorId == self.targetUserId }
                self.recomputePosts()
            }
            .store(in: &cancellables)
    }

    private func recomputePosts() {
        posts = repositoryPosts + demoLoadedPosts
    }

    /// Clears both the repository-backed and demo-loaded post state — used
    /// on sign-out so a subsequent sign-in as a different user doesn't merge
    /// stale demo posts from the previous session into the new one.
    func resetPosts() {
        repositoryPosts = []
        demoLoadedPosts = []
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
        self.hasMorePosts = true

        if let freshProfile = try? await profileRepository.fetchProfile(forId: profileId) {
            self.profile = freshProfile
        } else {
            self.profile = profileRepository.getProfile(forId: profileId)
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

    func loadMorePosts() {
        guard !isLazyLoadingPosts && hasMorePosts else { return }

        isLazyLoadingPosts = true

        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 800_000_000)

            let currentPostCount = self.posts.count
            if currentPostCount >= 9 {
                self.hasMorePosts = false
                self.isLazyLoadingPosts = false
                return
            }

            let authorId = self.targetUserId

            // Synthesized demo content only — merged into `posts` via
            // `recomputePosts()`, never written to `postRepository`, so it
            // can't leak into Feed/Discover or collide with real post ids.
            let additionalPosts = [
                PostModel(
                    id: "lazy_\(authorId)_\(currentPostCount + 1)", authorId: authorId, mood: nil, moodEmoji: nil, moodColorHex: nil,
                    text: nil, images: [], visibility: .publicVisibility,
                    createdAt: Date().addingTimeInterval(-86400 * 5), likesCount: 18, commentsCount: 3,
                    bookmarksCount: 0, isLiked: false, isBookmarked: false,
                    quoteText: "Grateful hearts see awesome things.",
                    gradientStartHex: "805AD5", gradientEndHex: "38B2AC"
                ),
                PostModel(
                    id: "lazy_\(authorId)_\(currentPostCount + 2)", authorId: authorId, mood: nil, moodEmoji: nil, moodColorHex: nil,
                    text: nil, images: [], visibility: .publicVisibility,
                    createdAt: Date().addingTimeInterval(-86400 * 6), likesCount: 22, commentsCount: 1,
                    bookmarksCount: 0, isLiked: true, isBookmarked: false,
                    quoteText: "Calm is a super power.",
                    gradientStartHex: "4A5568", gradientEndHex: "1A202C"
                ),
                PostModel(
                    id: "lazy_\(authorId)_\(currentPostCount + 3)", authorId: authorId, mood: nil, moodEmoji: nil, moodColorHex: nil,
                    text: nil, images: [], visibility: .publicVisibility,
                    createdAt: Date().addingTimeInterval(-86400 * 7), likesCount: 35, commentsCount: 4,
                    bookmarksCount: 0, isLiked: false, isBookmarked: true,
                    quoteText: "Keep moving, keep growing.",
                    gradientStartHex: "ED64A6", gradientEndHex: "E2E8F0"
                )
            ]

            self.demoLoadedPosts.append(contentsOf: additionalPosts)
            self.recomputePosts()
            self.isLazyLoadingPosts = false
        }
    }
}
