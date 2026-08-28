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

    /// Pre-auth placeholder id; mock data is seeded/queried against it.
    static let mockUserId = "current_user_mock"

    /// Static (not an instance method) so repositories can call it without
    /// depending on `AppSessionManager.shared` — that dependency would risk a
    /// circular-singleton-construction deadlock.
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
