import Combine
import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class FeedViewModel {

    enum FeedFilter: Int, CaseIterable {
        case forYou = 0
        case following = 1
    }

    // MARK: - Observed State

    private(set) var posts: [FeedPost] = [] {
        didSet {
            guard let firstPost = posts.first else { return }
            logger.debug(
                "feed posts assigned: \(firstPost.id, privacy: .public) liked \(firstPost.isLiked, privacy: .public), count \(firstPost.likesCount, privacy: .public)"
            )
        }
    }
    private(set) var errorMessage: String?

    var selectedFilter: FeedFilter = .forYou

    /// Stored (not computed) so the "Following" tab re-renders on a follow
    /// toggle from anywhere — see `observeFollowChanges`.
    private(set) var followedAuthorIds: Set<String> = []

    var visiblePosts: [FeedPost] {
        switch selectedFilter {
        case .forYou:
            return posts
        case .following:
            return posts.filter { followedAuthorIds.contains($0.authorId) }
        }
    }

    // MARK: - Dependencies

    private let postRepository: PostRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.moodmate", category: "FeedViewModel")

    // MARK: - Init

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared
    ) {
        self.postRepository = postRepository
        self.profileRepository = profileRepository
    }

    // MARK: - Lifecycle

    private var isObserving = false

    func startObserving() {
        guard !isObserving else { return }
        isObserving = true

        observePosts()
        observeFollowChanges()
        refreshFollowedAuthors()

        Task { [weak self] in
            guard let self else { return }
            do {
                let initialPosts = try await postRepository.fetchPosts()
                self.posts = initialPosts.map { FeedPost(from: $0) }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func stopObserving() {
        isObserving = false
        cancellables.removeAll()
    }


    // MARK: - Public API

    func addNewlyCreatedPost(_ postModel: PostModel) {
        let feedPost = FeedPost(from: postModel)
        guard !posts.contains(where: { $0.id == feedPost.id }) else { return }
        posts.insert(feedPost, at: 0)
    }

    func toggleLike(for post: FeedPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }

        let desiredLikeState = !post.isLiked
        let previousLiked    = post.isLiked
        let previousCount    = post.likesCount

        // Mutate in-place so SwiftUI redraws this frame.
        posts[index].isLiked    = desiredLikeState
        posts[index].likesCount = desiredLikeState ? previousCount + 1 : previousCount - 1

        logger.debug(
            "Like optimistic for \(post.id, privacy: .public): \(previousLiked, privacy: .public)→\(desiredLikeState, privacy: .public), count \(previousCount, privacy: .public)→\(self.posts[index].likesCount, privacy: .public)"
        )

        Task {
            do {
                try await postRepository.setLike(postId: post.id, isLiked: desiredLikeState)
            } catch {
                if let rollbackIndex = self.posts.firstIndex(where: { $0.id == post.id }) {
                    self.posts[rollbackIndex].isLiked    = previousLiked
                    self.posts[rollbackIndex].likesCount = previousCount
                }
                self.errorMessage = "Could not update like. Please try again."
            }
        }
    }

    /// Only your own posts can be deleted — there's no moderation path for
    /// anyone else's.
    func canDelete(_ post: FeedPost) -> Bool {
        !post.authorId.isEmpty && post.authorId == AppSessionManager.currentUserId()
    }

    func deletePost(_ post: FeedPost) {
        guard canDelete(post) else { return }

        let index = posts.firstIndex(where: { $0.id == post.id })
        if let index { posts.remove(at: index) }

        Task {
            do {
                try await postRepository.deletePost(id: post.id)
            } catch {
                // Put it back where it was so the feed still matches the store.
                if let index, !posts.contains(where: { $0.id == post.id }) {
                    posts.insert(post, at: min(index, posts.count))
                }
                errorMessage = "Could not delete that post. Please try again."
            }
        }
    }

    func toggleBookmark(for post: FeedPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }

        let previousBookmarked = posts[index].isBookmarked

        posts[index].isBookmarked = !previousBookmarked

        Task {
            do {
                try await postRepository.toggleBookmark(postId: post.id)
            } catch {
                if let rollbackIndex = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[rollbackIndex].isBookmarked = previousBookmarked
                }
                errorMessage = "Could not update bookmark. Please try again."
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Observation

    private func refreshFollowedAuthors() {
        followedAuthorIds = Set(
            profileRepository.allProfiles()
                .filter(\.isFollowing)
                .map(\.id)
        )
    }

    private func observeFollowChanges() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshFollowedAuthors()
            }
            .store(in: &cancellables)
    }

    private func observePosts() {
        postRepository.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] postModels in
                guard let self else { return }

                let merged = postModels.map { model -> FeedPost in
                    var incoming = FeedPost(from: model)

                    // Keep a just-applied optimistic like/bookmark from being
                    // clobbered by a stale publisher emission mid-flight.
                    if let existing = self.posts.first(where: { $0.id == incoming.id }) {
                        if existing.isLiked != model.isLiked {
                            incoming.isLiked    = existing.isLiked
                            incoming.likesCount = existing.likesCount
                        }
                        if existing.isBookmarked != model.isBookmarked {
                            incoming.isBookmarked = existing.isBookmarked
                        }
                    }

                    return incoming
                }

                logger.debug(
                    "postsPublisher emitted \(merged.count) posts; merged with local interaction state"
                )
                posts = merged
            }
            .store(in: &cancellables)
    }
}
