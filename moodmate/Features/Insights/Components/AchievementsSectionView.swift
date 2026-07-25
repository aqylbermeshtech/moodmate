//
//  AchievementsSectionView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct AchievementsSectionView: View {
    let achievements: [InsightAchievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Badges & Achievements")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(achievements.filter(\.isUnlocked).count) / \(achievements.count) Unlocked")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.teal)
                }
                
                Text("Milestones on your emotional growth path")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(achievements) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }
}

private struct AchievementCardView: View {
    let achievement: InsightAchievement
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                        ? Color(hex: achievement.badgeColorHex).opacity(0.18)
                        : Color.primary.opacity(0.06)
                    )
                    .frame(width: 58, height: 58)
                
                Text(achievement.iconEmoji)
                    .font(.system(size: 30))
                    .grayscale(achievement.isUnlocked ? 0 : 1.0)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.4)
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: achievement.badgeColorHex))
                        .offset(x: 20, y: -20)
                }
            }
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.06))
                            .frame(height: 5)
                        
                        Capsule()
                            .fill(Color(hex: achievement.badgeColorHex))
                            .frame(width: geo.size.width * CGFloat(achievement.percentage), height: 5)
                    }
                }
                .frame(height: 5)
                
                Text(achievement.isUnlocked ? (achievement.unlockedDateLabel ?? "Unlocked") : "\(achievement.progress) / \(achievement.totalTarget)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(achievement.isUnlocked ? Color(hex: achievement.badgeColorHex) : .secondary)
            }
        }
        .frame(width: 140)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            achievement.isUnlocked
                            ? Color(hex: achievement.badgeColorHex).opacity(0.4)
                            : Color.white.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}
