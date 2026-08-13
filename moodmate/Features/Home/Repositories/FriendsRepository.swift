import Foundation

final class FriendsRepository: FriendsRepositoryProtocol {

    private let service: ProfileRepositoryProtocol

    init(service: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.service = service
    }

    func loadFriends() -> [MoodUser] {

        let friendIds = ["1", "2", "3", "4", "5"]
        return friendIds.compactMap { id in
            guard let profile = service.getProfile(forId: id) else { return nil }
            return MoodUser(
                id:                  profile.id,
                name:                profile.displayName,
                username:            profile.username,
                avatarImageData:     profile.avatarImageData,
                avatarColorHex:      profile.avatarColorHex,
                currentMoodEmoji:    profile.currentMoodEmoji,
                currentMoodText:     profile.currentMoodText,
                currentMoodColorHex: profile.currentMoodColorHex
            )
        }
    }
}
