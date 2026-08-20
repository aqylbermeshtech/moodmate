//
//  SuggestedUserCard.swift
//  moodmate
//
//  Created by Nurtore on 26.07.2026.
//

import SwiftUI

struct SuggestedUserCard: View {
    let user: SuggestedUser
    var onFollow: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            AvatarView(
                imageData: user.avatarImageData,
                name: user.displayName,
                colorHex: user.avatarColorHex,
                size: 48,
                showBorder: false,
                moodEmoji: user.moodEmoji
            )

            VStack(spacing: 2) {
                Text(user.displayName)
                    .font(.xDisplayName)
                    .foregroundStyle(Color.theme.primaryText)
                    .lineLimit(1)

                Text("@\(user.username)")
                    .font(.xTrendingMeta)
                    .foregroundStyle(Color.theme.secondaryText)
                    .lineLimit(1)

                if let moodText = user.moodText, let emoji = user.moodEmoji {
                    HStack(spacing: 3) {
                        Text(emoji)
                            .font(.system(size: 10))
                        Text(moodText)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.theme.accent.opacity(0.12))
                    .foregroundStyle(Color.theme.accent)
                    .clipShape(Capsule())
                    .padding(.top, 2)
                }
            }

            Button(action: onFollow) {
                Text(user.isFollowing ? "Following" : "Follow")
                    .font(.xButton)
                    .foregroundStyle(user.isFollowing ? Color.theme.primaryText : .black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background {
                        if user.isFollowing {
                            Capsule()
                                .strokeBorder(Color.theme.secondaryText, lineWidth: 1)
                        } else {
                            Capsule()
                                .fill(Color.theme.primaryText)
                        }
                    }
            }
            .buttonStyle(XPressableStyle())
        }
        .frame(width: 130)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color.theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.theme.divider, lineWidth: 1)
        )
    }

}

#Preview {
    HStack(spacing: 12) {
        SuggestedUserCard(
            user: SuggestedUser(
                id: "1", displayName: "Luna Park", username: "luna_glow",
                avatarColorHex: "ED64A6", bio: "Night owl.", moodEmoji: "🌙",
                moodText: "Dreamy", moodColorHex: "805AD5", isFollowing: false
            ),
            onFollow: {}
        )
        SuggestedUserCard(
            user: SuggestedUser(
                id: "2", displayName: "River Stone", username: "river_flows",
                avatarColorHex: "38B2AC", bio: "Kayaker.", moodEmoji: "🌊",
                moodText: "Flowing", moodColorHex: "4DABF7", isFollowing: true
            ),
            onFollow: {}
        )
    }
    .padding()
    .background(Color.theme.primaryBackground)
}
