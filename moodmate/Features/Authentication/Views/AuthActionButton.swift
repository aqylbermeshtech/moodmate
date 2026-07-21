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

#Preview {
    AuthActionButton(title: "Sign In", isLoading: false, action: {})
        .padding()
}
