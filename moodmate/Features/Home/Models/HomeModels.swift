//
//  HomeModels.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct MoodUser: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var username: String
    var avatarImageName: String? // Optional custom image/system name
    var avatarImageData: Data?   // Binary JPEG avatar data
    var avatarColorHex: String   // Hex color for generating initials background
    var currentMoodEmoji: String?
    var currentMoodText: String?
    var currentMoodColorHex: String?
    
    init(
        id: String,
        name: String,
        username: String,
        avatarImageName: String? = nil,
        avatarImageData: Data? = nil,
        avatarColorHex: String = "38B2AC",
        currentMoodEmoji: String? = nil,
        currentMoodText: String? = nil,
        currentMoodColorHex: String? = nil
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarImageName = avatarImageName
        self.avatarImageData = avatarImageData
        self.avatarColorHex = avatarColorHex
        self.currentMoodEmoji = currentMoodEmoji
        self.currentMoodText = currentMoodText
        self.currentMoodColorHex = currentMoodColorHex
    }
}

struct FeedPost: Identifiable, Equatable {
    let id: String
    let user: MoodUser
    let timeAgo: String
    let postGradientStartHex: String
    let postGradientEndHex: String
    let quoteText: String       // Optional quote title
    let caption: String         // Body text
    var images: [String]        // Attached image base64 strings or URLs
    var moodEmoji: String?      // Mood emoji associated with post
    var moodText: String?       // Mood description
    var moodColorHex: String?   // Mood accent color
    var visibility: PostVisibility // Public, Friends, Private
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    var isBookmarked: Bool
    
    init(
        id: String,
        user: MoodUser,
        timeAgo: String,
        postGradientStartHex: String = "38B2AC",
        postGradientEndHex: String = "805AD5",
        quoteText: String = "",
        caption: String = "",
        images: [String] = [],
        moodEmoji: String? = nil,
        moodText: String? = nil,
        moodColorHex: String? = nil,
        visibility: PostVisibility = .publicVisibility,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isLiked: Bool = false,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.user = user
        self.timeAgo = timeAgo
        self.postGradientStartHex = postGradientStartHex
        self.postGradientEndHex = postGradientEndHex
        self.quoteText = quoteText
        self.caption = caption
        self.images = images
        self.moodEmoji = moodEmoji ?? user.currentMoodEmoji
        self.moodText = moodText ?? user.currentMoodText
        self.moodColorHex = moodColorHex ?? user.currentMoodColorHex
        self.visibility = visibility
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
    }
    
    // Convert from PostModel
    init(from postModel: PostModel) {
        self.id = postModel.id
        self.user = postModel.author
        self.timeAgo = postModel.formattedTimeAgo
        self.postGradientStartHex = postModel.gradientStartHex ?? postModel.moodColorHex ?? "38B2AC"
        self.postGradientEndHex = postModel.gradientEndHex ?? "805AD5"
        self.quoteText = postModel.quoteText ?? ""
        self.caption = postModel.text ?? ""
        self.images = postModel.images
        self.moodEmoji = postModel.moodEmoji
        self.moodText = postModel.mood
        self.moodColorHex = postModel.moodColorHex
        self.visibility = postModel.visibility
        self.likesCount = postModel.likesCount
        self.commentsCount = postModel.commentsCount
        self.isLiked = postModel.isLiked
        self.isBookmarked = postModel.isBookmarked
    }
}
