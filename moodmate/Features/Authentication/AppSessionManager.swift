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

    /// Canonical pre-auth placeholder id, used while no Firebase user is
    /// signed in yet (mock data is seeded/queried against this id).
    static let mockUserId = "current_user_mock"

    /// The one place "who is the current user" gets resolved. A static
    /// function rather than an instance method so repositories (which must
    /// not depend on AppSessionManager.shared — see PostRepository/
    /// ProfileRepository's one-directional dependency on this class) can
    /// call it without any risk of the circular-singleton-construction
    /// deadlock that a `.shared`-defaulted instance dependency would cause.
    static func currentUserId() -> String {
        FirebaseAuthService.shared.currentUser?.uid ?? mockUserId
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
