//
//  HomeModels.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct MoodUser: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let username: String
    let avatarImageName: String? // Optional custom image/system name
    let avatarColorHex: String   // Hex color for generating initials background
    var currentMoodEmoji: String?
    var currentMoodText: String?
    var currentMoodColorHex: String?
}

struct FeedPost: Identifiable, Equatable {
    let id: String
    let user: MoodUser
    let timeAgo: String
    let postGradientStartHex: String
    let postGradientEndHex: String
    let quoteText: String       // Inspirational post title/quote
    let caption: String
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    var isBookmarked: Bool
}
