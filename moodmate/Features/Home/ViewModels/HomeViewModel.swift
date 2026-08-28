import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentUserDisplayName: String = ""
    @Published private(set) var currentUserAvatarData: Data?
    @Published private(set) var currentUserAvatarColorHex: String = "38B2AC"

    // MARK: - Composed child ViewModel

    let feed: FeedViewModel

    // MARK: - Dependencies (all injected — no singletons)

    private let profileRepository: ProfileRepositoryProtocol
    private let authService: AuthServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
        authService: AuthServiceProtocol = FirebaseAuthService.shared
    ) {
        self.profileRepository = profileRepository
        self.authService       = authService
        self.feed = FeedViewModel(postRepository: postRepository, profileRepository: profileRepository)
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadCurrentUser()
        startObserving()
    }

    func startObserving() {
        feed.startObserving()
        observeProfileUpdates()
    }

    func stopObserving() {
        feed.stopObserving()
        cancellables.removeAll()
    }

    // MARK: - Feed delegation (keeps call sites in HomeView clean)

    func addNewlyCreatedPost(_ postModel: PostModel) {
        feed.addNewlyCreatedPost(postModel)
    }
}

// MARK: - Private helpers

private extension HomeViewModel {

    func loadCurrentUser() {
        let userId = AppSessionManager.currentUserId()
        if let profile = profileRepository.getProfile(forId: userId) {
            applyCurrentUser(profile)
        } else if let name = authService.currentUserDisplayName {
            currentUserDisplayName = name
        }
    }

    func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                let currentId = AppSessionManager.currentUserId()

                if profile.id == currentId {
                    applyCurrentUser(profile)
                }
            }
            .store(in: &cancellables)
    }

    func applyCurrentUser(_ profile: UserProfile) {
        currentUserDisplayName    = profile.displayName
        currentUserAvatarData     = profile.avatarImageData
        currentUserAvatarColorHex = profile.avatarColorHex
    }
}
