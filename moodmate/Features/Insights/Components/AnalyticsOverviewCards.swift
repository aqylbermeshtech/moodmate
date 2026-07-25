//
//  AnalyticsOverviewCards.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct AnalyticsOverviewCards: View {
    let data: InsightsDashboardData
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            // 1. Current Mood
            OverviewCard(
                iconName: "face.smiling.fill",
                iconColor: Color(hex: data.currentMoodColorHex),
                title: "Current Mood",
                valueText: "\(data.currentMoodEmoji) \(data.currentMoodName)",
                subtitle: "Latest check-in"
            )
            
            // 2. Current Streak
            OverviewCard(
                iconName: "flame.fill",
                iconColor: .orange,
                title: "Current Streak",
                valueText: "\(data.streaks.currentStreakDays) Days",
                subtitle: "Best: \(data.streaks.longestStreakDays) Days"
            )
            
            // 3. Total Posts
            OverviewCard(
                iconName: "photo.stack.fill",
                iconColor: .teal,
                title: "Total Posts",
                valueText: "\(data.totalPostsCount)",
                subtitle: "Mood logs shared"
            )
            
            // 4. Likes Received
            OverviewCard(
                iconName: "heart.fill",
                iconColor: .pink,
                title: "Total Likes",
                valueText: "\(data.engagement.totalLikesReceived)",
                subtitle: "Received on posts"
            )
            
            // 5. Comments Received
            OverviewCard(
                iconName: "bubble.left.and.bubble.right.fill",
                iconColor: .purple,
                title: "Total Comments",
                valueText: "\(data.engagement.totalCommentsReceived)",
                subtitle: "Social responses"
            )
            
            // 6. Followers
            OverviewCard(
                iconName: "person.2.fill",
                iconColor: .indigo,
                title: "Followers",
                valueText: "\(data.engagement.followersCount)",
                subtitle: "Growing community"
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Individual Glass Overview Card
private struct OverviewCard: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let valueText: String
    let subtitle: String
    
    @State private var animateScale = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(iconColor)
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(valueText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
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
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        .scaleEffect(animateScale ? 1 : 0.95)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                animateScale = true
            }
        }
    }
}
