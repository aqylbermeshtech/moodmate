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

    init(
        authService: AuthServiceProtocol = FirebaseAuthService.shared,
        profileService: ProfileServiceProtocol = ProfileService.shared
    ) {
        authService.addAuthStateListener { [weak self] user in
            guard let self = self else { return }
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = user != nil
                self.isResolvingSession = false
                if let user {
                    profileService.syncWithFirebaseUser(user: user)
                }
            }
        }
    }
}
