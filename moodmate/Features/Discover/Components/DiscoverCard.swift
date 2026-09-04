//
//  DiscoverCard.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct DiscoverCard: View {
    let post: DiscoverPost
    var onLike: () -> Void
    var userStore: UserStoreProtocol = UserStore.shared

    /// Decoded once when the card appears rather than on every body pass —
    /// base64 JPEG decoding is far too expensive to repeat while scrolling.
    @State private var photo: UIImage?

    private var author: AppUser? {
        userStore.user(for: post.userId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // The gradient sizes the slot; the photo rides in an overlay so
            // that `scaledToFill` can't widen the card past its grid column.
            gradientBackdrop
                .frame(maxWidth: .infinity)
                .frame(height: post.heightClass.heightValue)
                .overlay {
                    if let photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .overlay(alignment: .bottom) {
                    if !post.quoteText.isEmpty {
                        quoteOverlay
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .task(id: post.id) {
                guard let encoded = post.images.first else {
                    photo = nil
                    return
                }
                photo = UIImage.fromBase64(encoded)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    AvatarView(
                        name: author?.name ?? "",
                        colorHex: author?.avatarColorHex ?? "38B2AC",
                        size: 20,
                        showBorder: false
                    )

                    Text(author?.name ?? "")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.theme.primaryText)
                        .lineLimit(1)

                    Spacer()
                }

                HStack(spacing: 4) {
                    Button(action: onLike) {
                        HStack(spacing: 3) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(post.isLiked ? Color.theme.likePink : Color.theme.secondaryText)

                            Text("\(post.likesCount)")
                                .font(.xTrendingMeta)
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                    }
                    .buttonStyle(XPressableStyle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color.theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.theme.divider, lineWidth: 1)
        )
    }

    // MARK: - Artwork

    /// Visible only while the photo decode is in flight, or if the stored
    /// data can't be read.
    private var gradientBackdrop: some View {
        LinearGradient(
            colors: [
                Color(hex: post.gradientStartHex),
                Color(hex: post.gradientEndHex)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Scrimmed so the text stays readable whatever the photo underneath does.
    private var quoteOverlay: some View {
        Text(post.quoteText)
            .font(.system(size: 13, weight: .bold, design: .serif))
            .foregroundStyle(.white)
            .lineLimit(2)
            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

#Preview {
    HStack(alignment: .top, spacing: 12) {
        DiscoverCard(
            post: DiscoverPost(
                id: "1", userId: "su1",
                quoteText: "Stars can't shine without darkness.",
                caption: "Night thoughts.", gradientStartHex: "38B2AC", gradientEndHex: "805AD5",
                likesCount: 42, commentsCount: 5, isLiked: false,
                heightClass: .tall, createdAt: Date()
            ),
            onLike: {}
        )

        DiscoverCard(
            post: DiscoverPost(
                id: "2", userId: "su2",
                quoteText: "Be here now.",
                caption: "Flowing.", gradientStartHex: "667EEA", gradientEndHex: "764BA2",
                likesCount: 18, commentsCount: 2, isLiked: true,
                heightClass: .compact, createdAt: Date()
            ),
            onLike: {}
        )
    }
    .padding()
    .background(Color.theme.primaryBackground)
}
