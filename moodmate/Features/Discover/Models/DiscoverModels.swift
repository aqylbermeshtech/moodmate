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

    /// Projection from the canonical PostModel. heightClass isn't part of
    /// the domain model — it's masonry-grid layout metadata — so it's
    /// derived deterministically from the post id instead, keeping the
    /// grid stable within a session without storing it anywhere. Author
    /// display fields (name/username/avatar) aren't carried here at all —
    /// views resolve those from UserStore via userId at render time.
    init(from post: PostModel) {
        self.id = post.id
        self.userId = post.authorId
        self.moodEmoji = post.moodEmoji ?? "😊"
        self.moodText = post.mood ?? ""
        self.moodColorHex = post.moodColorHex ?? "38B2AC"
        self.quoteText = post.quoteText ?? ""
        self.caption = post.text ?? ""
        self.gradientStartHex = post.gradientStartHex ?? post.moodColorHex ?? "38B2AC"
        self.gradientEndHex = post.gradientEndHex ?? "805AD5"
        self.likesCount = post.likesCount
        self.commentsCount = post.commentsCount
        self.isLiked = post.isLiked
        let classes = CardHeightClass.allCases
        self.heightClass = classes[abs(post.id.hashValue) % classes.count]
        self.createdAt = post.createdAt
    }

    init(
        id: String, userId: String,
        moodEmoji: String, moodText: String, moodColorHex: String, quoteText: String, caption: String,
        gradientStartHex: String, gradientEndHex: String, likesCount: Int, commentsCount: Int,
        isLiked: Bool, heightClass: CardHeightClass, createdAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.moodEmoji = moodEmoji
        self.moodText = moodText
        self.moodColorHex = moodColorHex
        self.quoteText = quoteText
        self.caption = caption
        self.gradientStartHex = gradientStartHex
        self.gradientEndHex = gradientEndHex
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.heightClass = heightClass
        self.createdAt = createdAt
    }
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
    let iconName: String 
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

    var userId: String?
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
