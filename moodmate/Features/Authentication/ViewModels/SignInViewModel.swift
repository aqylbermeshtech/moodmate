//
//  SignInViewModel.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//

import SwiftUI
import Combine

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let signInUseCase: SignInUseCaseProtocol

    init(signInUseCase: SignInUseCaseProtocol = DIContainer.shared.signInUseCase) {
        self.signInUseCase = signInUseCase
    }

    func submit() {
        guard validateInputs() else { return }

        isLoading = true

        Task {
            do {
                _ = try await signInUseCase.execute(email: email, password: password)
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
