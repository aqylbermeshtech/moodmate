//
//  CustomTextField.swift
//  moodmate
//
//  Created by Nurtore on 20.07.2026.
//
import SwiftUI
import UIKit

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.theme.secondaryText)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .foregroundStyle(Color.theme.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.theme.secondaryText)
                .frame(width: 20)

            SecureField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Color.theme.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
}
