//
//  ProfileServiceProtocol.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import UIKit
import Combine

protocol ProfileServiceProtocol: AnyObject {
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }
    
    func getProfile(forId id: String?) -> UserProfile?
    func getCurrentUserId() -> String
    func fetchProfile(forId id: String?) async throws -> UserProfile?
    func refreshProfile(forId id: String?) async throws -> UserProfile?
    func updateProfile(
        id: String,
        displayName: String,
        username: String,
        bio: String,
        location: String?,
        birthday: Date?,
        privacySetting: PrivacySetting,
        avatarColorHex: String,
        avatarImageData: Data?,
        clearAvatar: Bool
    ) async throws -> UserProfile
    func uploadAvatar(image: UIImage, userId: String) async throws -> Data
    func deleteAvatar(userId: String) async throws
    func toggleFollow(targetId: String) -> UserProfile?
    func getFollowers(forId id: String?) -> [UserProfile]
    func getFollowing(forId id: String?) -> [UserProfile]
    func validateUsername(username: String, currentUserId: String) -> (isValid: Bool, error: String?)
}
