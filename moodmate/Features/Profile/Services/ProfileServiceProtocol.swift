//
//  ProfileServiceProtocol.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import UIKit
import Combine

protocol ProfileServiceProtocol: AnyObject {
    /// Publisher that emits whenever a profile is updated across the app.
    var profileUpdatesPublisher: AnyPublisher<UserProfile, Never> { get }
    
    /// Returns the profile for the given ID synchronously from memory, or the current user's profile if ID is nil.
    func getProfile(forId id: String?) -> UserProfile?
    
    /// Returns all posts for the given user ID synchronously, or the current user's posts if ID is nil.
    func getPosts(forId id: String?) -> [ProfilePost]
    
    /// Returns the active user's stable unique identifier.
    func getCurrentUserId() -> String
    
    /// Fetches the profile asynchronously for the given user ID.
    func fetchProfile(forId id: String?) async throws -> UserProfile?
    
    /// Forces a refresh of the specified user's profile from persistent storage.
    func refreshProfile(forId id: String?) async throws -> UserProfile?
    
    /// Updates the editable profile details for a user and persists changes.
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
    
    /// Uploads and compresses a custom profile avatar image.
    func uploadAvatar(image: UIImage, userId: String) async throws -> Data
    
    /// Removes the custom avatar image for a user, reverting to color initials.
    func deleteAvatar(userId: String) async throws
    
    /// Toggles the follow status for the target user ID and updates follower counts.
    func toggleFollow(targetId: String) -> UserProfile?
    
    /// Returns followers for the specified user ID.
    func getFollowers(forId id: String?) -> [UserProfile]
    
    /// Returns users that the specified user is following.
    func getFollowing(forId id: String?) -> [UserProfile]
    
    /// Validates username availability and format rules.
    func validateUsername(username: String, currentUserId: String) -> (isValid: Bool, error: String?)
}
