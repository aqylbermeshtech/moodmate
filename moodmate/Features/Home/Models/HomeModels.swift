//
//  HomeModels.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var username: String
    var avatarImageName: String?
    var avatarImageData: Data?
    var avatarColorHex: String

    init(
        id: String,
        name: String,
        username: String,
        avatarImageName: String? = nil,
        avatarImageData: Data? = nil,
        avatarColorHex: String = "38B2AC"
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarImageName = avatarImageName
        self.avatarImageData = avatarImageData
        self.avatarColorHex = avatarColorHex
    }
}

struct FeedPost: Identifiable, Equatable {
    let id: String
    let authorId: String
    let timeAgo: String
    let postGradientStartHex: String
    let postGradientEndHex: String
    let quoteText: String
    let caption: String
    var images: [String]
    var visibility: Visibility
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    var isBookmarked: Bool

    init(
        id: String,
        authorId: String,
        timeAgo: String,
        postGradientStartHex: String = "38B2AC",
        postGradientEndHex: String = "805AD5",
        quoteText: String = "",
        caption: String = "",
        images: [String] = [],
        visibility: Visibility = .publicVisibility,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isLiked: Bool = false,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.authorId = authorId
        self.timeAgo = timeAgo
        self.postGradientStartHex = postGradientStartHex
        self.postGradientEndHex = postGradientEndHex
        self.quoteText = quoteText
        self.caption = caption
        self.images = images
        self.visibility = visibility
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
    }

    init(from postModel: PostModel) {
        self.id = postModel.id
        self.authorId = postModel.authorId
        self.timeAgo = postModel.formattedTimeAgo
        self.postGradientStartHex = postModel.gradientStartHex ?? "38B2AC"
        self.postGradientEndHex = postModel.gradientEndHex ?? "805AD5"
        self.quoteText = postModel.quoteText ?? ""
        self.caption = postModel.text ?? ""
        self.images = postModel.images
        self.visibility = postModel.visibility
        self.likesCount = postModel.likesCount
        self.commentsCount = postModel.commentsCount
        self.isLiked = postModel.isLiked
        self.isBookmarked = postModel.isBookmarked
    }

}
