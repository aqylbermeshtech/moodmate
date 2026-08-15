//
//  SignInViewModel.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//

import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
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
                _ = try await authService.signIn(email: email, password: password)
                self.isLoading = false
                self.successMessage = "Welcome back to MoodMate!"
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func validateInputs() -> Bool {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return false
        }
        return true
    }
}
