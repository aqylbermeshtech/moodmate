//
//  PostCardView.swift
//  moodmate
//
//  X-style post row — replaces card-based FeedCard.
//

import SwiftUI

// MARK: - Post Card Style

enum PostCardStyle {
    case feed
    case detail
}

// MARK: - PostCardView

struct PostCardView: View {
    let post: FeedPost
    let style: PostCardStyle
    var onLike: () -> Void
    var onBookmark: () -> Void
    var onComment: () -> Void
    /// Supplied only when the viewer is allowed to delete this post — the
    /// overflow menu is the delete affordance, so it stays hidden without it.
    var onDelete: (() -> Void)? = nil
    var userStore: UserStoreProtocol = UserStore.shared
    @EnvironmentObject private var router: AppRouter

    @State private var showDeleteConfirmation = false
    @State private var isLikedLocal: Bool = false
    @State private var isRepostedLocal: Bool = false
    @State private var repostRotation: Double = 0

    private var author: AppUser? {
        userStore.user(for: post.authorId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                avatarButton

                VStack(alignment: .leading, spacing: 4) {
                    headerRow

                    bodyContent

                    actionRow
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().background(Color.theme.divider)
        }
        .background(Color.theme.primaryBackground)
        .onAppear {
            isLikedLocal = post.isLiked
        }
        .onChange(of: post.isLiked) { _, newValue in
            isLikedLocal = newValue
        }
    }

    // MARK: - Avatar

    @ViewBuilder
    private var avatarButton: some View {
        let avatar = AvatarView(
            imageData: author?.avatarImageData,
            name: author?.name ?? "",
            colorHex: author?.avatarColorHex ?? "38B2AC",
            size: 40,
            showBorder: false
        )

        switch style {
        case .feed:
            Button {
                router.push(.otherProfile(userId: post.authorId))
            } label: {
                avatar
            }
            .buttonStyle(PlainButtonStyle())
        case .detail:
            avatar
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 4) {
            Text(author?.name ?? "")
                .font(.xDisplayName)
                .foregroundStyle(Color.theme.primaryText)
                .lineLimit(1)

            Text("@\(author?.username ?? "")")
                .font(.xHandle)
                .foregroundStyle(Color.theme.secondaryText)
                .lineLimit(1)

            Text("·")
                .foregroundStyle(Color.theme.secondaryText)

            Text(post.timeAgo)
                .font(.xHandle)
                .foregroundStyle(Color.theme.secondaryText)

            Spacer()

            overflowMenu
        }
    }

    // MARK: - Overflow Menu

    private var overflowMenu: some View {
        Menu {
            ShareLink(item: shareText) {
                Label("Share post", systemImage: "square.and.arrow.up")
            }

            if onDelete != nil {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete post", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18))
                .foregroundStyle(Color.theme.secondaryText)
                .frame(width: 32, height: 32, alignment: .trailing)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("More options")
        .confirmationDialog(
            "Delete this post?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { onDelete?() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This post will be removed for good. This can't be undone.")
        }
    }

    /// Plain text rather than a `moodmate://post/...` deep link: posts live
    /// only on the device that wrote them, so a link would dead-end for
    /// whoever received it. Worth revisiting once posts are server-backed.
    private var shareText: String {
        let body = post.caption.isEmpty ? post.quoteText : post.caption

        var parts: [String] = []
        if !body.isEmpty { parts.append(body) }

        if let author, !author.name.isEmpty {
            parts.append("— \(author.name) (@\(author.username)) on MoodMate")
        } else {
            parts.append("Shared from MoodMate")
        }

        return parts.joined(separator: "\n\n")
    }

    // MARK: - Body Content

    @ViewBuilder
    private var bodyContent: some View {
        if !post.caption.isEmpty {
            Text(post.caption)
                .font(.xPostBody)
                .foregroundStyle(Color.theme.primaryText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }

        if !post.images.isEmpty {
            photoContent
        }

        if !post.quoteText.isEmpty {
            quoteContent
        }
    }

    // MARK: - Photo Content

    private var photoContent: some View {
        VStack(spacing: 4) {
            ForEach(post.images, id: \.self) { imageString in
                if let uiImage = UIImage.fromBase64(imageString) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.theme.divider, lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.theme.secondaryBackground)
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Quote Content

    private var quoteContent: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle()
                    .fill(Color.theme.accent)
                    .frame(width: 3)

                Text(post.quoteText)
                    .font(.xQuotedBody)
                    .foregroundStyle(Color.theme.primaryText)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
        }
        .padding(.top, 4)
    }

    // MARK: - Action Row

    /// Four equally-spaced actions. Every item carries the same centred
    /// 44pt frame, so the spacers between them render as equal gaps.
    private var actionRow: some View {
        HStack(spacing: 0) {
            XActionIcon(
                systemName: "bubble.left",
                count: post.commentsCount,
                color: Color.theme.secondaryText,
                active: false
            )
            .contentShape(Rectangle())
            .onTapGesture { onComment() }

            Spacer(minLength: 8)

            Image(systemName: "arrow.2.squarepath")
                .font(.system(size: 18.75))
                .foregroundStyle(isRepostedLocal ? Color.theme.repostGreen : Color.theme.secondaryText)
                .rotationEffect(.degrees(repostRotation))
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .onTapGesture {
                    isRepostedLocal.toggle()
                    withAnimation(.easeOut(duration: 0.4)) { repostRotation += 360 }
                }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Image(systemName: isLikedLocal ? "heart.fill" : "heart")
                    .font(.system(size: 18.75, weight: isLikedLocal ? .semibold : .regular))
                    .foregroundStyle(isLikedLocal ? Color.theme.likePink : Color.theme.secondaryText)
                    .scaleEffect(isLikedLocal ? 1.0 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.55), value: isLikedLocal)

                if post.likesCount > 0 {
                    Text(formattedCount(post.likesCount))
                        .font(.xActionCount)
                        .foregroundStyle(isLikedLocal ? Color.theme.likePink : Color.theme.secondaryText)
                }
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                onLike()
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isLikedLocal)

            Spacer(minLength: 8)

            Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.system(size: 18))
                .foregroundStyle(post.isBookmarked ? Color.theme.accent : Color.theme.secondaryText)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .onTapGesture { onBookmark() }
                .accessibilityLabel(post.isBookmarked ? "Remove from saved" : "Save post")
        }
    }

    // MARK: - Helpers

    private func formattedCount(_ n: Int) -> String {
        switch n {
        case 1_000_000...: return String(format: "%.1fM", Double(n)/1_000_000)
        case 1_000...:     return String(format: "%.1fK", Double(n)/1_000)
        default:           return "\(n)"
        }
    }
}

// MARK: - Conditional Modifier Helper

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            PostCardView(
                post: FeedPost(
                    id: "p1",
                    authorId: "2",
                    timeAgo: "2h",
                    quoteText: "Breathe in experience, breathe out poetry.",
                    caption: "Taking a conscious pause today."
                ),
                style: .feed,
                onLike: {}, onBookmark: {}, onComment: {}
            )

            PostCardView(
                post: FeedPost(
                    id: "p2",
                    authorId: "3",
                    timeAgo: "5h",
                    quoteText: "",
                    caption: "Just had an incredible morning walk through the park. The fresh air is exactly what I needed after a long week."
                ),
                style: .feed,
                onLike: {}, onBookmark: {}, onComment: {}
            )
        }
    }
    .background(Color.theme.primaryBackground)
    .environmentObject(AppRouter.shared)
}
