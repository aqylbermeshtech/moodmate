//
//  StreaksSectionView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct StreaksSectionView: View {
    let streaks: StreakData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Streak & Consistency")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Your daily posting momentum")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // Grid of Achievement Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StreakCard(
                    iconName: "flame.fill",
                    iconGradient: [.orange, .red],
                    title: "Current Streak",
                    value: "\(streaks.currentStreakDays) Days",
                    badgeText: "Active"
                )
                
                StreakCard(
                    iconName: "trophy.fill",
                    iconGradient: [.yellow, .orange],
                    title: "Longest Streak",
                    value: "\(streaks.longestStreakDays) Days",
                    badgeText: "Record"
                )
                
                StreakCard(
                    iconName: "calendar.badge.clock",
                    iconGradient: [.teal, .blue],
                    title: "Best Month",
                    value: streaks.bestMonthName,
                    badgeText: "31 Days"
                )
                
                StreakCard(
                    iconName: "bolt.shield.fill",
                    iconGradient: [.purple, .indigo],
                    title: "Consistency",
                    value: "\(streaks.consistencyScorePercentage)%",
                    badgeText: "High"
                )
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

// MARK: - Individual Streak Card
private struct StreakCard: View {
    let iconName: String
    let iconGradient: [Color]
    let title: String
    let value: String
    let badgeText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: iconGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 38, height: 38)
                        .shadow(color: iconGradient.first?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 2)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Text(badgeText)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(iconGradient.first ?? .primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((iconGradient.first ?? .primary).opacity(0.12))
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        }
    }
}
