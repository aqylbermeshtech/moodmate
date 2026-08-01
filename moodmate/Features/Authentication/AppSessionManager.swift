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
    // True until Firebase's first auth-state callback fires.
    // RootView waits on this before rendering either screen,
    // which prevents the Sign In flash on launch when a session already exists.
    @Published var isResolvingSession = true
    
    static let shared = AppSessionManager()
    
    private init() {
        FirebaseAuthService.shared.addAuthStateListener { [weak self] user in
            guard let self = self else { return }
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = user != nil
                // Mark session as resolved after the first callback — only fires once.
                self.isResolvingSession = false
                if let user {
                    ProfileService.shared.syncWithFirebaseUser(user: user)
                }
            }
        }
    }
}
