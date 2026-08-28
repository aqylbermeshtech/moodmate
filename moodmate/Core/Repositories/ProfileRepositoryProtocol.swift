import UIKit
import Combine
import FirebaseAuth

protocol ProfileRepositoryProtocol: AnyObject {
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }

    func getProfile(forId id: String?) -> UserProfile?

    func allProfiles() -> [UserProfile]

    func fetchProfile(forId id: String?) async throws -> UserProfile?

    func refreshProfile(forId id: String?) async throws -> UserProfile?

    func syncWithFirebaseUser(user: User)

    func updateProfile(
        id: String,
        displayName: String,
        username: String,
        bio: String,
        location: String?,
        birthday: Date?,
        privacySetting: Visibility,
        avatarColorHex: String,
        avatarImageData: Data?,
        clearAvatar: Bool
    ) async throws -> UserProfile

    func uploadAvatar(image: UIImage, userId: String) async throws -> Data

    func deleteAvatar(userId: String) async throws

    func validateUsername(username: String, currentUserId: String) -> (isValid: Bool, error: String?)

    /// Upserts a fully-formed record (persist + broadcast) with no validation
    /// or avatar handling — the write primitive for non-user-edited fields.
    func setProfile(_ profile: UserProfile)
}
