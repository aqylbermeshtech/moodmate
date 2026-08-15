//
//  ProfileRepository.swift
//  moodmate
//
//  Profile CRUD + local persistence only. Posts live in PostRepository,
//  follow relationships in FollowRepository, avatar files in
//  AvatarRepository, seed content in MockDataProvider — this type used to
//  own all of that as ProfileService, which is why it was split.
//

import UIKit
import FirebaseAuth
import Combine
import OSLog

final class ProfileRepository: ProfileRepositoryProtocol {
    static let shared = ProfileRepository()

    private let logger = Logger(subsystem: "com.moodmate", category: "ProfileRepository")

    private var profiles: [String: UserProfile] = [:]

    private let profileSubject = PassthroughSubject<UserProfile, Never>()
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> {
        profileSubject.eraseToAnyPublisher()
    }

    private let storageKey = "moodmate_user_profiles_v2.json"
    private let fileManager = FileManager.default

    private static let mockDataVersion = 2
    private static let mockDataVersionKey = "moodmate_mock_data_version"

    private var storageFileURL: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(storageKey)
    }

    private let avatarRepository: AvatarRepositoryProtocol

    init(avatarRepository: AvatarRepositoryProtocol = AvatarRepository.shared) {
        self.avatarRepository = avatarRepository
        loadPersistedProfiles()
        invalidateStaleMockProfilesIfNeeded()
        setupMockData()
    }

    private func invalidateStaleMockProfilesIfNeeded() {
        let storedVersion = UserDefaults.standard.integer(forKey: Self.mockDataVersionKey)
        guard storedVersion < Self.mockDataVersion else { return }
        for id in ["1", "2", "3", "4", "5"] {
            profiles.removeValue(forKey: id)
        }
        UserDefaults.standard.set(Self.mockDataVersion, forKey: Self.mockDataVersionKey)
    }

    // MARK: - Synchronous Fetching

    func getProfile(forId id: String?) -> UserProfile? {
        let actualId = id ?? AppSessionManager.currentUserId()
        return profiles[actualId]
    }

    func allProfiles() -> [UserProfile] {
        Array(profiles.values)
    }

    // MARK: - Async Methods

    func fetchProfile(forId id: String?) async throws -> UserProfile? {
        try await Task.sleep(nanoseconds: 100_000_000)
        let actualId = id ?? AppSessionManager.currentUserId()
        return profiles[actualId]
    }

    func refreshProfile(forId id: String?) async throws -> UserProfile? {
        try await Task.sleep(nanoseconds: 50_000_000)
        loadPersistedProfiles()
        let actualId = id ?? AppSessionManager.currentUserId()
        return profiles[actualId]
    }

    func updateProfile(
        id: String,
        displayName: String,
        username: String,
        bio: String,
        location: String? = nil,
        birthday: Date? = nil,
        privacySetting: Visibility = .publicVisibility,
        avatarColorHex: String,
        avatarImageData: Data? = nil,
        clearAvatar: Bool = false
    ) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 200_000_000)

        let actualId = id.isEmpty ? AppSessionManager.currentUserId() : id
        guard var profile = profiles[actualId] else {
            throw AppError.notFound("User profile")
        }

        profile.displayName = displayName
        profile.username = username.lowercased()
        profile.bio = bio
        profile.location = location
        profile.birthday = birthday
        profile.privacySetting = privacySetting
        profile.avatarColorHex = avatarColorHex

        if clearAvatar {
            profile.avatarImageData = nil
            profile.avatarImageName = nil
            try await avatarRepository.deleteAvatar(userId: actualId)
        } else if let newAvatarData = avatarImageData {
            let compressedData = try await avatarRepository.saveAvatar(data: newAvatarData, userId: actualId)
            profile.avatarImageData = compressedData
        }

        setProfile(profile)
        return profile
    }

    func uploadAvatar(image: UIImage, userId: String) async throws -> Data {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw AppError.imageProcessingFailed
        }
        let savedData = try await avatarRepository.saveAvatar(data: data, userId: userId)

        if var profile = profiles[userId] {
            profile.avatarImageData = savedData
            setProfile(profile)
        }

        return savedData
    }

    func deleteAvatar(userId: String) async throws {
        try await avatarRepository.deleteAvatar(userId: userId)
        if var profile = profiles[userId] {
            profile.avatarImageData = nil
            profile.avatarImageName = nil
            setProfile(profile)
        }
    }

    func validateUsername(username: String, currentUserId: String) -> (isValid: Bool, error: String?) {
        let cleaned = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if cleaned.isEmpty {
            return (false, "Username cannot be empty.")
        }

        if cleaned.count < 3 {
            return (false, "Username must be at least 3 characters.")
        }

        if cleaned.count > 30 {
            return (false, "Username cannot exceed 30 characters.")
        }

        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        if cleaned.unicodeScalars.contains(where: { !validCharacters.contains($0) }) {
            return (false, "Only letters, numbers, and underscores are allowed.")
        }

        let isTaken = profiles.values.contains { profile in
            profile.id != currentUserId && profile.username.lowercased() == cleaned
        }

        if isTaken {
            return (false, "Username is already taken.")
        }

        return (true, nil)
    }

    // MARK: - Write Primitive

    func setProfile(_ profile: UserProfile) {
        profiles[profile.id] = profile
        persistProfiles()
        profileSubject.send(profile)
    }

    // MARK: - Firebase Syncing

    func syncWithFirebaseUser(user: User) {
        let currentId = user.uid
        migrateMockProfileToAuthenticatedUser(currentId: currentId)

        let isNewProfile = profiles[currentId] == nil

        var profile = profiles[currentId] ?? MockDataProvider.newAuthenticatedUserSeedProfile(id: currentId, displayName: user.displayName)

        if isNewProfile {
            if let displayName = user.displayName, !displayName.isEmpty {
                profile.displayName = displayName
            } else if let email = user.email {
                let prefix = email.components(separatedBy: "@").first ?? "john"
                profile.displayName = prefix.capitalized
                profile.username = prefix.lowercased()
            }
        }

        if profile.achievements.isEmpty {
            profile.achievements = MockDataProvider.defaultAchievements()
        }
        if profile.moodHistory.isEmpty {
            profile.moodHistory = MockDataProvider.defaultMoodHistory()
        }

        setProfile(profile)
    }

    // MARK: - Persistence Helpers

    private func persistProfiles() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profiles)
            try data.write(to: storageFileURL, options: .atomic)
        } catch {
            logger.error("Failed to persist profiles: \(error, privacy: .public)")
        }
    }

    private func loadPersistedProfiles() {
        guard fileManager.fileExists(atPath: storageFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: storageFileURL)
            let decoded = try JSONDecoder().decode([String: UserProfile].self, from: data)
            for (id, profile) in decoded {
                profiles[id] = profile
            }
        } catch {
            logger.error("Failed to load persisted profiles: \(error, privacy: .public)")
        }
    }

    // MARK: - Mock Data Seeding

    private func migrateMockProfileToAuthenticatedUser(currentId: String) {
        guard currentId != AppSessionManager.mockUserId,
              profiles[currentId] == nil,
              let mockProfile = profiles[AppSessionManager.mockUserId] else {
            return
        }

        var migratedProfile = mockProfile
        migratedProfile.id = currentId
        profiles[currentId] = migratedProfile
    }

    private func setupMockData() {
        let currentId = AppSessionManager.currentUserId()

        if profiles[currentId] == nil {
            var currentUserProfile = MockDataProvider.currentUserSeedProfile(id: currentId)

            if let fbUser = Auth.auth().currentUser {
                if let displayName = fbUser.displayName, !displayName.isEmpty {
                    currentUserProfile.displayName = displayName
                } else if let email = fbUser.email {
                    let prefix = email.components(separatedBy: "@").first ?? "john"
                    currentUserProfile.displayName = prefix.capitalized
                    currentUserProfile.username = prefix.lowercased()
                }
            }

            profiles[currentId] = currentUserProfile
        }

        for friend in MockDataProvider.friendSeedProfiles() where profiles[friend.id] == nil {
            profiles[friend.id] = friend
        }

        let followingCount = profiles.values.filter { $0.id != currentId && $0.isFollowing }.count
        profiles[currentId]?.followingCount = followingCount
    }
}
