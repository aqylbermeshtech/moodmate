//
//  PostDetailView.swift
//  moodmate
//
//  Created by Nurtore on 23.07.2026.
//

import SwiftUI
import Combine

struct PostComment: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let avatarColorHex: String
    let text: String
    let timeAgo: String
}

struct PostDetailView: View {
    @StateObject private var viewModel: PostDetailViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var commentText = ""

    init(postId: String) {
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(postId: postId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.theme.primaryBackground
                .ignoresSafeArea()

            if let currentPost = viewModel.displayPost {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PostCardView(
                            post: currentPost,
                            style: .detail,
                            onLike: { viewModel.toggleLike() },
                            onBookmark: { viewModel.toggleBookmark() },
                            onComment: {},
                            onDelete: viewModel.canDelete ? { deletePost() } : nil
                        )
                        Text("Comments (\(viewModel.comments.count))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.theme.primaryText)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)

                        if viewModel.comments.isEmpty {
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
                                ForEach(viewModel.comments) { comment in
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
            } else if viewModel.didLoad {
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
            viewModel.onAppear()
        }
        .errorAlert($viewModel.errorMessage)
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
    private func commentRow(comment: PostComment) -> some View {
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
    
    // MARK: - Actions

    private func deletePost() {
        viewModel.deletePost {
            dismiss()
        }
    }

    private func addComment() {
        viewModel.addComment(text: commentText)
        commentText = ""
    }
}

#Preview {
    NavigationStack {
        PostDetailView(postId: "p1")
    }
}
