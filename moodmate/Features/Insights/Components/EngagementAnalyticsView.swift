//
//  EngagementAnalyticsView.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI
import Charts

struct EngagementAnalyticsView: View {
    let engagement: EngagementData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Community & Social Engagement")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("How friends & followers react to your mood posts")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                MetricPill(
                    icon: "heart.fill",
                    color: .pink,
                    label: "Avg Likes",
                    value: String(format: "%.1f", engagement.avgLikesPerPost)
                )
                
                MetricPill(
                    icon: "bubble.left.fill",
                    color: .purple,
                    label: "Avg Comments",
                    value: String(format: "%.1f", engagement.avgCommentsPerPost)
                )
                
                MetricPill(
                    icon: "person.2.fill",
                    color: .teal,
                    label: "Followers",
                    value: "\(engagement.followersCount)"
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Highlights")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                if let topLiked = engagement.mostLikedPost {
                    TopPostCard(title: "❤️ Most Liked Post", post: topLiked)
                }
                
                if let topCommented = engagement.mostCommentedPost {
                    TopPostCard(title: "💬 Most Commented Post", post: topCommented)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Follower Growth")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Chart(engagement.followerGrowth) { point in
                    LineMark(
                        x: .value("Month", point.label),
                        y: .value("Followers", point.count)
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(Color.theme.accent)
                    
                    PointMark(
                        x: .value("Month", point.label),
                        y: .value("Followers", point.count)
                    )
                    .foregroundStyle(Color.theme.accent)
                    .annotation(position: .top) {
                        Text("\(point.count)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.teal)
                    }
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let month = value.as(String.self) {
                                Text(month)
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.surface)
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

private struct MetricPill: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        }
    }
}

private struct TopPostCard: View {
    let title: String
    let post: EngagementPostSnapshot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
                Text(post.timeAgo)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: post.moodColorHex).opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text(post.moodEmoji)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.quoteText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(post.likesCount)", systemImage: "heart.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.pink)
                        
                        Label("\(post.commentsCount)", systemImage: "bubble.left.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.purple)
                    }
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        }
    }
}
