//
//  PostDetailView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import Combine

struct MockComment: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let avatarColorHex: String
    let text: String
    let timeAgo: String
}

struct PostDetailView: View {
    let postId: String
    var postRepository: PostRepositoryProtocol = PostRepository.shared
    @Environment(\.dismiss) private var dismiss

    @State private var comments: [MockComment] = []
    @State private var commentText = ""
    @State private var displayPost: FeedPost?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var errorMessage: String?
    @State private var didLoad = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.primaryBackground
                .ignoresSafeArea()

            if let currentPost = displayPost {
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
            } else if didLoad {
                notFoundView
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Back")
            }
        }
        .onAppear {
            initializePostState()
        }
        .errorAlert($errorMessage)
    }

    private var notFoundView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Color.theme.secondaryText)
            Text("Post Not Found")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.primaryText)
            Text("This post may have been removed.")
                .font(.system(size: 13))
                .foregroundStyle(Color.theme.secondaryText)
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
        guard !didLoad else { return }

        if let post = postRepository.post(id: postId) {
            self.displayPost = FeedPost(from: post)
            self.comments = [
                MockComment(name: "Michele", username: "mj", avatarColorHex: "4DABF7", text: "Such a beautiful quote. Grateful for this reminder today.", timeAgo: "1h ago"),
                MockComment(name: "Pepper", username: "pepperoni", avatarColorHex: "FF6B6B", text: "Love the positive energy, keep it up!", timeAgo: "45m ago")
            ]
        }
        didLoad = true

        postRepository.postsPublisher
            .receive(on: DispatchQueue.main)
            .sink { updatedPosts in
                guard let matching = updatedPosts.first(where: { $0.id == postId }) else { return }
                var updated = FeedPost(from: matching)
                updated.commentsCount = max(updated.commentsCount, comments.count)
                displayPost = updated
            }
            .store(in: &cancellables)
    }

    private func toggleLike() {
        guard let currentPost = displayPost else { return }
        let desiredLikeState = !currentPost.isLiked
        let previousLiked = currentPost.isLiked
        let previousCount = currentPost.likesCount
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            displayPost?.isLiked = desiredLikeState
            displayPost?.likesCount += desiredLikeState ? 1 : -1
        }
        Task {
            do {
                try await postRepository.setLike(postId: postId, isLiked: desiredLikeState)
            } catch {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    displayPost?.isLiked = previousLiked
                    displayPost?.likesCount = previousCount
                }
                errorMessage = "Could not update like. Please try again."
            }
        }
    }

    private func toggleBookmark() {
        guard let currentPost = displayPost else { return }
        let previousBookmarked = currentPost.isBookmarked
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            displayPost?.isBookmarked.toggle()
        }
        Task {
            do {
                try await postRepository.toggleBookmark(postId: postId)
            } catch {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    displayPost?.isBookmarked = previousBookmarked
                }
                errorMessage = "Could not update bookmark. Please try again."
            }
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
            displayPost?.commentsCount = comments.count
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(postId: "p1")
    }
}
