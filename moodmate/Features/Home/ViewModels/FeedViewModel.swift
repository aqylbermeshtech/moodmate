import Combine
import Foundation
import OSLog

@MainActor
final class FeedViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var posts: [FeedPost] = [] {
        didSet {
            guard let firstPost = posts.first else { return }
            logger.debug(
                "feed posts assigned: \(firstPost.id, privacy: .public) liked \(firstPost.isLiked, privacy: .public), count \(firstPost.likesCount, privacy: .public)"
            )
        }
    }
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let postRepository: PostRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.moodmate", category: "FeedViewModel")

    // MARK: - Init

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository()
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
        observeProfileUpdates()

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

        // Optimistic update — mutate the struct in-place so SwiftUI redraws this frame.
        posts[index].isLiked    = desiredLikeState
        posts[index].likesCount = desiredLikeState ? previousCount + 1 : previousCount - 1

        logger.debug(
            "Like optimistic for \(post.id, privacy: .public): \(previousLiked, privacy: .public)→\(desiredLikeState, privacy: .public), count \(previousCount, privacy: .public)→\(self.posts[index].likesCount, privacy: .public)"
        )

        Task {
            do {
                try await postRepository.setLike(postId: post.id, isLiked: desiredLikeState)
            } catch {
                // Rollback the optimistic update so UI stays consistent.
                if let rollbackIndex = self.posts.firstIndex(where: { $0.id == post.id }) {
                    self.posts[rollbackIndex].isLiked    = previousLiked
                    self.posts[rollbackIndex].likesCount = previousCount
                }
                self.errorMessage = "Could not update like. Please try again."
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

    private func observePosts() {
        postRepository.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] postModels in
                guard let self else { return }

                let merged = postModels.map { model -> FeedPost in
                    var incoming = FeedPost(from: model)

                    // If we already hold a local copy of this post, preserve any
                    // in-flight interaction state (isLiked, isBookmarked) so that
                    // an optimistic update applied synchronously by toggleLike /
                    // toggleBookmark is never silently overwritten by a publisher
                    // emission that carries stale server values.
                    //
                    // Once the service's own @Published update arrives *after*
                    // the async call completes, the local and remote values will
                    // agree and the guard below becomes a no-op.
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

    private func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedProfile in
                guard let self else { return }
                posts = posts.map { post in
                    post.user.id == updatedProfile.id
                        ? post.updatingAuthor(from: updatedProfile)
                        : post
                }
            }
            .store(in: &cancellables)
    }
}
