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
            bio: "Just here for the quiet corners of the internet.",
            location: "San Francisco, CA",
            birthday: nil,
            privacySetting: .publicVisibility,
            postsCount: 3,
            followersCount: 120,
            followingCount: 5,
            isFollowing: false
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
            bio: "Just here for the quiet corners of the internet.",
            postsCount: 3,
            followersCount: 120,
            followingCount: 85,
            isFollowing: false
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
                bio: "Endorphin addict. Morning run enthusiast. Motion creates emotion.",
                location: "Seattle, WA",
                privacySetting: .publicVisibility,
                postsCount: 2,
                followersCount: 234,
                followingCount: 189,
                isFollowing: false
            ),
            UserProfile(
                id: "2",
                displayName: "Michele",
                username: "mj",
                avatarColorHex: "4DABF7",
                bio: "Breathe in experience, breathe out poetry. Yoga teacher and writer.",
                location: "Portland, OR",
                privacySetting: .publicVisibility,
                postsCount: 2,
                followersCount: 512,
                followingCount: 342,
                isFollowing: true
            ),
            UserProfile(
                id: "3",
                displayName: "Ned",
                username: "ceo",
                avatarColorHex: "BE4BDF",
                bio: "Quiet seeker. Rain lover. Early to sleep, early to rise.",
                location: "Vancouver, BC",
                privacySetting: .friendsOnly,
                postsCount: 2,
                followersCount: 98,
                followingCount: 120,
                isFollowing: false
            ),
            UserProfile(
                id: "4",
                displayName: "Happy",
                username: "happyaunt",
                avatarColorHex: "FAB005",
                bio: "Product designer and tinkerer. Celebrating the tiny wins.",
                location: "Austin, TX",
                privacySetting: .publicVisibility,
                postsCount: 2,
                followersCount: 843,
                followingCount: 610,
                isFollowing: true
            ),
            UserProfile(
                id: "5",
                displayName: "Alex",
                username: "alexwang",
                avatarColorHex: "12B886",
                bio: "Sipping matcha, practicing presence. Be here now.",
                location: "Kyoto, Japan",
                privacySetting: .publicVisibility,
                postsCount: 2,
                followersCount: 156,
                followingCount: 112,
                isFollowing: true
            )
        ]
    }
}
