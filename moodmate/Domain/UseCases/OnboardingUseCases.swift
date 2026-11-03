//
//  OnboardingUseCases.swift
//  moodmate
//
//  Onboarding gate: reads the signed-in user's profile and streams its
//  updates so the root view can advance once interests are picked.
//  Completing onboarding reuses `UpdateInterestsUseCase`.
//

import Foundation
import Combine

nonisolated protocol ObserveCurrentProfileUseCaseProtocol {
    /// Synchronous read of the signed-in user's profile, if it has landed.
    func currentProfile() -> UserProfile?
    /// Updates for the signed-in user's profile only.
    var currentUserProfileUpdates: AnyPublisher<UserProfile, Never> { get }
}

nonisolated final class ObserveCurrentProfileUseCase: ObserveCurrentProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    private let currentUserProvider: CurrentUserProviderProtocol

    init(profileRepository: ProfileRepositoryProtocol, currentUserProvider: CurrentUserProviderProtocol) {
        self.profileRepository = profileRepository
        self.currentUserProvider = currentUserProvider
    }

    func currentProfile() -> UserProfile? {
        profileRepository.getProfile(forId: currentUserProvider.currentUserId)
    }

    var currentUserProfileUpdates: AnyPublisher<UserProfile, Never> {
        profileRepository.profileUpdatesPublisher
            .filter { [currentUserProvider] profile in
                profile.id == currentUserProvider.currentUserId
            }
            .eraseToAnyPublisher()
    }
}
