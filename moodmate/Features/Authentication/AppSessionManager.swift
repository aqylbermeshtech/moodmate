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
    
    static let shared = AppSessionManager()
    
    private init() {
        // Initialize listener
        FirebaseAuthService.shared.addAuthStateListener { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = user != nil
            }
        }
    }
}
