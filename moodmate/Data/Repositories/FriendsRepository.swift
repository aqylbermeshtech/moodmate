import Foundation

/// "Friends" are the accounts the signed-in user follows — the only social
/// graph the local store can answer for. See `FollowRepository`.
nonisolated final class FriendsRepository: FriendsRepositoryProtocol {

    private let followRepository: FollowRepositoryProtocol

    init(followRepository: FollowRepositoryProtocol) {
        self.followRepository = followRepository
    }

    func loadFriends() -> [AppUser] {
        followRepository.getFollowing(forId: nil).map { profile in
            AppUser(
                id:              profile.id,
                name:            profile.displayName,
                username:        profile.username,
                avatarImageData: profile.avatarImageData,
                avatarColorHex:  profile.avatarColorHex
            )
        }
    }
}
