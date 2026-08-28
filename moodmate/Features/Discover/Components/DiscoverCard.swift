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

    private var author: AppUser? {
        userStore.user(for: post.userId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: post.gradientStartHex),
                                Color(hex: post.gradientEndHex)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: post.heightClass.heightValue)

                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                        .blur(radius: 18)
                        .offset(x: geo.size.width * 0.2, y: -geo.size.height * 0.1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(post.quoteText)
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(12)
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
