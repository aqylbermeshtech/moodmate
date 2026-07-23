//
//  ProfileService.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import Foundation
import FirebaseAuth

final class ProfileService {
    static let shared = ProfileService()
    
    private var profiles: [String: UserProfile] = [:]
    private var posts: [String: [ProfilePost]] = [:]
    
    private init() {
        setupMockData()
    }
    
    func getProfile(forId id: String?) -> UserProfile? {
        let actualId = id ?? getCurrentUserId()
        return profiles[actualId]
    }
    
    func getPosts(forId id: String?) -> [ProfilePost] {
        let actualId = id ?? getCurrentUserId()
        return posts[actualId] ?? []
    }
    
    func updateProfile(
        id: String,
        displayName: String,
        username: String,
        bio: String,
        avatarColorHex: String
    ) -> UserProfile? {
        guard var profile = profiles[id] else { return nil }
        profile.displayName = displayName
        profile.username = username
        profile.bio = bio
        profile.avatarColorHex = avatarColorHex
        profiles[id] = profile
        return profile
    }
    
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
        return targetProfile
    }
    
    func getFollowers(forId id: String?) -> [UserProfile] {
        let actualId = id ?? getCurrentUserId()
        // Return a mock list of followers based on other profiles
        return profiles.values
            .filter { $0.id != actualId }
            .shuffled()
            .prefix(3)
            .map { $0 }
    }
    
    func getFollowing(forId id: String?) -> [UserProfile] {
        let actualId = id ?? getCurrentUserId()
        // If it's the current user, return users we follow (whose isFollowing is true or random subset)
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
    
    func syncWithFirebaseUser(user: User) {
        let currentId = user.uid
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
        
        if let displayName = user.displayName, !displayName.isEmpty {
            profile.displayName = displayName
        } else if let email = user.email {
            let prefix = email.components(separatedBy: "@").first ?? "john"
            profile.displayName = prefix.capitalized
            profile.username = prefix.lowercased()
        }
        
        // Re-generate achievements & history if they are empty
        if profile.achievements.isEmpty {
            profile.achievements = defaultAchievements()
        }
        if profile.moodHistory.isEmpty {
            profile.moodHistory = defaultMoodHistory()
        }
        
        profiles[currentId] = profile
        
        // Setup initial posts if empty
        if posts[currentId] == nil {
            posts[currentId] = defaultUserPosts()
        }
    }
    
    // MARK: - Private Helpers
    
    private func getCurrentUserId() -> String {
        return Auth.auth().currentUser?.uid ?? "current_user_mock"
    }
    
    private func setupMockData() {
        let currentId = getCurrentUserId()
        
        // 1. Current User
        var currentUserProfile = UserProfile(
            id: currentId,
            displayName: "John",
            username: "johndoe",
            avatarColorHex: "38B2AC", // Teal
            bio: "Mindfulness traveler. Tracking my moods and finding inner peace. 🌱🧘‍♂️",
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
        posts[currentId] = defaultUserPosts()
        
        // 2. Friends Profiles (corresponds to HomeViewModel users)
        // Alex
        profiles["1"] = UserProfile(
            id: "1",
            displayName: "Alex",
            username: "alex_active",
            avatarColorHex: "FF6B6B",
            bio: "Endorphin addict. Morning run enthusiast. Motion creates emotion! 🏃‍♂️☀️",
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
        posts["1"] = [
            ProfilePost(
                id: "p3",
                quoteText: "Motion creates emotion.",
                caption: "Morning run cleared my head. Endorphins are flowing! Highly recommend starting your day active! 🏃‍♂️☀️",
                postGradientStartHex: "ED64A6",
                postGradientEndHex: "ECC94B",
                likesCount: 42,
                commentsCount: 8,
                isLiked: false,
                isBookmarked: true,
                createdAt: Date().addingTimeInterval(-18000)
            ),
            ProfilePost(
                id: "p7",
                quoteText: "Joy is what happens when we allow ourselves to recognize how good things are.",
                caption: "Epic sunset view from the peak. Captured the perfect warm pink hues. 🌄🏔️",
                postGradientStartHex: "F56565",
                postGradientEndHex: "ED64A6",
                likesCount: 65,
                commentsCount: 11,
                isLiked: true,
                isBookmarked: true,
                createdAt: Date().addingTimeInterval(-86400)
            )
        ]
        
        // Emma
        profiles["2"] = UserProfile(
            id: "2",
            displayName: "Emma",
            username: "emma_zen",
            avatarColorHex: "4DABF7",
            bio: "Breathe in experience, breathe out poetry. Yoga teacher & mindfulness explorer. 🌱✨",
            currentMoodEmoji: "😌",
            currentMoodText: "Calm",
            currentMoodColorHex: "4A5568",
            moodStreak: 8,
            postsCount: 2,
            followersCount: 512,
            followingCount: 342,
            isFollowing: true, // Followed by current user initially
            achievements: [
                Achievement(title: "Zen Master", description: "Completed 20 mindfulness check-ins", icon: "leaf.fill", unlockedAt: Date().addingTimeInterval(-86400 * 20)),
                Achievement(title: "Early Bird", description: "Logged mood before 7:00 AM", icon: "sun.max.fill", unlockedAt: Date().addingTimeInterval(-86400 * 3))
            ],
            moodHistory: defaultMoodHistory(shiftDays: 0, colorHex: "4A5568", emoji: "😌", text: "Calm")
        )
        posts["2"] = [
            ProfilePost(
                id: "p1",
                quoteText: "Breathe in experience, breathe out poetry.",
                caption: "Taking a conscious pause today. A reminder that it is okay to just be, rather than always do. 🌱✨",
                postGradientStartHex: "38B2AC",
                postGradientEndHex: "805AD5",
                likesCount: 24,
                commentsCount: 3,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            ProfilePost(
                id: "p6",
                quoteText: "Peace is not the absence of trouble, but the presence of grace.",
                caption: "Grateful for a quiet Sunday evening. Reflected on what brought joy this week. What are you grateful for? ❤️",
                postGradientStartHex: "805AD5",
                postGradientEndHex: "B7791F",
                likesCount: 48,
                commentsCount: 9,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-86400)
            )
        ]
        
        // Daniel
        profiles["3"] = UserProfile(
            id: "3",
            displayName: "Daniel",
            username: "daniel_sleeps",
            avatarColorHex: "BE4BDF",
            bio: "Quiet seeker. Rain lover. Early to sleep, early to rise. 😴💤",
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
        posts["3"] = [
            ProfilePost(
                id: "p2",
                quoteText: "Rest is a fine medicine.",
                caption: "Listening to my body and getting to sleep early tonight. Recharge session starts now. 💤😴",
                postGradientStartHex: "1A365D",
                postGradientEndHex: "667EEA",
                likesCount: 15,
                commentsCount: 1,
                isLiked: true,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-10800)
            ),
            ProfilePost(
                id: "p9",
                quoteText: "Sleep is the best meditation.",
                caption: "Rain tapping on the window pane. Safe to say I'm sleeping in late tomorrow. Rainy night relaxation. 🌧️🕯️",
                postGradientStartHex: "000000",
                postGradientEndHex: "2D3748",
                likesCount: 29,
                commentsCount: 5,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-86400 * 2)
            )
        ]
        
        // Chloe
        profiles["4"] = UserProfile(
            id: "4",
            displayName: "Chloe",
            username: "chloe_shine",
            avatarColorHex: "FAB005",
            bio: "Product Designer, tech builder. Celebrating tiny wins every single day! 🚀🎉",
            currentMoodEmoji: "🤩",
            currentMoodText: "Excited",
            currentMoodColorHex: "ED64A6",
            moodStreak: 19,
            postsCount: 2,
            followersCount: 843,
            followingCount: 610,
            isFollowing: true, // Followed by current user initially
            achievements: [
                Achievement(title: "Productivity Prodigy", description: "Checked in on 30 active days", icon: "sparkles", unlockedAt: Date().addingTimeInterval(-86400 * 15)),
                Achievement(title: "Super Star", description: "Gathered 500 followers", icon: "star.fill", unlockedAt: Date().addingTimeInterval(-86400 * 2))
            ],
            moodHistory: defaultMoodHistory(shiftDays: 0, colorHex: "ED64A6", emoji: "🤩", text: "Excited")
        )
        posts["4"] = [
            ProfilePost(
                id: "p4",
                quoteText: "Celebrate the tiny wins.",
                caption: "We launched our beta today! Feeling incredibly excited and grateful for the team's effort! 🚀🎉🙌",
                postGradientStartHex: "ED64A6",
                postGradientEndHex: "FEFCBF",
                likesCount: 56,
                commentsCount: 12,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-21600)
            ),
            ProfilePost(
                id: "p10",
                quoteText: "Energy is contagious.",
                caption: "Spent the weekend catching up with old high school friends! My battery is 100% full. 😄💃✨",
                postGradientStartHex: "F6AD55",
                postGradientEndHex: "D69E2E",
                likesCount: 51,
                commentsCount: 7,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-86400 * 3)
            )
        ]
        
        // Marcus
        profiles["5"] = UserProfile(
            id: "5",
            displayName: "Marcus",
            username: "marcus_mind",
            avatarColorHex: "12B886",
            bio: "Sipping matcha, practicing presence. Be here now. 🧘‍♂️🍵",
            currentMoodEmoji: "🧠",
            currentMoodText: "Mindful",
            currentMoodColorHex: "805AD5",
            moodStreak: 15,
            postsCount: 2,
            followersCount: 156,
            followingCount: 112,
            isFollowing: true, // Followed by current user initially
            achievements: [
                Achievement(title: "Tea Master", description: "Logged 10 mindful check-ins", icon: "cup.and.saucer.fill", unlockedAt: Date().addingTimeInterval(-86400 * 12)),
                Achievement(title: "Constant Mind", description: "Logged mood 15 days in a row", icon: "brain.head.profile", unlockedAt: Date().addingTimeInterval(-86400 * 15))
            ],
            moodHistory: defaultMoodHistory(shiftDays: 0, colorHex: "805AD5", emoji: "🧠", text: "Mindful")
        )
        posts["5"] = [
            ProfilePost(
                id: "p5",
                quoteText: "Be here now.",
                caption: "Enjoyed a quiet matcha latte. Mindful sipping: focusing on the warmth, the taste, and the silence. 🍵🧘‍♂️",
                postGradientStartHex: "12B886",
                postGradientEndHex: "38B2AC",
                likesCount: 31,
                commentsCount: 4,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-28800)
            ),
            ProfilePost(
                id: "p8",
                quoteText: "Quiet the mind and the soul will speak.",
                caption: "Ten minutes of focused breathing before checking emails. It completely shifts my response patterns. Try it!",
                postGradientStartHex: "4A5568",
                postGradientEndHex: "718096",
                likesCount: 19,
                commentsCount: 2,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date().addingTimeInterval(-86400 * 2)
            )
        ]
        
        // Setup current user's default followings (sync count with Emma, Chloe, Marcus)
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
        
        // Emojis mapping for realistic calendar variety
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
            
            // For today (i == 0), match the input parameters
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
