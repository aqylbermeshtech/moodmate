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
//  `isFollowing` only records who the *signed-in* user follows, so that is
//  the only edge these queries can answer truthfully: a full follower graph
//  needs a backend that stores both directions.
//

import Foundation

nonisolated final class FollowRepository: FollowRepositoryProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let currentUserProvider: CurrentUserProviderProtocol

    init(profileRepository: ProfileRepositoryProtocol, currentUserProvider: CurrentUserProviderProtocol) {
        self.profileRepository = profileRepository
        self.currentUserProvider = currentUserProvider
    }

    func toggleFollow(targetId: String) -> UserProfile? {
        guard var targetProfile = profileRepository.getProfile(forId: targetId) else { return nil }

        targetProfile.isFollowing.toggle()
        profileRepository.setProfile(targetProfile)

        return targetProfile
    }

    /// Only one follower edge is knowable locally: the signed-in user follows
    /// this account. Nobody else's followers can be resolved without a backend.
    func getFollowers(forId id: String?) -> [UserProfile] {
        let currentUserId = currentUserProvider.currentUserId
        let actualId = id ?? currentUserId

        guard actualId != currentUserId,
              profileRepository.getProfile(forId: actualId)?.isFollowing == true,
              let currentUserProfile = profileRepository.getProfile(forId: currentUserId) else {
            return []
        }

        return [currentUserProfile]
    }

    func getFollowing(forId id: String?) -> [UserProfile] {
        let currentUserId = currentUserProvider.currentUserId
        let actualId = id ?? currentUserId

        guard actualId == currentUserId else { return [] }

        return profileRepository.allProfiles()
            .filter { $0.id != actualId && $0.isFollowing }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }
}
