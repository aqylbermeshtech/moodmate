//
//  UserStore.swift
//  moodmate
//
//  The single canonical publisher of "what does this user look like right
//  now" — display name, username, avatar. Before this,
//  FeedViewModel, HomeViewModel, DiscoverViewModel, and CreatePostViewModel
//  each subscribed to profileUpdatesPublisher independently and patched
//  their own stored copy (FeedPost.user, currentUser, SuggestedUser,
//  DiscoverPost's author fields) — five sinks doing the same fan-out, any
//  one of which could silently fail to fire.
//
//  UserStore replaces that for post rendering specifically: posts carry
//  only an authorId, and views read the current identity here directly at
//  render time via user(for:). Because this type is @Observable, that
//  read participates in SwiftUI's normal view-invalidation tracking with
//  no sink required anywhere — there's nothing to keep in sync because
//  nothing else is holding a copy.
//

import Foundation
import Combine
import Observation

@MainActor
@Observable
final class UserStore: UserStoreProtocol {
    static let shared = UserStore()

    private var identities: [String: AppUser] = [:]
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.profileRepository = profileRepository
        seed()
        observeProfileUpdates()
    }

    private func seed() {
        for profile in profileRepository.allProfiles() {
            identities[profile.id] = Self.appUser(from: profile)
        }
    }

    private func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.identities[profile.id] = Self.appUser(from: profile)
            }
            .store(in: &cancellables)
    }

    func user(for id: String) -> AppUser? {
        identities[id]
    }

    private static func appUser(from profile: UserProfile) -> AppUser {
        AppUser(
            id: profile.id,
            name: profile.displayName,
            username: profile.username,
            avatarImageName: profile.avatarImageName,
            avatarImageData: profile.avatarImageData,
            avatarColorHex: profile.avatarColorHex
        )
    }
}
