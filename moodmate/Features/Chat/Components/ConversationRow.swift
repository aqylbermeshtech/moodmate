//
//  ConversationRow.swift
//  moodmate
//

import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                imageData: conversation.participant.avatarImageData,
                name: conversation.participant.name,
                colorHex: conversation.participant.avatarColorHex,
                size: 48,
                showBorder: false,
                moodEmoji: conversation.participant.currentMoodEmoji
            )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(conversation.participant.name)
                        .font(.xDisplayName)
                        .foregroundStyle(Color.theme.primaryText)

                    Text("@\(conversation.participant.username)")
                        .font(.xHandle)
                        .foregroundStyle(Color.theme.secondaryText)
                        .lineLimit(1)

                    if let lastMessage = conversation.lastMessage {
                        Text("· \(lastMessage.timeLabel)")
                            .font(.xTrendingMeta)
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }

                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.isFromCurrentUser ? "You: \(lastMessage.text)" : lastMessage.text)
                        .font(.xPostBody)
                        .foregroundStyle(Color.theme.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer()

            if conversation.unreadCount > 0 {
                Circle()
                    .fill(Color.theme.accent)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
