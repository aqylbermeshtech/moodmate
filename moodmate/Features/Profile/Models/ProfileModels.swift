//
//  ProfileModels.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import Foundation

struct UserProfile: Identifiable, Equatable, Codable {
    /// Avatar tint used until the user picks one of their own.
    static let defaultAvatarColorHex = "38B2AC"

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

    /// Interest ids from `InterestCatalog`, in the order the user picked them.
    var interests: [String]

    /// Set once the interests onboarding has been completed. Kept separate
    /// from `interests.isEmpty` so that clearing every interest later doesn't
    /// drop the user back into onboarding.
    var hasCompletedOnboarding: Bool

    init(
        id: String,
        displayName: String,
        username: String,
        avatarColorHex: String = UserProfile.defaultAvatarColorHex,
        avatarImageData: Data? = nil,
        avatarImageName: String? = nil,
        bio: String = "",
        location: String? = nil,
        birthday: Date? = nil,
        privacySetting: Visibility = .publicVisibility,
        isFollowing: Bool = false,
        interests: [String] = [],
        hasCompletedOnboarding: Bool = false
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
        self.interests = interests
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    /// Hand-written so profiles persisted before interests existed still
    /// decode: the synthesized initializer would throw on the missing keys.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        username = try container.decode(String.self, forKey: .username)
        avatarColorHex = try container.decode(String.self, forKey: .avatarColorHex)
        avatarImageData = try container.decodeIfPresent(Data.self, forKey: .avatarImageData)
        avatarImageName = try container.decodeIfPresent(String.self, forKey: .avatarImageName)
        bio = try container.decode(String.self, forKey: .bio)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
        privacySetting = try container.decode(Visibility.self, forKey: .privacySetting)
        isFollowing = try container.decode(Bool.self, forKey: .isFollowing)
        interests = try container.decodeIfPresent([String].self, forKey: .interests) ?? []
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    }
}
