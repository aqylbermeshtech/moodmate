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
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 13, weight: .bold))
                    
                    Text("Publish")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isValid && !isPublishing {
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: isValid && !isPublishing ? accentColor.opacity(0.35) : Color.clear, radius: 8, x: 0, y: 4)
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
