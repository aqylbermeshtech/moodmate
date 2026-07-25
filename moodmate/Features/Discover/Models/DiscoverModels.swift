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
    let displayName: String
    let username: String
    let avatarColorHex: String
    let bio: String
    let moodEmoji: String?
    let moodText: String?
    let moodColorHex: String?
    var isFollowing: Bool
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
    
    // User fields
    var userName: String?
    var username: String?
    var avatarColorHex: String?
    var userMoodEmoji: String?
    var userBio: String?
    
    // Post fields
    var postQuote: String?
    var postCaption: String?
    var postGradientStartHex: String?
    var postGradientEndHex: String?
    var postLikesCount: Int?
    var postUserId: String?
    
    // Mood fields
    var moodEmoji: String?
    var moodName: String?
    var moodColorHex: String?
    var moodPostCount: Int?
    
    // Hashtag fields
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
