//
//  DiscoverModels.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

// MARK: - Height Class for Masonry Layout
enum CardHeightClass: Int, CaseIterable, Codable {
    case compact = 0
    case regular = 1
    case tall = 2
    
    var heightValue: CGFloat {
        switch self {
        case .compact: return 180
        case .regular: return 220
        case .tall: return 280
        }
    }
}

// MARK: - Discover Post (Masonry Grid Card)
struct DiscoverPost: Identifiable, Equatable, Codable {
    let id: String
    let userId: String
    let userName: String
    let username: String
    let avatarColorHex: String
    let moodEmoji: String
    let moodText: String
    let moodColorHex: String
    let quoteText: String
    let caption: String
    let gradientStartHex: String
    let gradientEndHex: String
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    let heightClass: CardHeightClass
    let createdAt: Date
}

// MARK: - Trending Mood
struct TrendingMood: Identifiable, Equatable, Codable {
    let id: String
    let emoji: String
    let name: String
    var postCount: Int
    let colorHex: String
}

// MARK: - Discover Hashtag
struct DiscoverHashtag: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    var postCount: Int
}

// MARK: - Discover Category
struct DiscoverCategory: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let iconName: String // SF Symbol
    let gradientStartHex: String
    let gradientEndHex: String
}

// MARK: - Suggested User
struct SuggestedUser: Identifiable, Equatable, Codable {
    let id: String
    var displayName: String
    var username: String
    var avatarColorHex: String
    var avatarImageData: Data?
    var bio: String
    var moodEmoji: String?
    var moodText: String?
    var moodColorHex: String?
    var isFollowing: Bool
    
    init(
        id: String,
        displayName: String,
        username: String,
        avatarColorHex: String = "38B2AC",
        avatarImageData: Data? = nil,
        bio: String = "",
        moodEmoji: String? = nil,
        moodText: String? = nil,
        moodColorHex: String? = nil,
        isFollowing: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarColorHex = avatarColorHex
        self.avatarImageData = avatarImageData
        self.bio = bio
        self.moodEmoji = moodEmoji
        self.moodText = moodText
        self.moodColorHex = moodColorHex
        self.isFollowing = isFollowing
    }
}

// MARK: - Search Result
enum SearchResultType: String, CaseIterable, Codable {
    case user
    case post
    case mood
    case hashtag
}

struct SearchResult: Identifiable, Equatable {
    let id: String
    let type: SearchResultType

    var userName: String?
    var username: String?
    var avatarColorHex: String?
    var avatarImageData: Data?
    var userMoodEmoji: String?
    var userBio: String?

    var postQuote: String?
    var postCaption: String?
    var postGradientStartHex: String?
    var postGradientEndHex: String?
    var postLikesCount: Int?
    var postUserId: String?

    var moodEmoji: String?
    var moodName: String?
    var moodColorHex: String?
    var moodPostCount: Int?

    var hashtagName: String?
    var hashtagPostCount: Int?
}

// MARK: - Search Scope
enum SearchScope: String, CaseIterable {
    case all = "All"
    case users = "Users"
    case posts = "Posts"
    case moods = "Moods"
    case hashtags = "Hashtags"
}
