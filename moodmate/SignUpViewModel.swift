//
//  SignUpViewModel.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(
                placeholder: "Name",
                text: $viewModel.name,
                icon: "person",
                autocapitalization: .words
            )

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

            CustomSecureField(
                placeholder: "Confirm Password",
                text: $viewModel.confirmPassword,
                icon: "lock.shield"
            )

            AuthActionButton(title: "Create Account", isLoading: viewModel.isLoading) {
                viewModel.submit()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("MoodMate"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SignUpView(viewModel: AuthViewModel())
}
