//
//  ProfileModels.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import Foundation

enum PrivacySetting: String, Codable, CaseIterable, Identifiable {
    case publicVisibility = "Public"
    case friendsOnly = "Friends"
    case privateVisibility = "Private"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .publicVisibility: return "globe"
        case .friendsOnly: return "person.2.fill"
        case .privateVisibility: return "lock.fill"
        }
    }
}

struct UserProfile: Identifiable, Equatable, Codable {
    var id: String
    var displayName: String
    var username: String
    var avatarColorHex: String
    var avatarImageData: Data?
    var avatarImageName: String?
    var bio: String
    var location: String?
    var birthday: Date?
    var privacySetting: PrivacySetting
    var currentMoodEmoji: String?
    var currentMoodText: String?
    var currentMoodColorHex: String?
    var moodStreak: Int
    var postsCount: Int
    var followersCount: Int
    var followingCount: Int
    var isFollowing: Bool
    var achievements: [Achievement]
    var moodHistory: [MoodHistoryEntry]
    
    init(
        id: String,
        displayName: String,
        username: String,
        avatarColorHex: String = "38B2AC",
        avatarImageData: Data? = nil,
        avatarImageName: String? = nil,
        bio: String = "",
        location: String? = nil,
        birthday: Date? = nil,
        privacySetting: PrivacySetting = .publicVisibility,
        currentMoodEmoji: String? = nil,
        currentMoodText: String? = nil,
        currentMoodColorHex: String? = nil,
        moodStreak: Int = 0,
        postsCount: Int = 0,
        followersCount: Int = 0,
        followingCount: Int = 0,
        isFollowing: Bool = false,
        achievements: [Achievement] = [],
        moodHistory: [MoodHistoryEntry] = []
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarColorHex = avatarColorHex
        self.avatarImageData = avatarImageData
        self.avatarImageName = avatarImageName
        self.bio = bio
        self.location = location
        self.birthday = birthday
        self.privacySetting = privacySetting
        self.currentMoodEmoji = currentMoodEmoji
        self.currentMoodText = currentMoodText
        self.currentMoodColorHex = currentMoodColorHex
        self.moodStreak = moodStreak
        self.postsCount = postsCount
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.isFollowing = isFollowing
        self.achievements = achievements
        self.moodHistory = moodHistory
    }
}

struct Achievement: Identifiable, Equatable, Codable {
    var id: String { title }
    let title: String
    let description: String
    let icon: String
    let unlockedAt: Date
}

struct MoodHistoryEntry: Identifiable, Equatable, Codable {
    let id: String
    let date: Date
    let emoji: String
    let colorHex: String
    let text: String
}

