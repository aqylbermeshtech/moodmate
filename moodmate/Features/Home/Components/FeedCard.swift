//
//  FeedCard.swift
//  moodmate
//
//  Created by Nurtore on 22.07.2026.
//

import SwiftUI

struct FeedCard: View {
    let post: FeedPost
    var onLike: () -> Void
    var onBookmark: () -> Void
    var onComment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                NavigationLink(destination: ProfileView(userId: post.user.id)) {
                    HStack(spacing: 10) {
                        // Mini user avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: post.user.avatarColorHex).opacity(0.85),
                                            Color(hex: post.user.avatarColorHex)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(getInitials(post.user.name))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 38, height: 38)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color(hex: post.user.currentMoodColorHex ?? "38B2AC").opacity(0.4),
                                    lineWidth: 1.5
                                )
                        )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(post.user.name)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Text("@\(post.user.username)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary.opacity(0.7))
                            }
                            
                            HStack(spacing: 6) {
                                // Mood Badge
                                if let mood = post.user.currentMoodEmoji, let text = post.user.currentMoodText {
                                    HStack(spacing: 4) {
                                        Text(mood)
                                            .font(.system(size: 10))
                                        Text(text)
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2.5)
                                    .background(Color(hex: post.user.currentMoodColorHex ?? "38B2AC").opacity(0.08))
                                    .foregroundStyle(Color(hex: post.user.currentMoodColorHex ?? "38B2AC"))
                                    .clipShape(Capsule())
                                }
                                
                                Text("•")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary.opacity(0.5))
                                
                                Text(post.timeAgo)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary.opacity(0.8))
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            
            // Large Post Visual (Premium mindfulness quote background card)
            ZStack {
                // Interactive abstract design container
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: post.postGradientStartHex),
                                Color(hex: post.postGradientEndHex)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)
                    .shadow(color: Color(hex: post.postGradientStartHex).opacity(0.12), radius: 10, x: 0, y: 6)
                
                // Overlay organic abstract shape for premium styling
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                            .blur(radius: 20)
                            .offset(x: geo.size.width * 0.15, y: -geo.size.height * 0.1)
                        
                        Circle()
                            .fill(Color.black.opacity(0.08))
                            .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                            .blur(radius: 30)
                            .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.2)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Quote text overlay
                VStack {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, 4)
                    
                    Text(post.quoteText)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .minimumScaleFactor(0.85)
                    
                    Image(systemName: "quote.closing")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            
            // Actions (Like, Comment, Bookmark)
            HStack(spacing: 20) {
                // Like Button
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(post.isLiked ? Color.red : Color.primary.opacity(0.8))
                        
                        Text("\(post.likesCount)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Comment Button
                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.primary.opacity(0.8))
                        
                        Text("\(post.commentsCount)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Bookmark Button
                Button(action: onBookmark) {
                    Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(post.isBookmarked ? Color(hex: "FAB005") : Color.primary.opacity(0.8))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 16)
            
            // Caption text
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text(post.user.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded)) +
                    Text("  ") +
                    Text(post.caption)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary.opacity(0.9))
                }
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            
            Divider()
                .padding(.top, 10)
                .opacity(0.3)
        }
        .padding(.top, 8)
    }
    
    private func getInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts[0].first, let second = parts[1].first {
            return "\(first)\(second)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "?"
    }
}

#Preview {
    ScrollView {
        FeedCard(
            post: FeedPost(
                id: "p1",
                user: MoodUser(
                    id: "2", name: "Emma Watson", username: "emma_zen", avatarImageName: nil,
                    avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"
                ),
                timeAgo: "2 hours ago",
                postGradientStartHex: "38B2AC",
                postGradientEndHex: "805AD5",
                quoteText: "Breathe in experience, breathe out poetry.",
                caption: "Taking a conscious pause today. A reminder that it is okay to just be, rather than always do. 🌱✨",
                likesCount: 24,
                commentsCount: 3,
                isLiked: false,
                isBookmarked: false
            ),
            onLike: {},
            onBookmark: {},
            onComment: {}
        )
    }
}
