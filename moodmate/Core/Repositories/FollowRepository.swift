//
//  FollowRepository.swift
//  moodmate
//
//  Follow/unfollow + follower/following queries, extracted from
//  ProfileService. Follow state stays denormalized on UserProfile
//  (just `isFollowing`) rather than as an independent relationship store —
//  this reads/writes that flag through ProfileRepository rather than
//  owning storage of its own. Follower/following *counts* are derived at
//  display time from the queried lists, not stored.
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

        targetProfile.isFollowing.toggle()
        profileRepository.setProfile(targetProfile)

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
