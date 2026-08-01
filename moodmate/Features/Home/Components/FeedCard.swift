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
    
    private var postAccentColor: Color {
        if let hex = post.moodColorHex {
            return Color.adaptiveMoodColor(hex: hex)
        }
        return Color.theme.accent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                NavigationLink(destination: ProfileView(userId: post.user.id)) {
                    HStack(spacing: 10) {
                        // Mini user avatar
                        AvatarView(
                            imageData: post.user.avatarImageData,
                            name: post.user.name,
                            colorHex: post.user.avatarColorHex,
                            size: 38,
                            showBorder: true
                        )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(post.user.name)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.theme.primaryText)
                                
                                Text("@\(post.user.username)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.theme.secondaryText)
                            }
                            
                            HStack(spacing: 6) {
                                // Mood Badge
                                if let mood = post.moodEmoji ?? post.user.currentMoodEmoji,
                                   let text = post.moodText ?? post.user.currentMoodText {
                                    HStack(spacing: 4) {
                                        Text(mood)
                                            .font(.system(size: 10))
                                        Text(text)
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2.5)
                                    .background(postAccentColor.opacity(0.15))
                                    .foregroundStyle(postAccentColor)
                                    .clipShape(Capsule())
                                }
                                
                                Text("•")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.theme.tertiaryText)
                                
                                Text(post.timeAgo)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.theme.secondaryText)
                                
                                if post.visibility != .publicVisibility {
                                    Image(systemName: post.visibility.iconName)
                                        .font(.system(size: 10))
                                        .foregroundStyle(Color.theme.tertiaryText)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            
            // Post Visual / Content Area
            if !post.images.isEmpty {
                // Photo Attachment Post Format
                photoContentSection
            } else if !post.quoteText.isEmpty {
                // Quote Card Format
                quoteContentSection
            } else if post.caption.isEmpty, let moodEmoji = post.moodEmoji, let moodText = post.moodText {
                // Mood-Only Hero Banner Format
                moodOnlyContentSection(moodEmoji: moodEmoji, moodText: moodText)
            }
            
            // Caption text (if present)
            if !post.caption.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(post.user.name)
                            .font(.system(size: 13, weight: .bold, design: .rounded)) +
                        Text("  ") +
                        Text(post.caption)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.theme.primaryText.opacity(0.9))
                    }
                    .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 16)
            }
            
            // Actions Bar (Like, Comment, Bookmark)
            HStack(spacing: 20) {
                // Like Button
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(post.isLiked ? Color.red : Color.theme.primaryText.opacity(0.8))
                        
                        Text("\(post.likesCount)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Comment Button
                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.theme.primaryText.opacity(0.8))
                        
                        Text("\(post.commentsCount)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Bookmark Button
                Button(action: onBookmark) {
                    Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(post.isBookmarked ? Color(hex: "FAB005") : Color.theme.primaryText.opacity(0.8))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 16)
            
            Divider()
                .padding(.top, 10)
                .background(Color.theme.divider)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Photo Content Section
    private var photoContentSection: some View {
        VStack(spacing: 8) {
            ForEach(post.images, id: \.self) { imageString in
                if let uiImage = imageFromBase64(imageString) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.theme.shadow, radius: 8, x: 0, y: 4)
                } else {
                    // Fallback visual container if string is non-base64
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(postAccentColor.opacity(0.2))
                            .frame(height: 220)
                        
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundStyle(postAccentColor)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Quote Content Section
    private var quoteContentSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.adaptiveMoodColor(hex: post.postGradientStartHex),
                            Color.adaptiveMoodColor(hex: post.postGradientEndHex)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 220)
                .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 6)
            
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
    }
    
    // MARK: - Mood-Only Banner Section
    private func moodOnlyContentSection(moodEmoji: String, moodText: String) -> some View {
        HStack(spacing: 16) {
            Text(moodEmoji)
                .font(.system(size: 44))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Mood")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(postAccentColor)
                    .textCase(.uppercase)
                
                Text("Feeling \(moodText)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(postAccentColor.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(postAccentColor.opacity(0.3), lineWidth: 1.5)
        )
        .padding(.horizontal, 16)
    }
    
    // Helper to decode Base64 image strings
    private func imageFromBase64(_ string: String) -> UIImage? {
        var base64 = string
        if string.contains(",") {
            let components = string.components(separatedBy: ",")
            if components.count > 1 {
                base64 = components[1]
            }
        }
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            FeedCard(
                post: FeedPost(
                    id: "p1",
                    user: MoodUser(id: "2", name: "Michele", username: "mj", avatarImageName: nil, avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
                    timeAgo: "2h ago",
                    quoteText: "Breathe in experience, breathe out poetry.",
                    caption: "Taking a conscious pause today. 🌱"
                ),
                onLike: {}, onBookmark: {}, onComment: {}
            )
        }
    }
}
