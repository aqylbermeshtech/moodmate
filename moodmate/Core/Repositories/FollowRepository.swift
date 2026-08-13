//
//  FollowRepository.swift
//  moodmate
//
//  Follow/unfollow + follower/following queries, extracted from
//  ProfileService. Follow state stays denormalized on UserProfile
//  (isFollowing/followersCount/followingCount) rather than as an
//  independent relationship store — this reads/writes those fields through
//  ProfileRepository rather than owning storage of its own.
//

import Foundation

final class FollowRepository: FollowRepositoryProtocol {
    static let shared = FollowRepository()

    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.profileRepository = profileRepository
    }

    func toggleFollow(targetId: String) -> UserProfile? {
        guard var targetProfile = profileRepository.getProfile(forId: targetId) else { return nil }
        let currentId = AppSessionManager.currentUserId()
        guard var currentProfile = profileRepository.getProfile(forId: currentId) else { return nil }

        if targetProfile.isFollowing {
            targetProfile.isFollowing = false
            targetProfile.followersCount = max(0, targetProfile.followersCount - 1)
            currentProfile.followingCount = max(0, currentProfile.followingCount - 1)
        } else {
            targetProfile.isFollowing = true
            targetProfile.followersCount += 1
            currentProfile.followingCount += 1
        }

        profileRepository.setProfile(targetProfile)
        profileRepository.setProfile(currentProfile)

        return targetProfile
    }

    func getFollowers(forId id: String?) -> [UserProfile] {
        let actualId = id ?? AppSessionManager.currentUserId()
        return profileRepository.allProfiles()
            .filter { $0.id != actualId }
            .shuffled()
            .prefix(3)
            .map { $0 }
    }

    func getFollowing(forId id: String?) -> [UserProfile] {
        let actualId = id ?? AppSessionManager.currentUserId()
        if actualId == AppSessionManager.currentUserId() {
            return profileRepository.allProfiles().filter { $0.id != actualId && $0.isFollowing }
        } else {
            return profileRepository.allProfiles()
                .filter { $0.id != actualId }
                .shuffled()
                .prefix(2)
                .map { $0 }
        }
    }
}
