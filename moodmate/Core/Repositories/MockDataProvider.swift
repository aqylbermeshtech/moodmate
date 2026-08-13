//
//  MockDataProvider.swift
//  moodmate
//
//  Pure seed-content generation for ProfileRepository's mock/local-storage
//  implementation. No Firebase awareness, no persistence, no side effects —
//  just data. This is the piece a real backend implementation would never
//  need at all, which is why it was kept separate from ProfileRepository
//  itself rather than folded back in.
//

import Foundation

enum MockDataProvider {

    /// The pre-auth placeholder profile seeded for `mockUserId` before any
    /// Firebase user has signed in.
    static func currentUserSeedProfile(id: String) -> UserProfile {
        UserProfile(
            id: id,
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
    }

    /// The seed profile for a newly-authenticated Firebase user who has no
    /// existing (migrated or persisted) profile yet.
    static func newAuthenticatedUserSeedProfile(id: String, displayName: String?) -> UserProfile {
        UserProfile(
            id: id,
            displayName: displayName ?? "John Doe",
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
    }

    /// The 5 seed "friend" profiles (ids "1"–"5") the mock social graph is
    /// built around.
    static func friendSeedProfiles() -> [UserProfile] {
        [
            UserProfile(
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
            ),
            UserProfile(
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
            ),
            UserProfile(
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
            ),
            UserProfile(
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
            ),
            UserProfile(
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
        ]
    }

    static func defaultAchievements() -> [Achievement] {
        [
            Achievement(title: "First Check-In", description: "Took the first step on the mindfulness path", icon: "sparkles", unlockedAt: Date().addingTimeInterval(-86400 * 5)),
            Achievement(title: "Streak Starter", description: "Logged mood for 5 days in a row", icon: "flame.fill", unlockedAt: Date()),
            Achievement(title: "Mindful Explorer", description: "Completed first mindfulness week", icon: "leaf.fill", unlockedAt: Date().addingTimeInterval(-86400 * 2))
        ]
    }

    static func defaultMoodHistory(
        shiftDays: Int = 0,
        colorHex: String = "38B2AC",
        emoji: String = "😊",
        text: String = "Happy"
    ) -> [MoodHistoryEntry] {
        var entries: [MoodHistoryEntry] = []
        let calendar = Calendar.current

        let mockOptions = [
            (emoji: "😊", text: "Happy", colorHex: "38B2AC"),
            (emoji: "😌", text: "Calm", colorHex: "4A5568"),
            (emoji: "😴", text: "Sleepy", colorHex: "667EEA"),
            (emoji: "🤩", text: "Excited", colorHex: "ED64A6"),
            (emoji: "🧠", text: "Mindful", colorHex: "805AD5"),
            (emoji: "😔", text: "Sad", colorHex: "A0AEC0")
        ]

        for i in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
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
}
