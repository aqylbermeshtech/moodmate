//
//  AnalyticsErrorView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct AnalyticsErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 38))
                .foregroundStyle(.orange)
            
            VStack(spacing: 4) {
                Text("Unable to Load Insights")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.teal)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.theme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.theme.warning.opacity(0.3), lineWidth: 0.5)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}
