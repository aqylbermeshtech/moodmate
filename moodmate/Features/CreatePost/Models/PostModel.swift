//
//  PostModel.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI
import Foundation

// MARK: - Post Visibility
enum PostVisibility: String, Codable, CaseIterable, Identifiable {
    case publicVisibility = "Public"
    case friendsOnly = "Friends"
    case privateVisibility = "Private"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .publicVisibility: return "globe"
        case .friendsOnly: return "person.2.fill"
        case .privateVisibility: return "lock.fill"
        }
    }
    
    var description: String {
        switch self {
        case .publicVisibility: return "Visible to everyone on MoodMate"
        case .friendsOnly: return "Visible only to your friends"
        case .privateVisibility: return "Only visible to you"
        }
    }
}

// MARK: - Post Model
struct PostModel: Identifiable, Codable, Equatable {
    let id: String
    var author: MoodUser
    var mood: String?
    var moodEmoji: String?
    var moodColorHex: String?
    var text: String?
    var images: [String]
    var visibility: PostVisibility
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
    var visibility: PostVisibility
    var savedAt: Date
}
