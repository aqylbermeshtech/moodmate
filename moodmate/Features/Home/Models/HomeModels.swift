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
    var avatarImageName: String?
    var avatarImageData: Data?
    var avatarColorHex: String
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
    let quoteText: String
    let caption: String
    var images: [String]
    var moodEmoji: String?
    var moodText: String?
    var moodColorHex: String?
    var visibility: PostVisibility
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
 
    func updatingAuthor(from profile: UserProfile) -> FeedPost {
        var updatedUser = self.user
        updatedUser.name           = profile.displayName
        updatedUser.username       = profile.username
        updatedUser.avatarColorHex = profile.avatarColorHex
        updatedUser.avatarImageData = profile.avatarImageData
        return FeedPost(
            id:                    id,
            user:                  updatedUser,
            timeAgo:               timeAgo,
            postGradientStartHex:  postGradientStartHex,
            postGradientEndHex:    postGradientEndHex,
            quoteText:             quoteText,
            caption:               caption,
            images:                images,
            moodEmoji:             moodEmoji,
            moodText:              moodText,
            moodColorHex:          moodColorHex,
            visibility:            visibility,
            likesCount:            likesCount,
            commentsCount:         commentsCount,
            isLiked:               isLiked,
            isBookmarked:          isBookmarked
        )
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

    // Convert from ProfilePost + UserProfile (used when navigating from Profile grid)
    init(from profilePost: ProfilePost, user: UserProfile) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        self.id = profilePost.id
        self.user = MoodUser(
            id: user.id,
            name: user.displayName,
            username: user.username,
            avatarImageData: user.avatarImageData,
            avatarColorHex: user.avatarColorHex,
            currentMoodEmoji: user.currentMoodEmoji,
            currentMoodText: user.currentMoodText,
            currentMoodColorHex: user.currentMoodColorHex
        )
        self.timeAgo = formatter.string(from: profilePost.createdAt)
        self.postGradientStartHex = profilePost.postGradientStartHex
        self.postGradientEndHex = profilePost.postGradientEndHex
        self.quoteText = profilePost.quoteText
        self.caption = profilePost.caption
        self.images = []
        self.moodEmoji = user.currentMoodEmoji
        self.moodText = user.currentMoodText
        self.moodColorHex = user.currentMoodColorHex
        self.visibility = .publicVisibility
        self.likesCount = profilePost.likesCount
        self.commentsCount = profilePost.commentsCount
        self.isLiked = profilePost.isLiked
        self.isBookmarked = profilePost.isBookmarked
    }
}
