//
//  ProfileModels.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import Foundation

struct UserProfile: Identifiable, Equatable, Codable {
    var id: String
    var displayName: String
    var username: String
    var avatarColorHex: String
    var avatarImageData: Data?
    var avatarImageName: String?
    var bio: String
    var location: String?
    var birthday: Date?
    var privacySetting: Visibility
    var isFollowing: Bool

    init(
        id: String,
        displayName: String,
        username: String,
        avatarColorHex: String = "38B2AC",
        avatarImageData: Data? = nil,
        avatarImageName: String? = nil,
        bio: String = "",
        location: String? = nil,
        birthday: Date? = nil,
        privacySetting: Visibility = .publicVisibility,
        isFollowing: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarColorHex = avatarColorHex
        self.avatarImageData = avatarImageData
        self.avatarImageName = avatarImageName
        self.bio = bio
        self.location = location
        self.birthday = birthday
        self.privacySetting = privacySetting
        self.isFollowing = isFollowing
    }
}
