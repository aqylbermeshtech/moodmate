//
//  ProfileService.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import UIKit
import FirebaseAuth
import Combine

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    
    private var profiles: [String: UserProfile] = [:]
    private var posts: [String: [ProfilePost]] = [:]
    
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

    private let profileImageService: ProfileImageServiceProtocol

    init(profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared) {
        self.profileImageService = profileImageService
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
        let actualId = id ?? getCurrentUserId()
        return profiles[actualId]
    }
    
    func getPosts(forId id: String?) -> [ProfilePost] {
        let actualId = id ?? getCurrentUserId()
        return posts[actualId] ?? []
    }
    
    // MARK: - Async Methods
    
    func fetchProfile(forId id: String?) async throws -> UserProfile? {
        try await Task.sleep(nanoseconds: 100_000_000)
        let actualId = id ?? getCurrentUserId()
        return profiles[actualId]
    }
    
    func refreshProfile(forId id: String?) async throws -> UserProfile? {
        try await Task.sleep(nanoseconds: 50_000_000)
        loadPersistedProfiles()
        let actualId = id ?? getCurrentUserId()
        return profiles[actualId]
    }
    
    func updateProfile(
        id: String,
        displayName: String,
        username: String,
        bio: String,
        location: String? = nil,
        birthday: Date? = nil,
        privacySetting: PrivacySetting = .publicVisibility,
        avatarColorHex: String,
        avatarImageData: Data? = nil,
        clearAvatar: Bool = false
    ) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let actualId = id.isEmpty ? getCurrentUserId() : id
        guard var profile = profiles[actualId] else {
            throw NSError(domain: "ProfileService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found."])
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
            try? await profileImageService.deleteAvatar(userId: actualId)
        } else if let newAvatarData = avatarImageData {
            let compressedData = try await profileImageService.saveAvatar(data: newAvatarData, userId: actualId)
            profile.avatarImageData = compressedData
        }
        
        profiles[actualId] = profile
        persistProfiles()

        profileSubject.send(profile)
        
        return profile
    }
    
    func uploadAvatar(image: UIImage, userId: String) async throws -> Data {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ProfileImageError.compressionFailed
        }
        let savedData = try await profileImageService.saveAvatar(data: data, userId: userId)
        
        if var profile = profiles[userId] {
            profile.avatarImageData = savedData
            profiles[userId] = profile
            persistProfiles()
            profileSubject.send(profile)
        }
        
        return savedData
    }
    
    func deleteAvatar(userId: String) async throws {
        try await profileImageService.deleteAvatar(userId: userId)
        if var profile = profiles[userId] {
            profile.avatarImageData = nil
            profile.avatarImageName = nil
            profiles[userId] = profile
            persistProfiles()
            profileSubject.send(profile)
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
    
    // MARK: - Follow Logic
    
    func toggleFollow(targetId: String) -> UserProfile? {
        guard var targetProfile = profiles[targetId] else { return nil }
        let currentId = getCurrentUserId()
        guard var currentProfile = profiles[currentId] else { return nil }
        
        if targetProfile.isFollowing {
            targetProfile.isFollowing = false
            targetProfile.followersCount = max(0, targetProfile.followersCount - 1)
            currentProfile.followingCount = max(0, currentProfile.followingCount - 1)
        } else {
            targetProfile.isFollowing = true
            targetProfile.followersCount += 1
            currentProfile.followingCount += 1
        }
        
        profiles[targetId] = targetProfile
        profiles[currentId] = currentProfile
        persistProfiles()
        
        profileSubject.send(targetProfile)
        profileSubject.send(currentProfile)
        
        return targetProfile
    }
    
    func getFollowers(forId id: String?) -> [UserProfile] {
        let actualId = id ?? getCurrentUserId()
        return profiles.values
            .filter { $0.id != actualId }
            .shuffled()
            .prefix(3)
            .map { $0 }
    }
    
    func getFollowing(forId id: String?) -> [UserProfile] {
        let actualId = id ?? getCurrentUserId()
        if actualId == getCurrentUserId() {
            return profiles.values.filter { $0.id != actualId && $0.isFollowing }
        } else {
            return profiles.values
                .filter { $0.id != actualId }
                .shuffled()
                .prefix(2)
                .map { $0 }
        }
    }
    
    // MARK: - Firebase Syncing
    
    func syncWithFirebaseUser(user: User) {
        let currentId = user.uid
        migrateMockProfileToAuthenticatedUser(currentId: currentId)

        let isNewProfile = profiles[currentId] == nil
        
        var profile = profiles[currentId] ?? UserProfile(
            id: currentId,
            displayName: user.displayName ?? "John Doe",
            username: "johndoe",
            avatarColorHex: "38B2AC",
            bio: "Mindfulness traveler. Tracking my moods and finding inner peace.",
            currentMoodEmoji: "😊",
            currentMoodText: "Happy",
            currentMoodColorHex: "38B2AC",
            moodStreak: 5,
            postsCount: 3,
            followersCount: 120,
            followingCount: 85,
            isFollowing: false,
            achievements: [],
            moodHistory: []
        )
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
            profile.achievements = defaultAchievements()
        }
        if profile.moodHistory.isEmpty {
            profile.moodHistory = defaultMoodHistory()
        }
        
        profiles[currentId] = profile
        if posts[currentId] == nil {
            posts[currentId] = defaultUserPosts()
        }
        
        persistProfiles()
        profileSubject.send(profile)
    }
    
    // MARK: - Persistence Helpers
    
    private func persistProfiles() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profiles)
            try data.write(to: storageFileURL, options: .atomic)
        } catch {
            print("ProfileService: Failed to persist profiles - \(error)")
        }
    }
    
    private func loadPersistedProfiles() {
        guard fileManager.fileExists(atPath: storageFileURL.path),
              let data = try? Data(contentsOf: storageFileURL),
              let decoded = try? JSONDecoder().decode([String: UserProfile].self, from: data) else {
            return
        }
        
        for (id, profile) in decoded {
            profiles[id] = profile
        }
    }
    
    // MARK: - Private Helpers
    
    private static let mockUserId = "current_user_mock"
    
    func getCurrentUserId() -> String {
        return Auth.auth().currentUser?.uid ?? Self.mockUserId
    }
    
    private func migrateMockProfileToAuthenticatedUser(currentId: String) {
        guard currentId != Self.mockUserId,
              profiles[currentId] == nil,
              let mockProfile = profiles[Self.mockUserId] else {
            return
        }
        
        var migratedProfile = mockProfile
        migratedProfile.id = currentId
        profiles[currentId] = migratedProfile
        
        if posts[currentId] == nil, let mockPosts = posts[Self.mockUserId] {
            posts[currentId] = mockPosts
        }
    }
    
    private func setupMockData() {
        let currentId = getCurrentUserId()

        if profiles[currentId] == nil {
            var currentUserProfile = UserProfile(
                id: currentId,
                displayName: "John",
                username: "johndoe",
                avatarColorHex: "38B2AC",
                bio: "Mindfulness traveler. Tracking my moods and finding inner peace. 🌱🧘‍♂️",
                location: "San Francisco, CA",
                birthday: nil,
                privacySetting: .publicVisibility,
                currentMoodEmoji: "😊",
                currentMoodText: "Happy",
                currentMoodColorHex: "38B2AC",
                moodStreak: 5,
                postsCount: 3,
                followersCount: 120,
                followingCount: 5,
                isFollowing: false,
                achievements: defaultAchievements(),
                moodHistory: defaultMoodHistory()
            )
            
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
        
        if posts[currentId] == nil {
            posts[currentId] = defaultUserPosts()
        }

        if profiles["1"] == nil {
            profiles["1"] = UserProfile(
                id: "1",
                displayName: "Pepper",
                username: "pepperoni",
                avatarColorHex: "FF6B6B",
                bio: "Endorphin addict. Morning run enthusiast. Motion creates emotion! 🏃‍♂️☀️",
                location: "Seattle, WA",
                privacySetting: .publicVisibility,
                currentMoodEmoji: "😊",
                currentMoodText: "Happy",
                currentMoodColorHex: "38B2AC",
                moodStreak: 12,
                postsCount: 2,
                followersCount: 234,
                followingCount: 189,
                isFollowing: false,
                achievements: [
                    Achievement(title: "Runner's High", description: "Completed 10 active check-ins", icon: "figure.run", unlockedAt: Date().addingTimeInterval(-86400 * 10)),
                    Achievement(title: "Streak Starter", description: "Logged mood for 5 days in a row", icon: "flame.fill", unlockedAt: Date().addingTimeInterval(-86400 * 5))
                ],
                moodHistory: defaultMoodHistory(shiftDays: 1, colorHex: "38B2AC", emoji: "😊", text: "Happy")
            )
        }
        
        if profiles["2"] == nil {
            profiles["2"] = UserProfile(
                id: "2",
                displayName: "Michele",
                username: "mj",
                avatarColorHex: "4DABF7",
                bio: "Breathe in experience, breathe out poetry. Yoga teacher & mindfulness explorer. 🌱✨",
                location: "Portland, OR",
                privacySetting: .publicVisibility,
                currentMoodEmoji: "😌",
                currentMoodText: "Calm",
                currentMoodColorHex: "4A5568",
                moodStreak: 8,
                postsCount: 2,
                followersCount: 512,
                followingCount: 342,
                isFollowing: true,
                achievements: [
                    Achievement(title: "Zen Master", description: "Completed 20 mindfulness check-ins", icon: "leaf.fill", unlockedAt: Date().addingTimeInterval(-86400 * 20)),
                    Achievement(title: "Early Bird", description: "Logged mood before 7:00 AM", icon: "sun.max.fill", unlockedAt: Date().addingTimeInterval(-86400 * 3))
                ],
                moodHistory: defaultMoodHistory(shiftDays: 0, colorHex: "4A5568", emoji: "😌", text: "Calm")
            )
        }
        
        if profiles["3"] == nil {
            profiles["3"] = UserProfile(
                id: "3",
                displayName: "Ned",
                username: "ceo",
                avatarColorHex: "BE4BDF",
                bio: "Quiet seeker. Rain lover. Early to sleep, early to rise. 😴💤",
                location: "Vancouver, BC",
                privacySetting: .friendsOnly,
                currentMoodEmoji: "😴",
                currentMoodText: "Sleepy",
                currentMoodColorHex: "667EEA",
                moodStreak: 4,
                postsCount: 2,
                followersCount: 98,
                followingCount: 120,
                isFollowing: false,
                achievements: [
                    Achievement(title: "Rest Specialist", description: "Logged sleep state for 7 days in a row", icon: "moon.stars.fill", unlockedAt: Date().addingTimeInterval(-86400 * 7))
                ],
                moodHistory: defaultMoodHistory(shiftDays: 2, colorHex: "667EEA", emoji: "😴", text: "Sleepy")
            )
        }
        
        if profiles["4"] == nil {
            profiles["4"] = UserProfile(
                id: "4",
                displayName: "Happy",
                username: "happyaunt",
                avatarColorHex: "FAB005",
                bio: "Product Designer, tech builder. Celebrating tiny wins every single day! 🚀🎉",
                location: "Austin, TX",
                privacySetting: .publicVisibility,
                currentMoodEmoji: "🤩",
                currentMoodText: "Excited",
                currentMoodColorHex: "ED64A6",
                moodStreak: 19,
                postsCount: 2,
                followersCount: 843,
                followingCount: 610,
                isFollowing: true,
                achievements: [
                    Achievement(title: "Productivity Prodigy", description: "Checked in on 30 active days", icon: "sparkles", unlockedAt: Date().addingTimeInterval(-86400 * 15)),
                    Achievement(title: "Super Star", description: "Gathered 500 followers", icon: "star.fill", unlockedAt: Date().addingTimeInterval(-86400 * 2))
                ],
                moodHistory: defaultMoodHistory(shiftDays: 0, colorHex: "ED64A6", emoji: "🤩", text: "Excited")
            )
        }
        
        if profiles["5"] == nil {
            profiles["5"] = UserProfile(
                id: "5",
                displayName: "Alex",
                username: "alexwang",
                avatarColorHex: "12B886",
                bio: "Sipping matcha, practicing presence. Be here now. 🧘‍♂️🍵",
                location: "Kyoto, Japan",
                privacySetting: .publicVisibility,
                currentMoodEmoji: "🧠",
                currentMoodText: "Mindful",
                currentMoodColorHex: "805AD5",
                moodStreak: 15,
                postsCount: 2,
                followersCount: 156,
                followingCount: 112,
                isFollowing: true,
                achievements: [
                    Achievement(title: "Tea Master", description: "Logged 10 mindful check-ins", icon: "cup.and.saucer.fill", unlockedAt: Date().addingTimeInterval(-86400 * 12)),
                    Achievement(title: "Constant Mind", description: "Logged mood 15 days in a row", icon: "brain.head.profile", unlockedAt: Date().addingTimeInterval(-86400 * 15))
                ],
                moodHistory: defaultMoodHistory(shiftDays: 0, colorHex: "805AD5", emoji: "🧠", text: "Mindful")
            )
        }
        
        let followingCount = profiles.values.filter { $0.id != currentId && $0.isFollowing }.count
        profiles[currentId]?.followingCount = followingCount
    }
    
    private func defaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Check-In", description: "Took the first step on the mindfulness path", icon: "sparkles", unlockedAt: Date().addingTimeInterval(-86400 * 5)),
            Achievement(title: "Streak Starter", description: "Logged mood for 5 days in a row", icon: "flame.fill", unlockedAt: Date()),
            Achievement(title: "Mindful Explorer", description: "Completed first mindfulness week", icon: "leaf.fill", unlockedAt: Date().addingTimeInterval(-86400 * 2))
        ]
    }
    
    private func defaultMoodHistory(
        shiftDays: Int = 0,
        colorHex: String = "38B2AC",
        emoji: String = "😊",
        text: String = "Happy"
    ) -> [MoodHistoryEntry] {
        var entries: [MoodHistoryEntry] = []
        let calendars = Calendar.current
        
        let mockOptions = [
            (emoji: "😊", text: "Happy", colorHex: "38B2AC"),
            (emoji: "😌", text: "Calm", colorHex: "4A5568"),
            (emoji: "😴", text: "Sleepy", colorHex: "667EEA"),
            (emoji: "🤩", text: "Excited", colorHex: "ED64A6"),
            (emoji: "🧠", text: "Mindful", colorHex: "805AD5"),
            (emoji: "😔", text: "Sad", colorHex: "A0AEC0")
        ]
        
        for i in 0..<7 {
            let targetDate = calendars.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let optionIndex = (i + shiftDays) % mockOptions.count
            let option = mockOptions[optionIndex]
            
            if i == 0 {
                entries.append(MoodHistoryEntry(
                    id: UUID().uuidString,
                    date: targetDate,
                    emoji: emoji,
                    colorHex: colorHex,
                    text: text
                ))
            } else {
                entries.append(MoodHistoryEntry(
                    id: UUID().uuidString,
                    date: targetDate,
                    emoji: option.emoji,
                    colorHex: option.colorHex,
                    text: option.text
                ))
            }
        }
        return entries
    }
    
    private func defaultUserPosts() -> [ProfilePost] {
        return [
            ProfilePost(
                id: "up1",
                quoteText: "The present moment is filled with joy and happiness.",
                caption: "Enjoyed a peaceful coffee walk this morning. Grateful for the fresh air. ☕️🍃",
                postGradientStartHex: "38B2AC",
                postGradientEndHex: "805AD5",
                likesCount: 14,
                commentsCount: 2,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            ProfilePost(
                id: "up2",
                quoteText: "Quiet mind, peaceful heart.",
                caption: "Spend 10 minutes writing down my worries. Writing them helps letting them go. 📝🧘‍♂️",
                postGradientStartHex: "4DABF7",
                postGradientEndHex: "BE4BDF",
                likesCount: 9,
                commentsCount: 0,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-86400 * 2)
            ),
            ProfilePost(
                id: "up3",
                quoteText: "Grateful for small things, big things, and everything in between.",
                caption: "Revisited my goals today. Taking it day by day. Every small step counts. 💪✨",
                postGradientStartHex: "ED64A6",
                postGradientEndHex: "FEFCBF",
                likesCount: 28,
                commentsCount: 5,
                isLiked: true,
                isBookmarked: true,
                createdAt: Date().addingTimeInterval(-86400 * 4)
            )
        ]
    }
}
