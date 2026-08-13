import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentUserDisplayName: String = ""
    @Published private(set) var currentUserAvatarData: Data?
    @Published private(set) var currentUserAvatarColorHex: String = "38B2AC"

    @Published private(set) var friends: [MoodUser] = []

    @Published var selectedMood: SelectedMood?
    @Published var showMoodPickerSheet = false

    @Published private(set) var errorMessage: String?

    // MARK: - Composed child ViewModel

    let feed: FeedViewModel

    // MARK: - Convenience accessors (backwards-compat for MoodCard / MoodPickerSheet)

    let moodOptions: [MoodOption] = MoodOption.catalog

    // MARK: - Dependencies (all injected — no singletons)

    private let profileRepository: ProfileRepositoryProtocol
    private let friendsRepository: FriendsRepositoryProtocol
    private let authService: AuthServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        postRepository: PostRepositoryProtocol = PostRepository.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared,
        friendsRepository: FriendsRepositoryProtocol = FriendsRepository(),
        authService: AuthServiceProtocol = FirebaseAuthService.shared
    ) {
        self.profileRepository = profileRepository
        self.friendsRepository = friendsRepository
        self.authService       = authService
        self.feed = FeedViewModel(postRepository: postRepository)
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadCurrentUser()
        loadFriends()
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

    // MARK: - Mood

    func selectMood(emoji: String, text: String, colorHex: String) {
        selectedMood = SelectedMood(emoji: emoji, text: text, colorHex: colorHex)
    }

    func clearMood() {
        selectedMood = nil
    }

    // MARK: - Feed delegation (keeps call sites in HomeView clean)

    func addNewlyCreatedPost(_ postModel: PostModel) {
        feed.addNewlyCreatedPost(postModel)
    }

    // MARK: - Authentication

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Presentation strings

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        default:      return "Good Evening,"
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
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

    func loadFriends() {
        friends = friendsRepository.loadFriends()
    }

    func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                let currentId = AppSessionManager.currentUserId()

                if profile.id == currentId {
                    updateCurrentUser(profile)
                }
                updateFriend(profile)
            }
            .store(in: &cancellables)
    }

    // MARK: Profile update helpers

    func updateCurrentUser(_ profile: UserProfile) {
        applyCurrentUser(profile)
    }

    func applyCurrentUser(_ profile: UserProfile) {
        currentUserDisplayName    = profile.displayName
        currentUserAvatarData     = profile.avatarImageData
        currentUserAvatarColorHex = profile.avatarColorHex
    }

    func updateFriend(_ profile: UserProfile) {
        guard let index = friends.firstIndex(where: { $0.id == profile.id }) else { return }
        friends[index].name            = profile.displayName
        friends[index].username        = profile.username
        friends[index].avatarColorHex  = profile.avatarColorHex
        friends[index].avatarImageData = profile.avatarImageData
    }


}
