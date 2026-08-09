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
    let post: FeedPost
    var onPostUpdated: (FeedPost) -> Void = { _ in }
    @EnvironmentObject private var navigationVisibility: NavigationVisibilityCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var comments: [MockComment] = []
    @State private var commentText = ""
    @State private var isLiked = false
    @State private var likesCount = 0
    @State private var isBookmarked = false
    
    @State private var displayPost: FeedPost?
    
    private var currentPost: FeedPost {
        displayPost ?? post
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PostCardView(
                        post: currentPost,
                        style: .detail,
                        onLike: toggleLike,
                        onBookmark: toggleBookmark,
                        onComment: {}
                    )
                    Text("Comments (\(comments.count))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    if comments.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.theme.secondaryText)
                            Text("No comments yet")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.theme.secondaryText)
                            Text("Be the first to share your thoughts!")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.theme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(comments) { comment in
                                commentRow(comment: comment)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 12)
            }
            .scrollDismissesKeyboard(.interactively)

            commentInputBar
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    updateNavigationVisibility(false)
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Back")
            }
        }
        .onAppear {
            updateNavigationVisibility(true)
            initializePostState()
        }
        .onDisappear {
            updateNavigationVisibility(false)
        }
    }

    private func updateNavigationVisibility(_ isDetailPresented: Bool) {
        Task { @MainActor in
            navigationVisibility.isPostDetailPresented = isDetailPresented
        }
    }
    
    // MARK: - Comment Row Component
    private func commentRow(comment: MockComment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(
                name: comment.name,
                colorHex: comment.avatarColorHex,
                size: 32,
                showBorder: false
            )
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(comment.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)
                    
                    Text("@\(comment.username)")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.theme.secondaryText)
                    
                    Spacer()
                    
                    Text(comment.timeAgo)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.theme.tertiaryText)
                }
                
                Text(comment.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.theme.primaryText.opacity(0.9))
            }
        }
        .padding(10)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    // MARK: - Bottom Input Bar
    private var commentInputBar: some View {
        HStack(spacing: 12) {
            TextField("Write a comment...", text: $commentText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.theme.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .foregroundStyle(Color.theme.primaryText)
            
            Button(action: addComment) {
                ZStack {
                    Circle()
                        .fill(commentText.isEmpty ? Color.theme.accent.opacity(0.5) : Color.theme.accent)
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
            Color.theme.cardBackground
        )
    }
    
    // MARK: - Actions & Helpers
    private func initializePostState() {
        self.isLiked = post.isLiked
        self.likesCount = post.likesCount
        self.isBookmarked = post.isBookmarked
        self.displayPost = post

        self.comments = [
            MockComment(name: "Michele", username: "mj", avatarColorHex: "4DABF7", text: "Such a beautiful quote! Grateful for this reminder today. 🙏🧘‍♀️", timeAgo: "1h ago"),
            MockComment(name: "Pepper", username: "pepperoni", avatarColorHex: "FF6B6B", text: "Love the positive energy, keep tracking! 💪✨", timeAgo: "45m ago")
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
            updateDisplayPost()
        }
    }
    
    private func toggleBookmark() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isBookmarked.toggle()
            updateDisplayPost()
        }
    }
    
    private func updateDisplayPost() {
        var updated = post
        updated.isLiked = isLiked
        updated.likesCount = likesCount
        updated.isBookmarked = isBookmarked
        updated.commentsCount = comments.count
        displayPost = updated
        onPostUpdated(updated)
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
            updateDisplayPost()
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: FeedPost(
                id: "1",
                user: MoodUser(id: "1", name: "Michele", username: "mj", avatarColorHex: "4DABF7", currentMoodEmoji: "😌", currentMoodText: "Calm", currentMoodColorHex: "4A5568"),
                timeAgo: "2h ago",
                quoteText: "Grateful hearts see awesome things.",
                caption: "Reflected on the beauty of nature. Grateful for the warm sun.",
                likesCount: 12,
                commentsCount: 2,
                isLiked: false,
                isBookmarked: false
            )
        )
        .environmentObject(NavigationVisibilityCoordinator())
    }
}
