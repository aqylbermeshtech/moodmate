//
//  ProfileUseCases.swift
//  moodmate
//
//  Profile and social-graph use cases.
//

import Foundation
import Combine

// MARK: - Fetch Profile

nonisolated protocol FetchProfileUseCaseProtocol {
    /// Synchronous read from the local store.
    func execute(forId id: String?) -> UserProfile?
    /// Async refresh (simulates a remote round-trip today).
    func executeAsync(forId id: String?) async throws -> UserProfile?
}

nonisolated final class FetchProfileUseCase: FetchProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(forId id: String?) -> UserProfile? {
        profileRepository.getProfile(forId: id)
    }

    func executeAsync(forId id: String?) async throws -> UserProfile? {
        try await profileRepository.fetchProfile(forId: id)
    }
}

// MARK: - Observe Profile Updates

nonisolated protocol ObserveProfileUpdatesUseCaseProtocol {
    var publisher: AnyPublisher<UserProfile, Never> { get }
}

nonisolated final class ObserveProfileUpdatesUseCase: ObserveProfileUpdatesUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    var publisher: AnyPublisher<UserProfile, Never> {
        profileRepository.profileUpdatesPublisher
    }
}

// MARK: - Session Profile Sync

nonisolated protocol SyncProfileWithAuthUserUseCaseProtocol {
    /// Upserts the local profile for a freshly authenticated user.
    func execute(user: AuthUser)
}

nonisolated final class SyncProfileWithAuthUserUseCase: SyncProfileWithAuthUserUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(user: AuthUser) {
        profileRepository.syncWithAuthUser(user)
    }
}

// MARK: - Update Profile

/// Input for `UpdateProfileUseCase` — keeps the call site readable instead
/// of an eleven-argument method.
nonisolated struct UpdateProfileInput {
    var displayName: String
    var username: String
    var bio: String
    var location: String?
    var birthday: Date?
    var privacySetting: Visibility
    var avatarColorHex: String
    var interests: [String]
    var avatarImageData: Data?
    var clearAvatar: Bool
}

nonisolated protocol UpdateProfileUseCaseProtocol {
    func execute(userId: String, input: UpdateProfileInput) async throws -> UserProfile
}

nonisolated final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(userId: String, input: UpdateProfileInput) async throws -> UserProfile {
        try await profileRepository.updateProfile(
            id: userId,
            displayName: input.displayName,
            username: input.username,
            bio: input.bio,
            location: input.location,
            birthday: input.birthday,
            privacySetting: input.privacySetting,
            avatarColorHex: input.avatarColorHex,
            interests: input.interests,
            avatarImageData: input.avatarImageData,
            clearAvatar: input.clearAvatar
        )
    }
}

// MARK: - Validate Username

nonisolated protocol ValidateUsernameUseCaseProtocol {
    func execute(username: String, currentUserId: String) -> (isValid: Bool, error: String?)
}

nonisolated final class ValidateUsernameUseCase: ValidateUsernameUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(username: String, currentUserId: String) -> (isValid: Bool, error: String?) {
        profileRepository.validateUsername(username: username, currentUserId: currentUserId)
    }
}

// MARK: - Toggle Follow

nonisolated protocol ToggleFollowUseCaseProtocol {
    /// A follow toggle is only meaningful for someone other than yourself.
    func execute(targetId: String) -> UserProfile?
}

nonisolated final class ToggleFollowUseCase: ToggleFollowUseCaseProtocol {
    private let followRepository: FollowRepositoryProtocol
    private let currentUserProvider: CurrentUserProviderProtocol

    init(followRepository: FollowRepositoryProtocol, currentUserProvider: CurrentUserProviderProtocol) {
        self.followRepository = followRepository
        self.currentUserProvider = currentUserProvider
    }

    func execute(targetId: String) -> UserProfile? {
        guard targetId != currentUserProvider.currentUserId else { return nil }
        return followRepository.toggleFollow(targetId: targetId)
    }
}

// MARK: - Follow Lists

nonisolated protocol FetchFollowListsUseCaseProtocol {
    func followers(forId id: String?) -> [UserProfile]
    func following(forId id: String?) -> [UserProfile]
}

nonisolated final class FetchFollowListsUseCase: FetchFollowListsUseCaseProtocol {
    private let followRepository: FollowRepositoryProtocol

    init(followRepository: FollowRepositoryProtocol) {
        self.followRepository = followRepository
    }

    func followers(forId id: String?) -> [UserProfile] {
        followRepository.getFollowers(forId: id)
    }

    func following(forId id: String?) -> [UserProfile] {
        followRepository.getFollowing(forId: id)
    }
}

// MARK: - Update Interests

nonisolated protocol UpdateInterestsUseCaseProtocol {
    func execute(_ interestIds: [String], forId id: String) async throws -> UserProfile
}

nonisolated final class UpdateInterestsUseCase: UpdateInterestsUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(_ interestIds: [String], forId id: String) async throws -> UserProfile {
        try await profileRepository.updateInterests(interestIds, forId: id)
    }
}

// MARK: - Avatars

nonisolated protocol UploadAvatarUseCaseProtocol {
    /// Takes already-compressed JPEG data — UIImage handling is presentation.
    func execute(data: Data, userId: String) async throws -> Data
}

nonisolated final class UploadAvatarUseCase: UploadAvatarUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(data: Data, userId: String) async throws -> Data {
        try await profileRepository.uploadAvatar(data: data, userId: userId)
    }
}

nonisolated protocol DeleteAvatarUseCaseProtocol {
    func execute(userId: String) async throws
}

nonisolated final class DeleteAvatarUseCase: DeleteAvatarUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func execute(userId: String) async throws {
        try await profileRepository.deleteAvatar(userId: userId)
    }
}
