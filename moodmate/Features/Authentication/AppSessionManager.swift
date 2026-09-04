//
//  AppSessionManager.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AppSessionManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isResolvingSession = true
    
    static let shared = AppSessionManager()

    /// Static (not an instance method) so repositories can call it without
    /// depending on `AppSessionManager.shared` — that dependency would risk a
    /// circular-singleton-construction deadlock.
    ///
    /// Empty while signed out. The app UI is gated behind authentication, so
    /// callers only ever see a real uid from a screen the user can reach.
    static func currentUserId() -> String {
        FirebaseAuthService.shared.currentUser?.uid ?? ""
    }

    init(
        authService: AuthServiceProtocol = FirebaseAuthService.shared,
        profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared
    ) {
        authService.addAuthStateListener { [weak self] user in
            guard let self = self else { return }
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = user != nil
                self.isResolvingSession = false
                if let user {
                    profileRepository.syncWithFirebaseUser(user: user)
                }
            }
        }
    }
}
