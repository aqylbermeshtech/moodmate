//
//  DiscoverErrorView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DiscoverErrorView: View {
    let message: String
    let isPartialContent: Bool
    var onRetry: () -> Void
    
    var body: some View {
        if isPartialContent {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: onRetry) {
                    Text("Retry")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.teal)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.theme.warning.opacity(0.3), lineWidth: 0.5)
            )
            .padding(.horizontal, 20)
        } else {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.theme.error.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.theme.error)
                }
                
                VStack(spacing: 8) {
                    Text("Something went wrong")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)
                    
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button(action: onRetry) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                        Text("Try Again")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.theme.accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.vertical, 60)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        DiscoverErrorView(
            message: "Could not load content. Check your connection.",
            isPartialContent: false,
            onRetry: {}
        )
        
        DiscoverErrorView(
            message: "Failed to load more posts.",
            isPartialContent: true,
            onRetry: {}
        )
    }
}
