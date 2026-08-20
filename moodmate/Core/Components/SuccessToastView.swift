//
//  SuccessToastView.swift
//  moodmate
//
//  Created by Antigravity on 31.07.2026.
//

import SwiftUI

struct SuccessToastView: View {
    let message: String
    let iconName: String
    
    init(message: String = "Profile updated successfully!", iconName: String = "checkmark.circle.fill") {
        self.message = message
        self.iconName = iconName
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.theme.accent)
            
            Text(message)
                .font(.xDisplayName)
                .foregroundStyle(Color.theme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.cardBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.theme.accent.opacity(0.3), lineWidth: 0.5)
        )
        .padding(.horizontal, 24)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
