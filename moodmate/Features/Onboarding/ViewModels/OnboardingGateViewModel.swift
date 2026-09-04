//
//  OnboardingGateViewModel.swift
//  moodmate
//
//  Decides which of the three post-authentication screens `RootView` shows.
//  Reads the current profile synchronously on refresh and then follows
//  `profileUpdatesPublisher`, so finishing onboarding moves the app on with
//  no extra plumbing between the two screens.
//

import Foundation
import Combine

@MainActor
final class OnboardingGateViewModel: ObservableObject {

    enum Status: Equatable {
        /// Signed in, but the profile hasn't landed yet — keep showing the
        /// splash rather than flashing the wrong screen.
        case undetermined
        case needsInterests
        case ready
    }

    @Published private(set) var status: Status = .undetermined

    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.profileRepository = profileRepository
        observeProfileUpdates()
    }

    func refresh(isAuthenticated: Bool) {
        guard isAuthenticated else {
            status = .undetermined
            return
        }
        apply(profileRepository.getProfile(forId: AppSessionManager.currentUserId()))
    }

    private func observeProfileUpdates() {
        profileRepository.profileUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self, profile.id == AppSessionManager.currentUserId() else { return }
                self.apply(profile)
            }
            .store(in: &cancellables)
    }

    private func apply(_ profile: UserProfile?) {
        guard let profile else {
            status = .undetermined
            return
        }
        status = profile.hasCompletedOnboarding ? .ready : .needsInterests
    }
}
