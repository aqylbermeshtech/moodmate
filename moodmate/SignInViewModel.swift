//
//  SignInViewModel.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//

import SwiftUI
import Combine

enum AuthMode {
    case signIn
    case signUp
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authMode: AuthMode = .signIn
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false

    func toggleMode() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            authMode = authMode == .signIn ? .signUp : .signIn
        }
    }

    func submit() {
        guard validateInputs() else { return }

        isLoading = true

        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                self.isLoading = false
                self.alertMessage = self.authMode == .signIn
                    ? "Welcome back to MoodMate!"
                    : "Account created! Welcome to MoodMate, \(self.name)."
                self.showAlert = true
            }
        }
    }

    private func validateInputs() -> Bool {
        switch authMode {
        case .signIn:
            guard !email.isEmpty, !password.isEmpty else {
                setAlert("Please enter both email and password.")
                return false
            }
        case .signUp:
            guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
                setAlert("Please fill in all fields.")
                return false
            }

            guard password == confirmPassword else {
                setAlert("Passwords do not match.")
                return false
            }
        }

        return true
    }

    private func setAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct AuthActionButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.teal)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        .disabled(isLoading)
    }
}

struct SignInView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(
                placeholder: "Email Address",
                text: $viewModel.email,
                icon: "envelope",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            CustomSecureField(
                placeholder: "Password",
                text: $viewModel.password,
                icon: "lock"
            )

            AuthActionButton(title: "Sign In", isLoading: viewModel.isLoading) {
                viewModel.submit()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("MoodMate"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SignInView(viewModel: AuthViewModel())
}
