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
            // Non-intrusive banner for partial content
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
            .background(Color(.systemBackground).opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        } else {
            // Full-screen error state
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.06))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.red.opacity(0.7).gradient)
                }
                
                VStack(spacing: 8) {
                    Text("Something went wrong")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
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
                    .background(Color.teal)
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
