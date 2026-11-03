//
//  AppSessionManager.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//
//  App-scope session state: observes the auth service and mirrors the
//  signed-in `AuthUser` for the UI. Owned by DIContainer; the static
//  members below are compatibility shims for app services created outside
//  the container (AppRouter) and previews.
//

import Foundation
import Combine

@MainActor
final class AppSessionManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isResolvingSession = true

    /// The canonical instance, owned by the composition root.
    static var shared: AppSessionManager { DIContainer.shared.sessionManager }

    /// Compatibility shim for app services that can't take injected
    /// dependencies (deep-link routing). New code should take
    /// `CurrentUserProviderProtocol` instead.
    static func currentUserId() -> String {
        DIContainer.shared.currentUserId
    }

    init(
        authService: AuthServiceProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        authService.addAuthStateListener { [weak self] user in
            guard let self = self else { return }
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = user != nil
                self.isResolvingSession = false
                if let user {
                    profileRepository.syncWithAuthUser(user)
                }
            }
        }
    }
}
