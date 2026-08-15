//
//  PostCardView.swift
//  moodmate
//
//  Unified post card component — replaces FeedCard and PostDetailView.postCard.
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
    var userStore: UserStoreProtocol = UserStore.shared

    /// Resolved live from UserStore, not stored on the post — this is what
    /// makes a display-name change show up here automatically with no sink.
    private var author: MoodUser? {
        userStore.moodUser(for: post.authorId)
    }

    private var postAccentColor: Color {
        if let hex = post.moodColorHex {
            return Color.adaptiveMoodColor(hex: hex)
        }
        return Color.theme.accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerSection
            contentSection
            captionSection
            actionsSection

            if style == .feed {
                Divider()
                    .padding(.top, 10)
                    .background(Color.theme.divider)
            }
        }
        .padding(.top, 8)
        .if(style == .detail) { view in
            view
                .padding(.vertical, 8)
                .background(Color.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 10) {
            headerUserInfo
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
    }

    @ViewBuilder
    private var headerUserInfo: some View {
        let content = HStack(spacing: 10) {
            AvatarView(
                imageData: author?.avatarImageData,
                name: author?.name ?? "",
                colorHex: author?.avatarColorHex ?? "38B2AC",
                size: 38,
                showBorder: true
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(author?.name ?? "")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.theme.primaryText)

                    Text("@\(author?.username ?? "")")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.theme.secondaryText)
                }

                HStack(spacing: 6) {
                    if let mood = post.moodEmoji ?? author?.currentMoodEmoji,
                       let text = post.moodText ?? author?.currentMoodText {
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

        switch style {
        case .feed:
            NavigationLink(destination: OtherProfileView(userId: post.authorId)) {
                content
            }
        case .detail:
            content
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        if !post.images.isEmpty {
            photoContentSection
        } else if !post.quoteText.isEmpty {
            quoteContentSection
        } else if post.caption.isEmpty, let moodEmoji = post.moodEmoji, let moodText = post.moodText {
            moodOnlyContentSection(moodEmoji: moodEmoji, moodText: moodText)
        }
    }

    // MARK: - Photo Content

    private var photoContentSection: some View {
        VStack(spacing: 8) {
            ForEach(post.images, id: \.self) { imageString in
                if let uiImage = imageFromBase64(imageString) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.image, style: .continuous))
                } else {
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

    // MARK: - Quote Content

    private var quoteContentSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.image, style: .continuous)
                .fill(postAccentColor.opacity(0.22))
                .frame(height: 220)

            VStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24))
                    .foregroundStyle(postAccentColor)
                    .padding(.bottom, 4)

                Text(post.quoteText)
                    .font(.title3.weight(.regular))
                    .foregroundStyle(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .minimumScaleFactor(0.85)

                Image(systemName: "quote.closing")
                    .font(.system(size: 24))
                    .foregroundStyle(postAccentColor)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Mood-Only Content

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

    // MARK: - Caption

    @ViewBuilder
    private var captionSection: some View {
        if !post.caption.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text("\(Text(author?.username ?? "").bold()) \(Text(post.caption))")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.theme.primaryText)
                        .multilineTextAlignment(.leading)
                }
                .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        HStack(spacing: 20) {
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

            Button(action: onBookmark) {
                Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(post.isBookmarked ? Color(hex: "FAB005") : Color.theme.primaryText.opacity(0.8))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

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
        VStack(spacing: 20) {
            PostCardView(
                post: FeedPost(
                    id: "p1",
                    authorId: "2",
                    timeAgo: "2h ago",
                    quoteText: "Breathe in experience, breathe out poetry.",
                    caption: "Taking a conscious pause today. 🌱"
                ),
                style: .feed,
                onLike: {}, onBookmark: {}, onComment: {}
            )

            PostCardView(
                post: FeedPost(
                    id: "p2",
                    authorId: "3",
                    timeAgo: "5h ago",
                    quoteText: "Grateful hearts see awesome things.",
                    caption: "Reflected on the beauty of nature."
                ),
                style: .detail,
                onLike: {}, onBookmark: {}, onComment: {}
            )
        }
    }
}
