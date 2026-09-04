//
//  ProfileRepository.swift
//  moodmate
//
//  Profile CRUD + local persistence only. Posts, follows, and avatars live in
//  their own repositories (this was once one ProfileService).
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

    private let storageKey = "moodmate_user_profiles_v3.json"

    /// Files written by builds that seeded fake profiles. Removed on first
    /// launch so that content can't come back from disk.
    private static let legacyStorageKeys = ["moodmate_user_profiles_v2.json"]
    private static let legacyDefaultsKeys = ["moodmate_mock_data_version"]

    private let fileManager = FileManager.default

    private var storageFileURL: URL {
        documentsDirectory.appendingPathComponent(storageKey)
    }

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private let avatarRepository: AvatarRepositoryProtocol

    init(avatarRepository: AvatarRepositoryProtocol = AvatarRepository.shared) {
        self.avatarRepository = avatarRepository
        removeLegacyStorage()
        loadPersistedProfiles()
    }

    private func removeLegacyStorage() {
        for key in Self.legacyStorageKeys {
            try? fileManager.removeItem(at: documentsDirectory.appendingPathComponent(key))
        }
        for key in Self.legacyDefaultsKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
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
        interests: [String] = [],
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
        profile.interests = interests

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

    func updateInterests(_ interestIds: [String], forId id: String) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 200_000_000)

        let actualId = id.isEmpty ? AppSessionManager.currentUserId() : id
        guard var profile = profiles[actualId] else {
            throw AppError.notFound("User profile")
        }

        profile.interests = interestIds
        profile.hasCompletedOnboarding = true

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
        let profile = profiles[user.uid] ?? Self.profile(for: user)
        setProfile(profile)
    }

    /// A brand new account: everything the app knows comes from the Firebase
    /// user itself. Bio, location, and birthday stay empty until the user
    /// fills them in from Edit Profile.
    static func profile(for user: User) -> UserProfile {
        let emailPrefix = user.email?
            .components(separatedBy: "@").first?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedDisplayName = user.displayName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let displayName: String
        if !trimmedDisplayName.isEmpty {
            displayName = trimmedDisplayName
        } else if let emailPrefix, !emailPrefix.isEmpty {
            displayName = emailPrefix.capitalized
        } else {
            displayName = ""
        }

        return UserProfile(
            id: user.uid,
            displayName: displayName,
            username: defaultUsername(emailPrefix: emailPrefix, displayName: displayName, uid: user.uid),
            avatarColorHex: UserProfile.defaultAvatarColorHex,
            bio: "",
            isFollowing: false
        )
    }

    private static func defaultUsername(emailPrefix: String?, displayName: String, uid: String) -> String {
        for candidate in [emailPrefix ?? "", displayName] {
            let sanitized = candidate
                .lowercased()
                .filter { $0.isLetter || $0.isNumber || $0 == "_" }
            if sanitized.count >= 3 { return String(sanitized.prefix(30)) }
        }
        return "user\(uid.lowercased().prefix(8))"
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
}
