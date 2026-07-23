//
//  PostDetailView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI

struct MockComment: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let avatarColorHex: String
    let text: String
    let timeAgo: String
}

struct PostDetailView: View {
    let post: ProfilePost
    let user: UserProfile
    
    @State private var comments: [MockComment] = []
    @State private var commentText = ""
    @State private var isLiked = false
    @State private var likesCount = 0
    @State private var isBookmarked = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: [Color.teal.opacity(0.12), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Full post card
                    postCard
                    
                    // Comments Section Title
                    Text("Comments (\(comments.count))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    if comments.isEmpty {
                        // Empty Comments State
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                            Text("No comments yet")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("Be the first to share your thoughts!")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        // Comments list
                        LazyVStack(spacing: 16) {
                            ForEach(comments) { comment in
                                commentRow(comment: comment)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100) // Padding for input text field
                }
                .padding(.top, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Bottom comment input bar
            commentInputBar
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            initializePostState()
        }
    }
    
    // MARK: - Post Visual Card (similar to FeedCard but self-contained)
    private var postCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                // Mini user avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: user.avatarColorHex).opacity(0.85),
                                    Color(hex: user.avatarColorHex)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(getInitials(user.displayName))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 38, height: 38)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("@\(user.username)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    
                    HStack(spacing: 6) {
                        if let moodEmoji = user.currentMoodEmoji, let moodText = user.currentMoodText {
                            HStack(spacing: 4) {
                                Text(moodEmoji)
                                    .font(.system(size: 10))
                                Text(moodText)
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(Color(hex: user.currentMoodColorHex ?? "38B2AC").opacity(0.08))
                            .foregroundStyle(Color(hex: user.currentMoodColorHex ?? "38B2AC"))
                            .clipShape(Capsule())
                        }
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary.opacity(0.5))
                        
                        Text(formatDate(post.createdAt))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Large Post Visual (Premium mindfulness quote background card)
            ZStack {
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
                
                // Abstract Circles
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
                Button(action: toggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(isLiked ? Color.red : Color.primary.opacity(0.8))
                        
                        Text("\(likesCount)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Comment Info
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.8))
                    
                    Text("\(comments.count)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Bookmark Button
                Button(action: toggleBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isBookmarked ? Color(hex: "FAB005") : Color.primary.opacity(0.8))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.displayName)  \(post.caption)")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.primary.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Comment Row Component
    private func commentRow(comment: MockComment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: comment.avatarColorHex).opacity(0.85), Color(hex: comment.avatarColorHex)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(getInitials(comment.name))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(comment.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("@\(comment.username)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary.opacity(0.7))
                    
                    Spacer()
                    
                    Text(comment.timeAgo)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary.opacity(0.6))
                }
                
                Text(comment.text)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary.opacity(0.9))
            }
        }
        .padding(10)
        .background(Color(.systemBackground).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    // MARK: - Bottom Input Bar
    private var commentInputBar: some View {
        HStack(spacing: 12) {
            TextField("Write a comment...", text: $commentText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                )
            
            Button(action: addComment) {
                ZStack {
                    Circle()
                        .fill(commentText.isEmpty ? Color.teal.opacity(0.5) : Color.teal)
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            }
            .disabled(commentText.isEmpty)
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(.systemBackground)
                .opacity(0.85)
                .background(.ultraThinMaterial)
        )
    }
    
    // MARK: - Actions & Helpers
    private func initializePostState() {
        self.isLiked = post.isLiked
        self.likesCount = post.likesCount
        self.isBookmarked = post.isBookmarked
        
        // Setup initial mock comments
        self.comments = [
            MockComment(name: "Emma", username: "emma_zen", avatarColorHex: "4DABF7", text: "Such a beautiful quote! Grateful for this reminder today. 🙏🧘‍♀️", timeAgo: "1h ago"),
            MockComment(name: "Alex", username: "alex_active", avatarColorHex: "FF6B6B", text: "Love the positive energy, keep tracking! 💪✨", timeAgo: "45m ago")
        ]
    }
    
    private func toggleLike() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
            if isLiked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
        }
    }
    
    private func toggleBookmark() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isBookmarked.toggle()
        }
    }
    
    private func addComment() {
        guard !commentText.isEmpty else { return }
        
        let newComment = MockComment(
            name: "You",
            username: "johndoe",
            avatarColorHex: "38B2AC",
            text: commentText,
            timeAgo: "Just now"
        )
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            comments.append(newComment)
            commentText = ""
        }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: ProfilePost(
                id: "1",
                quoteText: "Grateful hearts see awesome things.",
                caption: "Reflected on the beauty of nature. Grateful for the warm sun.",
                postGradientStartHex: "38B2AC",
                postGradientEndHex: "805AD5",
                likesCount: 12,
                commentsCount: 2,
                isLiked: false,
                isBookmarked: false,
                createdAt: Date()
            ),
            user: UserProfile(
                id: "1",
                displayName: "Emma Zen",
                username: "emma_zen",
                avatarColorHex: "4DABF7",
                bio: "Mindfulness guide",
                currentMoodEmoji: "😌",
                currentMoodText: "Calm",
                currentMoodColorHex: "4A5568",
                moodStreak: 5,
                postsCount: 10,
                followersCount: 200,
                followingCount: 150,
                isFollowing: true,
                achievements: [],
                moodHistory: []
            )
        )
    }
}
