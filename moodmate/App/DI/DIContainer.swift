//
//  DIContainer.swift
//  moodmate
//
//  Composition root. This is the only place in the app that knows which
//  concrete types satisfy the domain's protocols. Repositories are lazy
//  singletons (they own state); use cases are stateless and created on
//  demand.
//
//  View models default their dependencies to `DIContainer.shared.<useCase>`
//  so existing view call sites keep working; tests inject fakes through the
//  same initializers.
//

import Foundation

/// Explicitly nonisolated (the target builds with MainActor default
/// isolation) so view models can reference use cases in default argument
/// expressions, which are nonisolated contexts. Only the two
/// MainActor-constrained members are isolated; everything else is a plain
/// class safe to build and hand out from any context. In practice every
/// access happens on the main actor via view model initializers.
nonisolated final class DIContainer {
    static let shared = DIContainer()

    private init() {}

    // MARK: - Data: services

    private lazy var authService: AuthServiceProtocol = FirebaseAuthService()
    private(set) lazy var currentUserProvider: CurrentUserProviderProtocol = CurrentUserProvider(authService: authService)
    private lazy var draftStore: DraftStoreProtocol = DraftManager()

    // MARK: - Data: repositories

    private lazy var avatarRepository: AvatarRepositoryProtocol = AvatarRepository()
    private lazy var postRepository: PostRepositoryProtocol = PostRepository()
    private lazy var profileRepository: ProfileRepositoryProtocol = ProfileRepository(
        avatarRepository: avatarRepository,
        currentUserProvider: currentUserProvider
    )
    private lazy var followRepository: FollowRepositoryProtocol = FollowRepository(
        profileRepository: profileRepository,
        currentUserProvider: currentUserProvider
    )
    private lazy var friendsRepository: FriendsRepositoryProtocol = FriendsRepository(
        followRepository: followRepository
    )
    private lazy var discoverService: DiscoverServiceProtocol = DiscoverService(
        postRepository: postRepository,
        profileRepository: profileRepository,
        followRepository: followRepository,
        currentUserProvider: currentUserProvider
    )

    /// Identity projection read directly by views (post cards, search rows).
    @MainActor private(set) lazy var userStore: UserStoreProtocol = UserStore(profileRepository: profileRepository)

    // MARK: - Session

    @MainActor private(set) lazy var sessionManager: AppSessionManager = AppSessionManager(
        authService: authService,
        profileRepository: profileRepository
    )

    // MARK: - Use cases: Auth

    var signInUseCase: SignInUseCaseProtocol { SignInUseCase(authService: authService) }
    var signUpUseCase: SignUpUseCaseProtocol { SignUpUseCase(authService: authService, profileRepository: profileRepository) }
    var signOutUseCase: SignOutUseCaseProtocol { SignOutUseCase(authService: authService) }
    var fetchCurrentAuthUserUseCase: FetchCurrentAuthUserUseCaseProtocol { FetchCurrentAuthUserUseCase(authService: authService) }

    // MARK: - Use cases: Feed

    var fetchFeedPostsUseCase: FetchFeedPostsUseCaseProtocol { FetchFeedPostsUseCase(postRepository: postRepository) }
    var fetchPostUseCase: FetchPostUseCaseProtocol { FetchPostUseCase(postRepository: postRepository) }
    var observeFeedPostsUseCase: ObserveFeedPostsUseCaseProtocol { ObserveFeedPostsUseCase(postRepository: postRepository) }
    var fetchFollowedAuthorIdsUseCase: FetchFollowedAuthorIdsUseCaseProtocol { FetchFollowedAuthorIdsUseCase(followRepository: followRepository) }
    var togglePostLikeUseCase: TogglePostLikeUseCaseProtocol { TogglePostLikeUseCase(postRepository: postRepository) }
    var togglePostBookmarkUseCase: TogglePostBookmarkUseCaseProtocol { TogglePostBookmarkUseCase(postRepository: postRepository) }
    var deletePostUseCase: DeletePostUseCaseProtocol { DeletePostUseCase(postRepository: postRepository) }

    // MARK: - Use cases: Create Post

    var createPostUseCase: CreatePostUseCaseProtocol { CreatePostUseCase(postRepository: postRepository, currentUserProvider: currentUserProvider) }
    var savePostDraftUseCase: SavePostDraftUseCaseProtocol { SavePostDraftUseCase(draftStore: draftStore) }
    var loadPostDraftUseCase: LoadPostDraftUseCaseProtocol { LoadPostDraftUseCase(draftStore: draftStore) }
    var clearPostDraftUseCase: ClearPostDraftUseCaseProtocol { ClearPostDraftUseCase(draftStore: draftStore) }

    // MARK: - Use cases: Profile

    var fetchProfileUseCase: FetchProfileUseCaseProtocol { FetchProfileUseCase(profileRepository: profileRepository) }
    var syncProfileWithAuthUserUseCase: SyncProfileWithAuthUserUseCaseProtocol { SyncProfileWithAuthUserUseCase(profileRepository: profileRepository) }
    var observeProfileUpdatesUseCase: ObserveProfileUpdatesUseCaseProtocol { ObserveProfileUpdatesUseCase(profileRepository: profileRepository) }
    var updateProfileUseCase: UpdateProfileUseCaseProtocol { UpdateProfileUseCase(profileRepository: profileRepository) }
    var validateUsernameUseCase: ValidateUsernameUseCaseProtocol { ValidateUsernameUseCase(profileRepository: profileRepository) }
    var toggleFollowUseCase: ToggleFollowUseCaseProtocol { ToggleFollowUseCase(followRepository: followRepository, currentUserProvider: currentUserProvider) }
    var fetchFollowListsUseCase: FetchFollowListsUseCaseProtocol { FetchFollowListsUseCase(followRepository: followRepository) }
    var updateInterestsUseCase: UpdateInterestsUseCaseProtocol { UpdateInterestsUseCase(profileRepository: profileRepository) }
    var uploadAvatarUseCase: UploadAvatarUseCaseProtocol { UploadAvatarUseCase(profileRepository: profileRepository) }
    var deleteAvatarUseCase: DeleteAvatarUseCaseProtocol { DeleteAvatarUseCase(profileRepository: profileRepository) }

    // MARK: - Use cases: Discover

    var fetchSuggestedUsersUseCase: FetchSuggestedUsersUseCaseProtocol { FetchSuggestedUsersUseCase(discoverService: discoverService) }
    var fetchTrendingHashtagsUseCase: FetchTrendingHashtagsUseCaseProtocol { FetchTrendingHashtagsUseCase(discoverService: discoverService) }
    var fetchDiscoverCategoriesUseCase: FetchDiscoverCategoriesUseCaseProtocol { FetchDiscoverCategoriesUseCase(discoverService: discoverService) }
    var fetchDiscoverPostsUseCase: FetchDiscoverPostsUseCaseProtocol { FetchDiscoverPostsUseCase(discoverService: discoverService) }
    var searchDiscoverUseCase: SearchDiscoverUseCaseProtocol { SearchDiscoverUseCase(discoverService: discoverService) }

    // MARK: - Use cases: Chat

    var fetchConversationsUseCase: FetchConversationsUseCaseProtocol { FetchConversationsUseCase(friendsRepository: friendsRepository) }
    var fetchChatParticipantUseCase: FetchChatParticipantUseCaseProtocol { FetchChatParticipantUseCase(profileRepository: profileRepository) }

    // MARK: - Use cases: Onboarding

    var observeCurrentProfileUseCase: ObserveCurrentProfileUseCaseProtocol {
        ObserveCurrentProfileUseCase(profileRepository: profileRepository, currentUserProvider: currentUserProvider)
    }

    // MARK: - Presentation helpers

    /// Read-only identity lookup for the signed-in user, used by view models
    /// that render the current user (home greeting, post composer).
    var currentUserId: String { currentUserProvider.currentUserId }
}
