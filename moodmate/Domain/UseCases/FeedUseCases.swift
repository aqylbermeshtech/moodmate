//
//  FeedUseCases.swift
//  moodmate
//
//  Feed use cases: fetching/observing posts and the interactions on them.
//  Optimistic UI rollbacks stay in the view model; these are the
//  single-responsibility boundaries to the data layer.
//

import Foundation
import Combine

// MARK: - Fetch Posts

nonisolated protocol FetchFeedPostsUseCaseProtocol {
    func execute() async throws -> [PostModel]
}

nonisolated final class FetchFeedPostsUseCase: FetchFeedPostsUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    func execute() async throws -> [PostModel] {
        try await postRepository.fetchPosts()
    }
}

// MARK: - Fetch Single Post

nonisolated protocol FetchPostUseCaseProtocol {
    func execute(postId: String) -> PostModel?
}

nonisolated final class FetchPostUseCase: FetchPostUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    func execute(postId: String) -> PostModel? {
        postRepository.post(id: postId)
    }
}

// MARK: - Observe Posts

nonisolated protocol ObserveFeedPostsUseCaseProtocol {
    var publisher: AnyPublisher<[PostModel], Never> { get }
}

nonisolated final class ObserveFeedPostsUseCase: ObserveFeedPostsUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    var publisher: AnyPublisher<[PostModel], Never> {
        postRepository.postsPublisher
    }
}

// MARK: - Followed Authors

nonisolated protocol FetchFollowedAuthorIdsUseCaseProtocol {
    func execute() -> Set<String>
}

/// The "Following" tab filter: ids of every account the signed-in user
/// follows, derived from the one-directional local follow graph.
nonisolated final class FetchFollowedAuthorIdsUseCase: FetchFollowedAuthorIdsUseCaseProtocol {
    private let followRepository: FollowRepositoryProtocol

    init(followRepository: FollowRepositoryProtocol) {
        self.followRepository = followRepository
    }

    func execute() -> Set<String> {
        Set(followRepository.getFollowing(forId: nil).map(\.id))
    }
}

// MARK: - Like

nonisolated protocol TogglePostLikeUseCaseProtocol {
    func execute(postId: String, isLiked: Bool) async throws
}

nonisolated final class TogglePostLikeUseCase: TogglePostLikeUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    func execute(postId: String, isLiked: Bool) async throws {
        try await postRepository.setLike(postId: postId, isLiked: isLiked)
    }
}

// MARK: - Bookmark

nonisolated protocol TogglePostBookmarkUseCaseProtocol {
    func execute(postId: String) async throws
}

nonisolated final class TogglePostBookmarkUseCase: TogglePostBookmarkUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    func execute(postId: String) async throws {
        try await postRepository.toggleBookmark(postId: postId)
    }
}

// MARK: - Delete

nonisolated protocol DeletePostUseCaseProtocol {
    func execute(postId: String) async throws
}

nonisolated final class DeletePostUseCase: DeletePostUseCaseProtocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    func execute(postId: String) async throws {
        try await postRepository.deletePost(id: postId)
    }
}
