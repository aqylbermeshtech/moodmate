//
//  PostModel.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import Foundation

// MARK: - Post Model
struct PostModel: Identifiable, Codable, Equatable {
    let id: String
    var authorId: String
    var mood: String?
    var moodEmoji: String?
    var moodColorHex: String?
    var text: String?
    var images: [String]
    var visibility: Visibility
    let createdAt: Date
    var likesCount: Int
    var commentsCount: Int
    var bookmarksCount: Int
    var isLiked: Bool
    var isBookmarked: Bool

    var quoteText: String?
    var gradientStartHex: String?
    var gradientEndHex: String?
    
    var formattedTimeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Post Draft Model
struct PostDraft: Codable, Equatable {
    var moodText: String?
    var moodEmoji: String?
    var moodColorHex: String?
    var text: String
    var imageBase64Strings: [String]
    var visibility: Visibility
    var savedAt: Date
}
