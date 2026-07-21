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
    @Published var alertMessage = ""
    @Published var showAlert = false

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
                self.alertMessage = "Welcome back to MoodMate!"
                self.showAlert = true
            } catch {
                self.isLoading = false
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }

    private func validateInputs() -> Bool {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            setAlert("Please enter both email and password.")
            return false
        }
        return true
    }

    private func setAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
