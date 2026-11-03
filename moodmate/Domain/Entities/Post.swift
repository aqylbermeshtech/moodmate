//
//  Post.swift
//  moodmate
//
//  Domain entity for a post, plus the create-post draft.
//

import Foundation

// MARK: - Post Model
nonisolated struct PostModel: Identifiable, Codable, Equatable {
    let id: String
    var authorId: String
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
nonisolated struct PostDraft: Codable, Equatable {
    var text: String
    var imageBase64Strings: [String]
    var visibility: Visibility
    var savedAt: Date
}
