//
//  PublishButton.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct PublishButton: View {
    let isValid: Bool
    let isPublishing: Bool
    let accentColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isPublishing {
                    ProgressView()
                        .tint(Color.theme.primaryBackground)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 13, weight: .bold))
                    
                    Text("Publish")
                        .font(.subheadline.weight(.medium))
                }
            }
            .foregroundStyle(Color.theme.primaryBackground)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(isValid && !isPublishing ? accentColor : Color.theme.tertiaryText)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous))
        }
        .disabled(!isValid || isPublishing)
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    HStack(spacing: 16) {
        PublishButton(isValid: true, isPublishing: false, accentColor: .teal, action: {})
        PublishButton(isValid: false, isPublishing: false, accentColor: .teal, action: {})
        PublishButton(isValid: true, isPublishing: true, accentColor: .teal, action: {})
    }
    .padding()
}
