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

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    convenience init() {
        self.init(authService: FirebaseAuthService.shared)
    }

    func submit() {
        guard validateInputs() else { return }

        isLoading = true

        Task {
            do {
                _ = try await authService.signUp(email: email, password: password)
                self.isLoading = false
                let displayName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
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
