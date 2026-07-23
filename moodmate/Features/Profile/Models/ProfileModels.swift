//
//  ProfileModels.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import Foundation

struct UserProfile: Identifiable, Equatable, Codable {
    let id: String
    var displayName: String
    var username: String
    var avatarColorHex: String
    var bio: String
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
}

struct Achievement: Identifiable, Equatable, Codable {
    var id: String { title }
    let title: String
    let description: String
    let icon: String // Emoji or SF Symbol name
    let unlockedAt: Date
}

struct MoodHistoryEntry: Identifiable, Equatable, Codable {
    let id: String
    let date: Date
    let emoji: String
    let colorHex: String
    let text: String
}

struct ProfilePost: Identifiable, Equatable, Codable {
    let id: String
    let quoteText: String
    let caption: String
    let postGradientStartHex: String
    let postGradientEndHex: String
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    var isBookmarked: Bool
    let createdAt: Date
}
