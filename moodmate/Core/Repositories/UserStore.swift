//
//  UserStore.swift
//  moodmate
//
//  Canonical current identity (name, username, avatar) for a user id.
//  Posts carry only an authorId; views read the identity here at render
//  time. @Observable, so the read tracks for invalidation with no sink.
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
