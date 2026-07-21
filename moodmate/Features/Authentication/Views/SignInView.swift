//
//  SignInView.swift
//  moodmate
//
//  Created by Nurtore on 21.07.2026.
//

import SwiftUI

@MainActor
struct SignInView: View {
    @StateObject private var viewModel: SignInViewModel

    init(viewModel: SignInViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    init() {
        _viewModel = StateObject(wrappedValue: SignInViewModel())
    }

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
    SignInView()
}
