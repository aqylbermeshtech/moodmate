//
//  ProfileRepositoryProtocol.swift
//  moodmate
//
//  Profile persistence contract. Purified of UIKit and FirebaseAuth:
//  avatars are `Data`, and session sync takes the domain `AuthUser`.
//

import Foundation
import Combine

nonisolated protocol ProfileRepositoryProtocol: AnyObject {
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }

    func getProfile(forId id: String?) -> UserProfile?

    func allProfiles() -> [UserProfile]

    func fetchProfile(forId id: String?) async throws -> UserProfile?

    func refreshProfile(forId id: String?) async throws -> UserProfile?

    func syncWithAuthUser(_ user: AuthUser)

    func updateProfile(
        id: String,
        displayName: String,
        username: String,
        bio: String,
        location: String?,
        birthday: Date?,
        privacySetting: Visibility,
        avatarColorHex: String,
        interests: [String],
        avatarImageData: Data?,
        clearAvatar: Bool
    ) async throws -> UserProfile

    /// Saves the user's interest picks and marks onboarding as done. Used by
    /// the onboarding flow, which has no other profile fields to write.
    func updateInterests(_ interestIds: [String], forId id: String) async throws -> UserProfile

    /// Persists already-compressed avatar JPEG data and attaches it to the
    /// profile. Compressing a UIImage is the caller's job.
    func uploadAvatar(data: Data, userId: String) async throws -> Data

    func deleteAvatar(userId: String) async throws

    func validateUsername(username: String, currentUserId: String) -> (isValid: Bool, error: String?)

    /// Upserts a fully-formed record (persist + broadcast) with no validation
    /// or avatar handling — the write primitive for non-user-edited fields.
    func setProfile(_ profile: UserProfile)
}
