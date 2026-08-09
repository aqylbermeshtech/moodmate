//
//  AuthActionButton.swift
//  moodmate
//
//  Created by Nurtore on 21.07.2026.
//

import SwiftUI

struct AuthActionButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.theme.primaryBackground)
            } else {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.theme.primaryBackground)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Color.theme.accent)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous))
        .disabled(isLoading)
    }
}

#Preview {
    AuthActionButton(title: "Sign In", isLoading: false, action: {})
        .padding()
}
