//
//  PostDetailViewModel.swift
//  moodmate
//
//  Post detail screen state: the post itself (kept in sync with the store),
//  optimistic like/bookmark, delete, and screen-local comments.
//

import SwiftUI
import Combine

@MainActor
final class PostDetailViewModel: ObservableObject {
    let postId: String

    @Published private(set) var displayPost: FeedPost?
    @Published private(set) var didLoad = false
    @Published var errorMessage: String?

    /// Comments live only for the lifetime of this screen — there is no
    /// comment store behind them yet.
    @Published private(set) var comments: [PostComment] = []

    private let fetchPostUseCase: FetchPostUseCaseProtocol
    private let observeFeedPostsUseCase: ObserveFeedPostsUseCaseProtocol
    private let togglePostLikeUseCase: TogglePostLikeUseCaseProtocol
    private let togglePostBookmarkUseCase: TogglePostBookmarkUseCaseProtocol
    private let deletePostUseCase: DeletePostUseCaseProtocol
    private let fetchProfileUseCase: FetchProfileUseCaseProtocol
    private let currentUserProvider: CurrentUserProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    init(postId: String,
         fetchPostUseCase: FetchPostUseCaseProtocol = DIContainer.shared.fetchPostUseCase,
         observeFeedPostsUseCase: ObserveFeedPostsUseCaseProtocol = DIContainer.shared.observeFeedPostsUseCase,
         togglePostLikeUseCase: TogglePostLikeUseCaseProtocol = DIContainer.shared.togglePostLikeUseCase,
         togglePostBookmarkUseCase: TogglePostBookmarkUseCaseProtocol = DIContainer.shared.togglePostBookmarkUseCase,
         deletePostUseCase: DeletePostUseCaseProtocol = DIContainer.shared.deletePostUseCase,
         fetchProfileUseCase: FetchProfileUseCaseProtocol = DIContainer.shared.fetchProfileUseCase,
         currentUserProvider: CurrentUserProviderProtocol = DIContainer.shared.currentUserProvider) {
        self.postId = postId
        self.fetchPostUseCase = fetchPostUseCase
        self.observeFeedPostsUseCase = observeFeedPostsUseCase
        self.togglePostLikeUseCase = togglePostLikeUseCase
        self.togglePostBookmarkUseCase = togglePostBookmarkUseCase
        self.deletePostUseCase = deletePostUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.currentUserProvider = currentUserProvider
    }

    func onAppear() {
        guard !didLoad else { return }

        if let post = fetchPostUseCase.execute(postId: postId) {
            displayPost = FeedPost(from: post)
        }
        didLoad = true

        observeFeedPostsUseCase.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedPosts in
                guard let self,
                      let matching = updatedPosts.first(where: { $0.id == self.postId }) else { return }
                var updated = FeedPost(from: matching)
                updated.commentsCount = max(updated.commentsCount, self.comments.count)
                self.displayPost = updated
            }
            .store(in: &cancellables)
    }

    /// Only your own posts can be deleted — mirrors `FeedViewModel.canDelete`.
    var canDelete: Bool {
        guard let post = displayPost else { return false }
        return !post.authorId.isEmpty && post.authorId == currentUserProvider.currentUserId
    }

    func deletePost(onSuccess: @escaping () -> Void) {
        Task {
            do {
                try await deletePostUseCase.execute(postId: postId)
                onSuccess()
            } catch {
                errorMessage = "Could not delete that post. Please try again."
            }
        }
    }

    func toggleLike() {
        guard let currentPost = displayPost else { return }
        let desiredLikeState = !currentPost.isLiked
        let previousLiked = currentPost.isLiked
        let previousCount = currentPost.likesCount
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            displayPost?.isLiked = desiredLikeState
            displayPost?.likesCount += desiredLikeState ? 1 : -1
        }
        Task {
            do {
                try await togglePostLikeUseCase.execute(postId: postId, isLiked: desiredLikeState)
            } catch {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    displayPost?.isLiked = previousLiked
                    displayPost?.likesCount = previousCount
                }
                errorMessage = "Could not update like. Please try again."
            }
        }
    }

    func toggleBookmark() {
        guard let currentPost = displayPost else { return }
        let previousBookmarked = currentPost.isBookmarked
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            displayPost?.isBookmarked.toggle()
        }
        Task {
            do {
                try await togglePostBookmarkUseCase.execute(postId: postId)
            } catch {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    displayPost?.isBookmarked = previousBookmarked
                }
                errorMessage = "Could not update bookmark. Please try again."
            }
        }
    }

    func addComment(text: String) {
        guard !text.isEmpty else { return }

        let author = fetchProfileUseCase.execute(forId: nil)

        let newComment = PostComment(
            name: author?.displayName ?? "You",
            username: author?.username ?? "",
            avatarColorHex: author?.avatarColorHex ?? UserProfile.defaultAvatarColorHex,
            text: text,
            timeAgo: "Just now"
        )

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            comments.append(newComment)
            displayPost?.commentsCount = comments.count
        }
    }
}
