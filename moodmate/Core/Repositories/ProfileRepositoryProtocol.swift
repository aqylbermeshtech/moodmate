import UIKit
import Combine
import FirebaseAuth

protocol ProfileRepositoryProtocol: AnyObject {
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }

    func getProfile(forId id: String?) -> UserProfile?

    /// All known profiles. Used by FollowRepository's mock follower/
    /// following queries, which need to enumerate rather than look up by
    /// id. A real backend implementation would likely serve this narrower
    /// (e.g. a proper follow-edges query instead of "all profiles") — kept
    /// as-is here to preserve today's mock behavior exactly.
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
        privacySetting: PrivacySetting,
        avatarColorHex: String,
        avatarImageData: Data?,
        clearAvatar: Bool
    ) async throws -> UserProfile

    func uploadAvatar(image: UIImage, userId: String) async throws -> Data

    func deleteAvatar(userId: String) async throws

    func validateUsername(username: String, currentUserId: String) -> (isValid: Bool, error: String?)

    /// Upserts an already-fully-formed profile record (persist + broadcast),
    /// with no field validation or avatar handling of its own. This is the
    /// primitive FollowRepository writes through when it bumps
    /// followers/following counts — those aren't user-edited profile
    /// fields, so they don't belong going through updateProfile's
    /// validation/avatar pipeline.
    func setProfile(_ profile: UserProfile)
}
