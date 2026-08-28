//
//  SignUpViewModel.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//

import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let authService: AuthServiceProtocol
    private let profileRepository: ProfileRepositoryProtocol

    init(authService: AuthServiceProtocol, profileRepository: ProfileRepositoryProtocol = ProfileRepository.shared) {
        self.authService = authService
        self.profileRepository = profileRepository
    }

    convenience init() {
        self.init(authService: FirebaseAuthService.shared)
    }

    func submit() {
        guard validateInputs() else { return }

        isLoading = true

        Task {
            do {
                let displayName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                let user = try await authService.signUp(email: email, password: password, displayName: displayName)

                // Apply the name directly, not via user.displayName: Firebase's
                // auth-state listener can fire before the displayName write
                // commits and would fall back to an email-derived name.
                if !displayName.isEmpty {
                    var profile = self.profileRepository.getProfile(forId: user.uid)
                        ?? MockDataProvider.newAuthenticatedUserSeedProfile(id: user.uid, displayName: displayName)
                    profile.displayName = displayName
                    self.profileRepository.setProfile(profile)
                }

                self.isLoading = false
                self.successMessage = "Account created! Welcome to MoodMate\(displayName.isEmpty ? "" : ", " + displayName)."
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func validateInputs() -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        return true
    }
}
