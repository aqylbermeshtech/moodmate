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

    // MARK: - Dependencies

    private let fetchProfileUseCase: FetchProfileUseCaseProtocol
    private let observeProfileUpdatesUseCase: ObserveProfileUpdatesUseCaseProtocol
    private let fetchCurrentAuthUserUseCase: FetchCurrentAuthUserUseCaseProtocol
    private let currentUserProvider: CurrentUserProviderProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        feed: FeedViewModel? = nil,
        fetchProfileUseCase: FetchProfileUseCaseProtocol = DIContainer.shared.fetchProfileUseCase,
        observeProfileUpdatesUseCase: ObserveProfileUpdatesUseCaseProtocol = DIContainer.shared.observeProfileUpdatesUseCase,
        fetchCurrentAuthUserUseCase: FetchCurrentAuthUserUseCaseProtocol = DIContainer.shared.fetchCurrentAuthUserUseCase,
        currentUserProvider: CurrentUserProviderProtocol = DIContainer.shared.currentUserProvider
    ) {
        // Resolved in the (MainActor) init body: default argument expressions
        // are nonisolated in Swift 5 language mode.
        self.feed = feed ?? FeedViewModel()
        self.fetchProfileUseCase = fetchProfileUseCase
        self.observeProfileUpdatesUseCase = observeProfileUpdatesUseCase
        self.fetchCurrentAuthUserUseCase = fetchCurrentAuthUserUseCase
        self.currentUserProvider = currentUserProvider
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
        let userId = currentUserProvider.currentUserId
        if let profile = fetchProfileUseCase.execute(forId: userId) {
            applyCurrentUser(profile)
        } else if let name = fetchCurrentAuthUserUseCase.execute()?.resolvedDisplayName {
            currentUserDisplayName = name
        }
    }

    func observeProfileUpdates() {
        observeProfileUpdatesUseCase.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                if profile.id == self.currentUserProvider.currentUserId {
                    self.applyCurrentUser(profile)
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
