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
                size: 52,
                showBorder: false,
                moodEmoji: conversation.participant.currentMoodEmoji
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(conversation.participant.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.primaryText)

                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.isFromCurrentUser ? "You: \(lastMessage.text)" : lastMessage.text)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.timeLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.theme.tertiaryText)
                }

                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(Color.theme.accent)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
