//
//  AnalyticsEmptyStateView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct AnalyticsEmptyStateView: View {
    let onCreatePost: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.teal.opacity(0.2), .purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.teal, .purple], startPoint: .leading, endPoint: .trailing)
                    )
            }
            
            VStack(spacing: 8) {
                Text("No Analytics Yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Start logging your daily mood posts to unlock personalized insights, mood trends, streaks, and achievements.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: onCreatePost) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Log Your First Mood")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.teal, .teal.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .teal.opacity(0.35), radius: 10, x: 0, y: 5)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
    }
}
