import Combine
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var posts: [FeedPost] = []
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let postService: PostServiceProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        postService: PostServiceProtocol = MockPostService.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository()
    ) {
        self.postService = postService
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
                let initialPosts = try await postService.fetchPosts()
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

        let previousLiked = posts[index].isLiked
        let previousCount = posts[index].likesCount

        posts[index].isLiked    = !previousLiked
        posts[index].likesCount = previousLiked ? previousCount - 1 : previousCount + 1

        Task {
            do {
                try await postService.toggleLike(postId: post.id)
            } catch {
                if let rollbackIndex = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[rollbackIndex].isLiked    = previousLiked
                    posts[rollbackIndex].likesCount = previousCount
                }
                errorMessage = "Could not update like. Please try again."
            }
        }
    }

    func toggleBookmark(for post: FeedPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }

        let previousBookmarked = posts[index].isBookmarked

        posts[index].isBookmarked = !previousBookmarked

        Task {
            do {
                try await postService.toggleBookmark(postId: post.id)
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
        postService.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] postModels in
                self?.posts = postModels.map { FeedPost(from: $0) }
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
