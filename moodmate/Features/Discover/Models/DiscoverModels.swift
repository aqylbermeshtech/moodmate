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
    let quoteText: String
    let caption: String
    let gradientStartHex: String
    let gradientEndHex: String
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    let heightClass: CardHeightClass
    let createdAt: Date

    /// `heightClass` is masonry layout metadata, derived deterministically
    /// from the post id so the grid stays stable without storing it. Author
    /// display fields aren't carried — views resolve those from UserStore.
    init(from post: PostModel) {
        self.id = post.id
        self.userId = post.authorId
        self.quoteText = post.quoteText ?? ""
        self.caption = post.text ?? ""
        self.gradientStartHex = post.gradientStartHex ?? "38B2AC"
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
        quoteText: String, caption: String,
        gradientStartHex: String, gradientEndHex: String, likesCount: Int, commentsCount: Int,
        isLiked: Bool, heightClass: CardHeightClass, createdAt: Date
    ) {
        self.id = id
        self.userId = userId
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
    var isFollowing: Bool

    init(
        id: String,
        displayName: String,
        username: String,
        avatarColorHex: String = "38B2AC",
        avatarImageData: Data? = nil,
        bio: String = "",
        isFollowing: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarColorHex = avatarColorHex
        self.avatarImageData = avatarImageData
        self.bio = bio
        self.isFollowing = isFollowing
    }
}

// MARK: - Search Result
enum SearchResultType: String, CaseIterable, Codable {
    case user
    case post
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
    var userBio: String?

    var postQuote: String?
    var postCaption: String?
    var postGradientStartHex: String?
    var postGradientEndHex: String?
    var postLikesCount: Int?
    var postUserId: String?

    var hashtagName: String?
    var hashtagPostCount: Int?
}

// MARK: - Search Scope
enum SearchScope: String, CaseIterable {
    case all = "All"
    case users = "Users"
    case posts = "Posts"
    case hashtags = "Hashtags"
}
